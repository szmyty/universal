# 🧩 DPKG Configuration for Docker Optimization

This directory contains modular `dpkg.cfg.d` configuration files that optimize the Debian `dpkg` package manager for use in Docker containers.

---

## 🧩 Purpose

- 🐳 Eliminate interactive prompts during builds
- 📦 Strip unnecessary files (man pages, locales) to reduce image size
- 🔄 Improve logging and visibility
- 🚀 (Optional) Speed up installs with `force-unsafe-io`

---

## 📂 File Breakdown

| File                     | Purpose                                                                         |
| ------------------------ | ------------------------------------------------------------------------------- |
| `01-logging.conf`        | Enables log output to `/var/log/dpkg.log`                                       |
| `10-noninteractive.conf` | Enables `confdef`, disables pagers and pseudo-tty use                           |
| `20-size-reduction.conf` | Removes unused man/doc/locale files, keeps legal copyright                      |
| `30-security.conf`       | Disables signature enforcement by default (safe for standard mirrors)           |
| `40-performance.conf`    | (Optional) Uncomment `force-unsafe-io` to speed up installs in ephemeral builds |

---

## 🐳 Dockerfile Integration

```shell
COPY configs/dpkg/*.conf /etc/dpkg/dpkg.cfg.d/
```

---

## ⚠️ Caution

- `force-unsafe-io` can significantly speed up installs but should **only be enabled** in ephemeral or CI containers — it skips filesystem syncs, which is unsafe on real systems.
- To preserve legal attribution, we \*\*only delete doc files except `copyright`.

---

## 🧼 Best Practices

- Use `dpkg -L <package>` to preview what files would be removed by `path-exclude`.
- Combine with APT `apt.conf.d` settings for full control over Debian package behavior.

---
