# Server & Scheduling Setup Notes

These notes are for configuring the Shiny Server deployment, scheduled updates, and system-level setup on our VM.

## Shiny Server Setup

See [lab documentation](https://dashboard.lim.bio/docs/setting_up_shiny_server/) for full instructions. (Access required)

### Key location on the server

```bash
/srv/shiny-server/shiny-performance-tracking
```

## System-wide R Package Installation

To install R packages for all users on `akramihpc1`, switch to superuser:

```bash
sudo -i
R
# Then install packages as root
install.packages("shiny")
```

## Scheduled Data Processing

Data updates and Git syncs are handled automatically via a daily cron job + systemd timer.

### Crontab Script: `/etc/cron.daily/update_shiny_app.sh`

```bash
#!/bin/bash

# Fail on error, unset variable, or pipe failure
set -euo pipefail

# For cron jobs, explicitly set $HOME
export HOME=/root/

# Timestamp for log file name
DATE=$(date +"%Y-%m-%d_%H-%M")
LOG_FILE="/mnt/ceph/_logs/shiny_log_$DATE.txt"

# Function for logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function for error handling
handle_error() {
    log "ERROR: An error occurred in the script at line $1"
    log "Last command exit code: $2"
    exit 1
}

# Set up error handling
trap 'handle_error ${LINENO} $?' ERR

# Start logging
log "===== SCRIPT START ====="

# Check if required directories exist
if [ ! -d "/srv/shiny-server/shiny-performance-tracking" ]; then
    log "ERROR: Application directory not found"
    exit 1
fi

if [ ! -d "/mnt/ceph/_logs" ]; then
    log "ERROR: Log directory not found"
    exit 1
fi

# Change to application directory
cd /srv/shiny-server/shiny-performance-tracking || {
    log "ERROR: Failed to change to application directory"
    exit 1
}

# Ensure git is configured for this directory
git config --global --add safe.directory /srv/shiny-server/shiny-performance-tracking

# Git operations with error checking
log "Checking out master branch..."
if ! git checkout master; then
    log "ERROR: Failed to checkout master branch"
    exit 1
fi

log "Pulling latest changes..."
if ! git pull; then
    log "ERROR: Failed to pull latest changes"
    exit 1
fi

# Run R script with error checking
log "Running R script..."
if ! Rscript ExtractSaveData.R; then
    log "ERROR: R script failed"
    exit 1
fi

# Check for changes and handle git operations
log "Checking for changes..."
if ! git diff --quiet; then
    log "Changes detected. Committing and pushing..."
    if ! git add .; then
        log "ERROR: Failed to add changes"
        exit 1
    fi

    if ! git commit -m "daily update of TRAINING.csv"; then
        log "ERROR: Failed to commit changes"
        exit 1
    fi

    if ! git push; then
        log "ERROR: Failed to push changes"
        exit 1
    fi

    log "Restarting shiny-server..."
    if ! systemctl restart shiny-server.service; then
        log "ERROR: Failed to restart shiny-server"
        exit 1
    fi
else
    log "No changes to commit. Skipping push and restart."
fi

log "===== SCRIPT END ====="

# Exit successfully
exit 0
```

## Systemd Configuration

- `/etc/systemd/system/update_shiny_app.service`
- `/etc/systemd/system/update_shiny_app.timer`

Use `systemctl` to manage:

```bash
sudo systemctl daemon-reload      # Reload config after edits
systemctl list-timers             # View active timers
```

## SSH Key for Git Push (as root)

The cron job runs as `root`, so it needs a GitHub SSH key added for the root user.

See: [GitHub’s SSH setup guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

## Related Lab Docs

- [Setting up Shiny Server](https://github.com/LIMLabSWC/limlab_documentation/blob/main/docs/setting_up_shiny_server.md)
- [Scheduling & Logging Bash Scripts](https://github.com/LIMLabSWC/limlab_documentation/blob/main/docs/scheduling_and_logging_bash_scripts.md)

