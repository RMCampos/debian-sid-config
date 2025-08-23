#!/bin/bash

# Create backup directory
BACKUP_DIR="$HOME/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Create main log file
LOG_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).log"


echo "Starting backup at $(date)" | tee "$LOG_FILE"
echo "Backup directory: $BACKUP_DIR" | tee -a "$LOG_FILE"
echo "User: $(whoami)" | tee -a "$LOG_FILE"
echo "Home directory: $HOME" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

# Backup user data
echo "Backing up user data..." | tee -a "$LOG_FILE"
rsync -aHAXxv \
  --exclude='.cache/' \
  --exclude='.local/share/Trash/' \
  --exclude='.thumbnails/' \
  --exclude='.mozilla/firefox/*/Cache*' \
  --exclude='.mozilla/firefox/*/cache2/' \
  --exclude='.config/google-chrome/*/Cache*' \
  --exclude='.config/chromium/*/Cache*' \
  --exclude='.npm/_cacache/' \
  --exclude='.cache/pip/' \
  --exclude='.cache/yarn/' \
  --exclude='.m2/repository/' \
  --exclude='.gradle/caches/' \
  --exclude='.cargo/registry/' \
  --exclude='.composer/cache/' \
  --exclude='.cache/go-build/' \
  --exclude='node_modules/' \
  --exclude='.git/' \
  "$HOME/" "$BACKUP_DIR/home/" 2>&1 | tee -a "$LOG_FILE"

# Backup system configuration
echo "Backing up system configuration..." | tee -a "$LOG_FILE"
sudo rsync -aHAXxv /etc/ "$BACKUP_DIR/etc/" 2>&1 | tee -a "$LOG_FILE"

# Backup local installations
echo "Backing up local installations..." | tee -a "$LOG_FILE"
sudo rsync -aHAXxv /usr/local/ "$BACKUP_DIR/usr_local/" 2>&1 | tee -a "$LOG_FILE"
sudo rsync -aHAXxv /opt/ "$BACKUP_DIR/opt/" 2>&1 | tee -a "$LOG_FILE"

# Backup important var directories
echo "Backing up variable data..." | tee -a "$LOG_FILE"
sudo rsync -aHAXxv /var/lib/ "$BACKUP_DIR/var_lib/" 2>&1 | tee -a "$LOG_FILE"

# Create package lists
echo "Creating package lists..." | tee -a "$LOG_FILE"
dpkg --get-selections > "$BACKUP_DIR/installed-packages.txt" 2>&1 | tee -a "$LOG_FILE"
apt-mark showauto > "$BACKUP_DIR/auto-packages.txt" 2>&1 | tee -a "$LOG_FILE"
apt-mark showmanual > "$BACKUP_DIR/manual-packages.txt" 2>&1 | tee -a "$LOG_FILE"
sudo apt-key exportall > "$BACKUP_DIR/repositories.keys" 2>&1 | tee -a "$LOG_FILE"


# Backup installed snap/flatpak lists. Uncomment if applied
#echo "Creating snap/flatpak lists..." | tee -a "$LOG_FILE"
#snap list > "$BACKUP_DIR/snap-packages.txt" 2>&1 | tee -a "$LOG_FILE" || echo "Snap not installed" | tee -a "$LOG_FILE"
#flatpak list > "$BACKUP_DIR/flatpak-packages.txt" 2>&1 | tee -a "$LOG_FILE" || echo "Flatpak not installed" | tee -a "$LOG_FILE"

# Final summary
echo "----------------------------------------" | tee -a "$LOG_FILE"
echo "Backup completed at $(date)" | tee -a "$LOG_FILE"
echo "Backup size:" | tee -a "$LOG_FILE"
du -sh "$BACKUP_DIR" | tee -a "$LOG_FILE"
echo "Files backed up:" | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -type f | wc -l | tee -a "$LOG_FILE"

