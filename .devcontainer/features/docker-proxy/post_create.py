#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import argparse
import logging
from typing import Dict, List, Any, Optional
from pathlib import Path

# === Constants ===
USER_HOME: Path = Path("/home/vscode")
SSH_DIR: Path = USER_HOME / ".ssh"
DOCKER_CONFIG_DIR: Path = USER_HOME / ".docker"
DOCKER_CONFIG_JSON: Path = DOCKER_CONFIG_DIR / "config.json"
DAEMON_JSON: Path = Path("/etc/docker/daemon.json")
SYSTEMD_DIR: Path = Path("/etc/systemd/system/docker.service.d")
SYSTEMD_PROXY_FILE: Path = SYSTEMD_DIR / "http-proxy.conf"
DOCKER_INIT_SCRIPT: Path = Path("/usr/local/share/docker-init.sh")

# === Globals ===
logger: logging.Logger = logging.getLogger("docker-proxy")


def setup_logging(log_file: Path) -> None:
    """Initialize logging to file and console."""
    log_file.parent.mkdir(parents=True, exist_ok=True)
    handler = logging.FileHandler(log_file)
    console = logging.StreamHandler(sys.stdout)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[handler, console],
    )


def resolve_arg(
    args: argparse.Namespace, key: str, env_key: str, default: Optional[str] = None
) -> str:
    """Resolve argument from CLI or environment, with optional default."""
    val = getattr(args, key)
    if val == "none":
        return ""
    return val or os.getenv(env_key, default or "")


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments and resolve with fallbacks."""
    parser = argparse.ArgumentParser(description="Docker Proxy Setup")
    parser.add_argument("--http-proxy", default=None)
    parser.add_argument("--https-proxy", default=None)
    parser.add_argument("--no-proxy", default=None)
    parser.add_argument("--docker-dns", default=None)
    parser.add_argument("--insecure-registries", default=None)
    parser.add_argument("--log-file", default=None)

    args = parser.parse_args()

    args.http_proxy = resolve_arg(args, "http_proxy", "HTTP_PROXY")
    args.https_proxy = resolve_arg(args, "https_proxy", "HTTPS_PROXY")
    args.no_proxy = resolve_arg(args, "no_proxy", "NO_PROXY")
    args.docker_dns = resolve_arg(args, "docker_dns", "DOCKER_DNS", "8.8.8.8")
    args.insecure_registries = resolve_arg(args, "insecure_registries", "INSECURE_REGISTRIES")
    args.log_file = resolve_arg(
        args, "log_file", "LOG_FILE", "/var/log/.devtools/docker-proxy-setup.log"
    )

    return args


def run(cmd: List[str], **kwargs: Any) -> None:
    """Run a shell command and raise if it fails."""
    subprocess.run(cmd, check=True, **kwargs)


def run_as_root_write(path: Path, content: str) -> None:
    """Write content to a file as root."""
    run(["sudo", "tee", str(path)], input=content.encode(), stdout=subprocess.DEVNULL)


def safe_chown(path: Path, user: str, group: str) -> None:
    run(["sudo", "chown", "-R", f"{user}:{group}", str(path)])


def safe_mkdir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def safe_mkdir_root(path: Path) -> None:
    run(["sudo", "mkdir", "-p", str(path)])


def write_json_if_changed(path: Path, new_data: Dict[str, Any]) -> None:
    """Write JSON to file only if it differs from existing content."""
    old_data: Dict[str, Any] = {}
    if path.exists():
        try:
            old_data = json.loads(path.read_text())
        except Exception:
            pass
    if old_data != new_data:
        logger.info(f"Updating {path}")
        content = json.dumps(new_data, indent=2, separators=(",", ": ")) + "\n"
        run_as_root_write(path, content)


def setup_ssh() -> None:
    """Ensure ~/.ssh exists with proper permissions."""
    safe_mkdir(SSH_DIR)
    safe_chown(SSH_DIR, "vscode", "vscode")
    SSH_DIR.chmod(0o700)


def setup_docker_config(http: str, https: str, no: str) -> None:
    """Write Docker client proxy config."""
    safe_mkdir(DOCKER_CONFIG_DIR)
    if not DOCKER_CONFIG_JSON.exists():
        DOCKER_CONFIG_JSON.write_text("{}\n")
    safe_chown(DOCKER_CONFIG_DIR, "vscode", "vscode")

    cfg: Dict[str, Any] = {}
    try:
        cfg = json.loads(DOCKER_CONFIG_JSON.read_text())
    except Exception:
        pass

    proxies: Dict[str, str] = {}
    if http:
        proxies["httpProxy"] = http
    if https:
        proxies["httpsProxy"] = https
    if no:
        proxies["noProxy"] = no

    if proxies:
        cfg.setdefault("proxies", {})["default"] = proxies
    else:
        cfg.pop("proxies", None)

    write_json_if_changed(DOCKER_CONFIG_JSON, cfg)


def setup_daemon_json(dns_val: str, registries: str) -> None:
    """Write daemon.json DNS and insecure registry config."""
    safe_mkdir_root(DAEMON_JSON.parent)
    if not DAEMON_JSON.exists():
        run_as_root_write(DAEMON_JSON, "{}\n")

    data: Dict[str, Any] = {}
    try:
        data = json.loads(DAEMON_JSON.read_text())
    except Exception:
        pass

    updated = False
    if data.get("dns") != [dns_val]:
        data["dns"] = [dns_val]
        updated = True

    reg_list: List[str] = [r.strip() for r in registries.split(",") if r.strip()]
    if data.get("insecure-registries") != reg_list:
        data["insecure-registries"] = reg_list
        updated = True

    if updated:
        write_json_if_changed(DAEMON_JSON, data)


def setup_systemd_proxy(http: str, https: str, no: str) -> None:
    """Write systemd drop-in config for Docker proxy env vars."""
    safe_mkdir_root(SYSTEMD_DIR)
    if SYSTEMD_PROXY_FILE.exists():
        return

    env_lines: List[str] = []
    for name, val in [("HTTP_PROXY", http), ("HTTPS_PROXY", https), ("NO_PROXY", no)]:
        if val:
            env_lines.append(f'Environment="{name}={val}"')
            env_lines.append(f'Environment="{name.lower()}={val}"')

    if env_lines:
        block = "[Service]\n" + "\n".join(env_lines) + "\n"
        run_as_root_write(SYSTEMD_PROXY_FILE, block)
        logger.info(f"Created {SYSTEMD_PROXY_FILE}")


def restart_docker_daemon() -> None:
    """Restart the Docker daemon safely."""
    try:
        run(["sudo", "service", "docker", "restart"])
        logger.info("✅ Docker restarted via service command.")
        return
    except subprocess.CalledProcessError as e:
        logger.warning(f"Service restart failed: {e}")

    if DOCKER_INIT_SCRIPT.exists():
        for proc in ["dockerd", "containerd"]:
            try:
                run(["sudo", "pkill", "-f", proc])
            except subprocess.CalledProcessError:
                logger.warning(f"⚠️ '{proc}' was not running — skipping.")
        try:
            run(["sudo", "bash", str(DOCKER_INIT_SCRIPT)])
            logger.info("✅ Docker restarted via docker-init script.")
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Failed to run Docker init script: {e}")
            sys.exit(1)
    else:
        logger.error(f"❌ {DOCKER_INIT_SCRIPT} not found.")
        sys.exit(1)


def verify_docker_connection() -> None:
    """Ensure Docker is operational."""
    try:
        subprocess.run(["sudo", "docker", "images"], capture_output=True, check=True)
        logger.info("✅ Docker is working and can list images.")
    except subprocess.CalledProcessError as e:
        logger.error("❌ Docker command failed.")
        logger.error(f"stderr: {e.stderr}")
        sys.exit(1)


def main() -> None:
    args = parse_args()
    setup_logging(Path(args.log_file))

    logger.info("🚀 Setting up Docker proxy environment...")
    setup_ssh()
    setup_docker_config(args.http_proxy, args.https_proxy, args.no_proxy)
    setup_daemon_json(args.docker_dns, args.insecure_registries)
    setup_systemd_proxy(args.http_proxy, args.https_proxy, args.no_proxy)
    restart_docker_daemon()
    verify_docker_connection()
    logger.info("✅ Dev container setup complete.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logger.exception(f"💥 Fatal error: {e}")
        sys.exit(1)
