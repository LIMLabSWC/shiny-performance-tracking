# Server & Scheduling Setup Notes

These notes are for configuring the Shiny Server deployment, scheduled updates, and system-level setup on our VM.

---

## 🚀 Shiny Server Setup

See [lab documentation](https://github.com/viktorpm/limlab_documentation/blob/main/docs/Setting%20up%20Shiny%20server.md) for full instructions. (Access required)

### Key location on the server:
```

/srv/shiny-server/shiny-performance-tracking

````

---

## 📦 System-wide R Package Installation

To install R packages for all users on `akramihpc1`, switch to superuser:

```bash
sudo su
R
# Then install packages as root
install.packages("shiny")
````

---

## 🔁 Scheduled Data Processing

Data updates and Git syncs are handled automatically via a daily cron job + systemd timer.

### Crontab Script: `/etc/cron.daily/update_shiny_app.sh`

```bash
#!/bin/bash

export HOME=/root/
DATE=$(date +"%Y-%m-%d_%H-%M")
exec > >(tee -a /mnt/ceph/_logs/shiny_log_$DATE.txt) 2>&1

cd /srv/shiny-server/shiny-performance-tracking
git config --global --add safe.directory /srv/shiny-server/shiny-performance-tracking
git checkout master
git pull
Rscript ExtractSaveData.R
git add .
git commit -m 'daily update of TRAINING.csv'
git push

systemctl restart shiny-server.service
```

---

## 🛠️ Systemd Configuration

* `/etc/systemd/system/update_shiny_app.service`
* `/etc/systemd/system/update_shiny_app.timer`

Use `systemctl` to manage:

```bash
sudo systemctl daemon-reload      # Reload config after edits
systemctl list-timers             # View active timers
```

---

## 🔑 SSH Key for Git Push (as root)

The cron job runs as `root`, so it needs a GitHub SSH key added for the root user.

See: [GitHub’s SSH setup guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## 🔗 Related Lab Docs

* [Setting up Shiny Server](https://github.com/viktorpm/limlab_documentation/blob/main/docs/Setting%20up%20Shiny%20server.md)
* [Scheduling & Logging Bash Scripts](https://github.com/viktorpm/limlab_documentation/blob/main/docs/Scheduling%20and%20logging%20bash%20scripts.md)
