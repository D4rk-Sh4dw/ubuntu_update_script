#!/bin/bash

LOG_FILE="/var/log/update_script.log"

# Logging Funktion
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# System reinigen (Autoremove, Clean)
log "Starte Systemreinigung mit apt autoremove und apt clean..."
sudo apt autoremove -y >> "$LOG_FILE" 2>&1
sudo apt clean >> "$LOG_FILE" 2>&1

# Entfernen der älteren MongoDB-Versionen aus den Repositories
log "Entferne MongoDB-Versionen älter als 8 aus den Repositories..."

# Wenn eine ältere Version (z. B. 3.6 oder 4.x) in der Repository-Liste existiert, entfernen
if [ -f /etc/apt/sources.list.d/mongodb-org-3.6.list ]; then
    sudo rm /etc/apt/sources.list.d/mongodb-org-3.6.list
    log "Entferntes Repository für MongoDB 3.6."
fi

if [ -f /etc/apt/sources.list.d/mongodb-org-4.0.list ]; then
    sudo rm /etc/apt/sources.list.d/mongodb-org-4.0.list
    log "Entferntes Repository für MongoDB 4.0."
fi

if [ -f /etc/apt/sources.list.d/mongodb-org-4.2.list ]; then
    sudo rm /etc/apt/sources.list.d/mongodb-org-4.2.list
    log "Entferntes Repository für MongoDB 4.2."
fi

if [ -f /etc/apt/sources.list.d/mongodb-org-4.4.list ]; then
    sudo rm /etc/apt/sources.list.d/mongodb-org-4.4.list
    log "Entferntes Repository für MongoDB 4.4."
fi

# Ubuntu-Version ermitteln
UBUNTU_VERSION=$(lsb_release -c | awk '{print $2}')

# Repository entsprechend der Ubuntu-Version anpassen
log "Ubuntu Version: $UBUNTU_VERSION"

# Überprüfen, ob die Version unterstützt wird
case "$UBUNTU_VERSION" in
    "focal")
        UBUNTU_CODENAME="focal"
        ;;
    "jammy")
        UBUNTU_CODENAME="jammy"
        ;;
    *)
        log "Nicht unterstützte Ubuntu-Version: $UBUNTU_VERSION. Verwende die Standardversion 'focal'."
        UBUNTU_CODENAME="focal"
        ;;
esac

# Füge MongoDB 8.0 Repository für die entsprechende Ubuntu-Version hinzu
log "Füge MongoDB 8.0 Repository für $UBUNTU_CODENAME hinzu..."

# Installiere gnupg und curl, falls nicht installiert
sudo apt-get install -y gnupg curl >> "$LOG_FILE" 2>&1

# Lade den MongoDB 8.0 GPG-Schlüssel herunter und füge ihn dem Keyring hinzu
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor >> "$LOG_FILE" 2>&1

# Füge das MongoDB 8.0 Repository hinzu
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $UBUNTU_CODENAME/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list >> "$LOG_FILE" 2>&1

# Führe apt update aus, um die neuen Repositories zu laden
log "Aktualisiere apt Paketlisten..."
sudo apt-get update >> "$LOG_FILE" 2>&1

# Aktualisierung der Paketlisten und Upgrade der Pakete
log "Führe apt update aus..."
sudo apt update -y >> "$LOG_FILE" 2>&1

log "Führe apt upgrade aus..."
sudo apt upgrade -y >> "$LOG_FILE" 2>&1

# Optional: MongoDB 8.0 installieren (falls gewünscht)
# log "Installiere MongoDB 8.0..."
# sudo apt-get install -y mongodb-org >> "$LOG_FILE" 2>&1

log "Update-Skript abgeschlossen!"
