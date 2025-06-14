# ⚙️ APT Configuration for Docker Builds

This directory contains modular `apt.conf.d` configuration files that optimize Debian-based APT usage for reproducibility, performance, and minimal image size in Docker environments.

---

## 🧩 Purpose

- 🐳 Non-interactive + deterministic Docker builds
- 📉 Reduced image size by avoiding suggested/recommended packages
- 🔐 Secure repository usage (no downgrades or insecure mirrors)
- ⚡ Faster builds via tuned download and compression settings
- 🧼 Clean layer caching via post-invoke cleanup

---

## 📂 File Breakdown

| File                  | Purpose                                                                             |
| --------------------- | ----------------------------------------------------------------------------------- |
| `00-global.conf`      | Basic defaults like colored output and root sandboxing                              |
| `01-assumptions.conf` | Non-interactive install behavior (assume yes, no loop breaking)                     |
| `02-recommends.conf`  | Prevents auto-installation of `Recommended` or `Suggested` packages                 |
| `03-cleanup.conf`     | Adds timestamping and purges APT cache after installs and updates                   |
| `04-quiet.conf`       | Reduces logging noise from APT operations                                           |
| `05-acquire.conf`     | Optimizes how files and metadata are fetched and compressed                         |
| `06-security.conf`    | Ensures only trusted, up-to-date repositories are used                              |
| `07-https.conf`       | HTTPS hardening (disable caching if not caching `/var/cache/apt`)                   |
| `08-keep-cache.conf`  | Prevents Docker from deleting downloaded `.deb` packages (for caching or debugging) |

---

## 🐳 Dockerfile Integration

```dockerfile
COPY configs/apt/*.conf /etc/apt/apt.conf.d/
```
