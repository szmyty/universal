## 🧠 General Task

### 🧭 Objective

Configure log rotation for the Apache server to prevent disk overflow and maintain log hygiene. This ensures logs are rotated, compressed, and pruned automatically.

### 🗺️ Plan

- [ ] Verify Apache log paths (e.g., `/var/log/apache2/*.log` or custom paths in `httpd.conf`)
- [ ] Create a logrotate configuration file (e.g., `/etc/logrotate.d/apache2` or local project override)
- [ ] Set appropriate rotation policy: daily/weekly, `rotate 7`, `compress`, `missingok`, `notifempty`
- [ ] Test rotation manually with `logrotate -f`
- [ ] Ensure permissions and ownership are preserved (`create 640 root adm`)
- [ ] If containerized, decide if log rotation is done inside container or at host level
- [ ] Document retention policy and location for team visibility

### 🔗 References / Resources

- [Logrotate man page](https://man7.org/linux/man-pages/man8/logrotate.8.html)
- Example:
  ```bash
  /var/log/apache2/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 640 root adm
    sharedscripts
    postrotate
        systemctl reload apache2 > /dev/null 2>&1 || true
    endscript
  }
  ```
