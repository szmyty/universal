#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import argparse
from typing import Dict, List
from pathlib import Path

# === Constants ===
USER_HOME = Path("/home/vscode")
SSH_DIR = USER_HOME / ".ssh"
DOCKER_CONFIG_DIR = USER_HOME / ".docker"
DOCKER_CONFIG_JSON = DOCKER_CONFIG_DIR / "config.json"
DAEMON_JSON = Path("/etc/docker/daemon.json")
SYSTEMD_DIR = Path("/etc/systemd/system/docker.service.d")
SYSTEMD_PROXY_FILE = SYSTEMD_DIR / "http-proxy.conf"
DOCKER_INIT_SCRIPT = Path("/usr/local/share/docker-init.sh")

# Will be set later from args
LOG_FILE_PATH = None
LOG_FILE_HANDLE = None

def parse_args():
    parser = argparse.ArgumentParser(description="Docker Proxy Setup")

    parser.add_argument("--http-proxy", default=None)
    parser.add_argument("--https-proxy", default=None)
    parser.add_argument("--no-proxy", default=None)
    parser.add_argument("--docker-dns", default=None)
    parser.add_argument("--insecure-registries", default=None)
    parser.add_argument("--log-file", default=None)

    args = parser.parse_args()

    def resolve(key, env_key, default=None):
        val = getattr(args, key)
        if val == "none":
            return ""
        return val or os.getenv(env_key, default or "")

    args.http_proxy = resolve("http_proxy", "HTTP_PROXY")
    args.https_proxy = resolve("https_proxy", "HTTPS_PROXY")
    args.no_proxy = resolve("no_proxy", "NO_PROXY")
    args.docker_dns = resolve("docker_dns", "DOCKER_DNS", "8.8.8.8")
    args.insecure_registries = resolve("insecure_registries", "INSECURE_REGISTRIES")
    args.log_file = resolve("log_file", "LOG_FILE", "/var/log/.devtools/docker-proxy.log")

    return args

def init_logging(path: Path) -> None:
    global LOG_FILE_HANDLE
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        LOG_FILE_HANDLE = open(path, "a", encoding="utf-8")
    except Exception as e:
        print(f"⚠️  Failed to open log file {path}: {e}")

def log(msg: str) -> None:
    line = f"🔧 {msg}"
    print(line)
    if LOG_FILE_HANDLE:
        try:
            LOG_FILE_HANDLE.write(line + "\n")
            LOG_FILE_HANDLE.flush()
        except Exception:
            pass

def run(cmd: List[str], **kwargs) -> None:
    subprocess.run(cmd, check=True, **kwargs)

def run_as_root_write(path: Path, content: str) -> None:
    run(["sudo", "tee", str(path)], input=content.encode(), stdout=subprocess.DEVNULL)

def safe_chown(path: Path, user: str, group: str) -> None:
    run(["sudo", "chown", "-R", f"{user}:{group}", str(path)])

def safe_mkdir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)

def safe_mkdir_root(path: Path) -> None:
    run(["sudo", "mkdir", "-p", str(path)])

def write_json_if_changed(path: Path, new_data: Dict) -> None:
    old_data = {}
    if path.exists():
        try:
            old_data = json.loads(path.read_text())
        except Exception:
            pass
    if old_data != new_data:
        log(f"Updating {path}")
        run_as_root_write(path, json.dumps(new_data, indent=2))

def setup_ssh() -> None:
    safe_mkdir(SSH_DIR)
    safe_chown(SSH_DIR, "vscode", "vscode")
    SSH_DIR.chmod(0o700)

def setup_docker_config(http, https, no) -> None:
    safe_mkdir(DOCKER_CONFIG_DIR)
    if not DOCKER_CONFIG_JSON.exists():
        DOCKER_CONFIG_JSON.write_text("{}\n")
    safe_chown(DOCKER_CONFIG_DIR, "vscode", "vscode")

    try:
        cfg = json.loads(DOCKER_CONFIG_JSON.read_text())
    except Exception:
        cfg = {}

    proxies = {}
    if http: proxies["httpProxy"] = http
    if https: proxies["httpsProxy"] = https
    if no: proxies["noProxy"] = no

    if proxies:
        cfg.setdefault("proxies", {})["default"] = proxies
    else:
        cfg.pop("proxies", None)

    write_json_if_changed(DOCKER_CONFIG_JSON, cfg)

def setup_daemon_json(dns_val, registries) -> None:
    safe_mkdir_root(DAEMON_JSON.parent)
    if not DAEMON_JSON.exists():
        run_as_root_write(DAEMON_JSON, "{}\n")

    try:
        data = json.loads(DAEMON_JSON.read_text())
    except Exception:
        data = {}

    updated = False
    if data.get("dns") != [dns_val]:
        data["dns"] = [dns_val]
        updated = True

    reg_list = [r.strip() for r in registries.split(",") if r.strip()]
    if data.get("insecure-registries") != reg_list:
        data["insecure-registries"] = reg_list
        updated = True

    if updated:
        write_json_if_changed(DAEMON_JSON, data)

def setup_systemd_proxy(http, https, no) -> None:
    safe_mkdir_root(SYSTEMD_DIR)
    if SYSTEMD_PROXY_FILE.exists():
        return

    env_lines = []
    for name, val in [("HTTP_PROXY", http), ("HTTPS_PROXY", https), ("NO_PROXY", no)]:
        if val:
            env_lines.append(f'Environment="{name}={val}"')
            env_lines.append(f'Environment="{name.lower()}={val}"')

    if env_lines:
        block = "[Service]\n" + "\n".join(env_lines) + "\n"
        run_as_root_write(SYSTEMD_PROXY_FILE, block)
        log(f"Created {SYSTEMD_PROXY_FILE}")

def reload_systemd() -> None:
    try:
        run(["sudo", "systemctl", "daemon-reexec"])
    except subprocess.CalledProcessError:
        log("⚠️ Failed to reload systemd daemon (non-fatal)")

def restart_docker_daemon() -> None:
    """Restart the Docker daemon in Docker-in-Docker environments."""
    # First try using the service command (for systemd based containers)
    try:
        run(["sudo", "service", "docker", "restart"])
        log("✅ Docker restarted via service command.")
        return
    except subprocess.CalledProcessError as e:
        log(f"⚠️ Failed to restart Docker via service: {e}. Falling back to docker-init script...")

    # Fall back to using the docker-init script provided by the docker-in-docker feature
    if DOCKER_INIT_SCRIPT.exists():
        try:
            run(["sudo", "pkill", "-f", "dockerd"])
        except subprocess.CalledProcessError:
            log("⚠️ 'dockerd' was not running — skipping.")
        try:
            run(["sudo", "pkill", "-f", "containerd"])
        except subprocess.CalledProcessError:
            log("⚠️ 'containerd' was not running — skipping.")
        try:
            run(["sudo", "bash", str(DOCKER_INIT_SCRIPT)])
            log("✅ Docker restarted via docker-init script.")
            return
        except subprocess.CalledProcessError as e:
            log(f"❌ Failed to run Docker init script: {e}")
    else:
        log(f"❌ {DOCKER_INIT_SCRIPT} not found.")
    sys.exit(1)

def verify_docker_connection() -> None:
    try:
        subprocess.run(["sudo", "docker", "images"], capture_output=True, check=True)
        log("✅ Docker is working and can list images.")
    except subprocess.CalledProcessError as e:
        log("❌ Docker command failed.")
        log(f"stderr: {e.stderr}")
        sys.exit(1)

def pretty_print_file(path: Path) -> None:
    if not path.exists():
        log(f"⚠️ {path} does not exist.")
        return
    log(f"📄 {path}:")
    try:
        output = subprocess.run(["sudo", "cat", str(path)], capture_output=True, text=True).stdout
        data = json.loads(output)
        print(json.dumps(data, indent=2))
    except Exception:
        print(output)

def verify_proxy_settings() -> None:
    log("Verifying Docker proxy configuration files...")
    ok = True

    if SYSTEMD_PROXY_FILE.exists():
        log(f"✅ Found {SYSTEMD_PROXY_FILE}")
    else:
        log(f"❌ Missing {SYSTEMD_PROXY_FILE}")
        ok = False

    if DOCKER_CONFIG_JSON.exists():
        try:
            cfg = json.loads(DOCKER_CONFIG_JSON.read_text())
            if cfg.get("proxies", {}).get("default"):
                log("✅ Proxy settings present in config.json")
            else:
                log("⚠️ No proxy settings detected in config.json")
                ok = False
        except Exception as e:
            log(f"❌ Failed to parse {DOCKER_CONFIG_JSON}: {e}")
            ok = False
    else:
        log(f"❌ Missing {DOCKER_CONFIG_JSON}")
        ok = False

    if ok:
        log("✅ Proxy settings applied successfully.")
    else:
        log("⚠️ Proxy settings may not have been fully applied.")

    pretty_print_file(DAEMON_JSON)
    pretty_print_file(DOCKER_CONFIG_JSON)
    pretty_print_file(SYSTEMD_PROXY_FILE)

def main():
    args = parse_args()
    global LOG_FILE_PATH
    LOG_FILE_PATH = Path(args.log_file)
    init_logging(LOG_FILE_PATH)

    log("🚀 Setting up Docker proxy environment...")
    setup_ssh()
    setup_docker_config(args.http_proxy, args.https_proxy, args.no_proxy)
    setup_daemon_json(args.docker_dns, args.insecure_registries)
    setup_systemd_proxy(args.http_proxy, args.https_proxy, args.no_proxy)
    # reload_systemd()
    restart_docker_daemon()
    verify_docker_connection()
    verify_proxy_settings()
    log("✅ Dev container setup complete.")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        log(f"💥 Fatal error: {e}")
        sys.exit(1)
    finally:
        if LOG_FILE_HANDLE:
            try:
                LOG_FILE_HANDLE.close()
            except Exception:
                pass
