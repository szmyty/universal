#!/usr/bin/env python3

import os
import sys
import json
import subprocess
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


def log(msg: str) -> None:
    """Print a structured log message."""
    print(f"🔧 {msg}")


def run(cmd: List[str], **kwargs) -> None:
    """Run a subprocess command with error handling."""
    subprocess.run(cmd, check=True, **kwargs)


def run_as_root_write(path: Path, content: str) -> None:
    """Write to a root-owned file using sudo and tee."""
    run(["sudo", "tee", str(path)], input=content.encode(), stdout=subprocess.DEVNULL)


def safe_chown(path: Path, user: str, group: str) -> None:
    """Recursively chown a path."""
    run(["sudo", "chown", "-R", f"{user}:{group}", str(path)])


def safe_mkdir(path: Path) -> None:
    """Ensure a directory exists."""
    path.mkdir(parents=True, exist_ok=True)


def safe_mkdir_root(path: Path) -> None:
    """Create a directory with sudo using 'mkdir -p'."""
    run(["sudo", "mkdir", "-p", str(path)])


def write_json_if_changed(path: Path, new_data: Dict) -> None:
    """Write JSON to a file only if the contents have changed."""
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
    """Ensure ~/.ssh exists and has correct permissions."""
    safe_mkdir(SSH_DIR)
    safe_chown(SSH_DIR, "vscode", "vscode")
    SSH_DIR.chmod(0o700)


def setup_docker_config() -> None:
    """Configure ~/.docker/config.json with proxy values if set."""
    safe_mkdir(DOCKER_CONFIG_DIR)
    if not DOCKER_CONFIG_JSON.exists():
        DOCKER_CONFIG_JSON.write_text("{}\n")

    safe_chown(DOCKER_CONFIG_DIR, "vscode", "vscode")

    try:
        cfg = json.loads(DOCKER_CONFIG_JSON.read_text())
    except Exception:
        cfg = {}

    new_cfg = cfg.copy()
    proxies: Dict[str, str] = {}

    for env_var, key in [
        ("HTTP_PROXY", "httpProxy"),
        ("HTTPS_PROXY", "httpsProxy"),
        ("NO_PROXY", "noProxy"),
    ]:
        val = os.environ.get(env_var) or os.environ.get(env_var.lower())
        if val:
            proxies[key] = val

    if proxies:
        new_cfg.setdefault("proxies", {})["default"] = proxies
    else:
        new_cfg.pop("proxies", None)

    write_json_if_changed(DOCKER_CONFIG_JSON, new_cfg)


def setup_daemon_json() -> None:
    """Set DNS and insecure registries in /etc/docker/daemon.json if provided."""
    safe_mkdir_root(DAEMON_JSON.parent)

    if not DAEMON_JSON.exists():
        run_as_root_write(DAEMON_JSON, "{}\n")

    try:
        data = json.loads(DAEMON_JSON.read_text())
    except Exception:
        data = {}

    updated = False

    dns_val: str = os.environ.get("DOCKER_DNS", "8.8.8.8")
    if data.get("dns") != [dns_val]:
        data["dns"] = [dns_val]
        updated = True

    registries = os.environ.get("INSECURE_REGISTRIES", "")
    if registries:
        reg_list = [r.strip() for r in registries.split(",") if r.strip()]
        if data.get("insecure-registries") != reg_list:
            data["insecure-registries"] = reg_list
            updated = True

    if updated:
        write_json_if_changed(DAEMON_JSON, data)


def setup_systemd_proxy() -> None:
    """Create a docker service override for proxy environment variables."""
    safe_mkdir_root(SYSTEMD_DIR)

    if not SYSTEMD_PROXY_FILE.exists():
        proxy_vars = [
            ("HTTP_PROXY", "http_proxy"),
            ("HTTPS_PROXY", "https_proxy"),
            ("NO_PROXY", "no_proxy"),
        ]
        env_lines: List[str] = []

        for upper, lower in proxy_vars:
            val = os.environ.get(upper) or os.environ.get(lower)
            if val:
                env_lines.append(f'Environment="{upper}={val}"')
                env_lines.append(f'Environment="{lower}={val}"')

        if env_lines:
            proxy_block = "[Service]\n" + "\n".join(env_lines) + "\n"
            run_as_root_write(SYSTEMD_PROXY_FILE, proxy_block)
            log(f"Created {SYSTEMD_PROXY_FILE}")


def reload_systemd() -> None:
    """Reload systemd daemon safely."""
    try:
        run(["sudo", "systemctl", "daemon-reexec"])
    except subprocess.CalledProcessError:
        log("⚠️ Failed to reload systemd daemon (non-fatal)")


def restart_docker_daemon() -> None:
    """Restart the Docker daemon using custom entrypoint script."""
    try:
        log("Restarting Docker daemon using custom script...")
        run(["sudo", "pkill", "-f", "dockerd"])
    except subprocess.CalledProcessError:
        log("⚠️ 'dockerd' was not running — skipping.")

    try:
        run(["sudo", "pkill", "-f", "containerd"])
    except subprocess.CalledProcessError:
        log("⚠️ 'containerd' was not running — skipping.")

    try:
        run(["bash", str(DOCKER_INIT_SCRIPT)])
        log("✅ Docker restarted successfully.")
    except subprocess.CalledProcessError as e:
        log(f"❌ Failed to run Docker init script: {e}")
        sys.exit(1)


def verify_docker_connection() -> None:
    """Check Docker CLI is functional."""
    try:
        subprocess.run(["docker", "images"], capture_output=True, text=True, check=True)
        log("✅ Docker is working and can list images.")
        if any(os.environ.get(k) for k in ("HTTP_PROXY", "HTTPS_PROXY")):
            log("🔍 Proxy environment detected. Docker appears to function with proxy.")
    except subprocess.CalledProcessError as e:
        log("❌ Docker command failed.")
        log(f"stderr: {e.stderr}")
        sys.exit(1)


def pretty_print_file(path: Path) -> None:
    """Display file contents in a human-friendly way."""
    if not path.exists():
        log(f"⚠️ {path} does not exist.")
        return

    log(f"📄 {path}:")
    try:
        output = subprocess.run(
            ["sudo", "cat", str(path)], capture_output=True, text=True, check=True
        ).stdout
    except subprocess.CalledProcessError as e:
        log(f"❌ Failed to read {path}: {e}")
        return

    try:
        data = json.loads(output)
        print(json.dumps(data, indent=2))
    except Exception:
        print(output)


def verify_proxy_settings() -> None:
    """Confirm that proxy configuration files exist and contain proxy info."""
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


def main() -> None:
    """Main proxy setup flow."""
    log("Setting up development proxy environment...")
    setup_ssh()
    setup_docker_config()
    setup_daemon_json()
    setup_systemd_proxy()
    reload_systemd()
    restart_docker_daemon()
    verify_docker_connection()
    verify_proxy_settings()
    log("✅ Dev container postCreate setup finished. Docker is ready.")


def main_wrapper() -> None:
    """Wrap main logic with error trapping."""
    try:
        main()
    except Exception as e:
        log(f"💥 Fatal error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main_wrapper()
