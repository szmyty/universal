# Lynis Security Auditing

[Lynis](https://github.com/CISOfy/lynis) is a security auditing tool for Unix based systems.
This repository ships a small configuration and Taskfile commands to run audits.

## Installation

Run the installation script which fetches a pinned release from GitHub:

```bash
# Installs to /usr/local/lynis and creates /usr/local/bin/lynis
scripts/install_lynis.sh
```

You can override the version or prefix path by providing arguments:

```bash
scripts/install_lynis.sh 3.1.1 /opt
```

## Running an Audit

Use the Taskfile wrapper to execute Lynis with the repo configuration:

```bash
task lynis:system
```

Logs and reports are written to `reports/lynis/`.

