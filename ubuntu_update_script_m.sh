#!/bin/bash

LOG_FILE="/var/log/update_script.log"

# Logging Funktion mit Konsolenausgabe
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Überprüfen und Beheben von dpkg-Problemen
log "Überprüfen des dpkg-Status..."
if sudo dpkg --audit; then
    log "dpkg-Status ist in Ordnung."
else
    log "Probleme mit dpkg festgestellt. Führe 'dpkg --configure -a' aus..."
    sudo dpkg --configure -a 2>&1 | tee -a "$LOG_FILE"
    if [ $? -ne 0 ]; then
        log "Fehler beim Ausführen von 'dpkg --configure -a'. Bitte manuell beheben."
        exit 1
    fi
fi

# System reinigen (Autoremove, Clean)
log "Starte Systemreinigung mit apt autoremove und apt clean..."
sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
sudo apt clean 2>&1 | tee -a "$LOG_FILE"

# Entfernen der älteren MongoDB-Versionen aus den Repositories
log "Entferne MongoDB-Versionen älter als 8 aus den Repositories..."

for version in 3.6 4.0 4.2 4.4; do
    if [ -f "/etc/apt/sources.list.d/mongodb-org-${version}.list" ]; then
        sudo rm "/etc/apt/sources.list.d/mongodb-org-${version}.list"
        log "Entferntes Repository für MongoDB ${version}."
    fi
done

# Ubuntu-Version ermitteln
UBUNTU_VERSION=$(lsb_release -c | awk '{print $2}')
log "Ubuntu Version: $UBUNTU_VERSION"

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

# Füge MongoDB 7.0 Repository für die entsprechende Ubuntu-Version hinzu
log "Füge MongoDB 7.0 Repository für $UBUNTU_CODENAME hinzu..."

log "Installiere notwendige Pakete: gnupg, curl..."
sudo apt-get install -y gnupg curl 2>&1 | tee -a "$LOG_FILE"

log "Lade MongoDB 7.0 GPG-Schlüssel herunter..."
sudo curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor --yes 2>&1 | tee -a "$LOG_FILE"

log "Füge das MongoDB 7.0 Repository hinzu..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $UBUNTU_CODENAME/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list 2>&1 | tee -a "$LOG_FILE"

# Aktualisiere apt Paketlisten
log "Aktualisiere apt Paketlisten mit --allow-releaseinfo-change..."
sudo apt-get update --allow-releaseinfo-change 2>&1 | tee -a "$LOG_FILE"

log "Führe apt update aus..."
sudo apt update -y 2>&1 | tee -a "$LOG_FILE"

log "Führe apt upgrade aus..."
sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"

log "Update-Skript abgeschlossen!"
