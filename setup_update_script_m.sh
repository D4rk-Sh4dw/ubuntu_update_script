#!/bin/bash

LOG_FILE="/var/log/update_script.log"

# Logging Funktion mit Konsolenausgabe
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Setze DEBIAN_FRONTEND, um Interaktivität zu deaktivieren
export DEBIAN_FRONTEND=noninteractive

# Überprüfen und Beheben von dpkg-Problemen
log "Überprüfen des dpkg-Status..."
if ! sudo dpkg --audit; then
    log "Probleme mit dpkg festgestellt. Führe 'dpkg --configure -a' aus..."
    sudo dpkg --configure -a 2>&1 | tee -a "$LOG_FILE"
    if [ $? -ne 0 ]; then
        log "Fehler beim Ausführen von 'dpkg --configure -a'. Lösche Lock-Dateien und versuche erneut..."
        sudo rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
        sudo dpkg --configure -a 2>&1 | tee -a "$LOG_FILE"
        if [ $? -ne 0 ]; then
            log "Fehler bleibt bestehen. Bitte manuell eingreifen."
            exit 1
        fi
    fi
else
    log "dpkg-Status ist in Ordnung."
fi

# System reinigen (Autoremove, Clean)
log "Starte Systemreinigung mit apt autoremove und apt clean..."
sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
sudo apt clean 2>&1 | tee -a "$LOG_FILE"

# Entfernen der älteren MongoDB-Versionen aus den Repositories
log "Entferne ältere MongoDB-Repositories..."
for VERSION in 3.6 4.0 4.2 4.4; do
    if [ -f /etc/apt/sources.list.d/mongodb-org-$VERSION.list ]; then
        sudo rm /etc/apt/sources.list.d/mongodb-org-$VERSION.list
        log "Entferntes Repository für MongoDB $VERSION."
    fi
done

# Ubuntu-Version ermitteln
UBUNTU_VERSION=$(lsb_release -c | awk '{print $2}')
log "Ermittelte Ubuntu-Version: $UBUNTU_VERSION"

# Repository entsprechend der Ubuntu-Version anpassen
case "$UBUNTU_VERSION" in
    "focal" | "jammy")
        UBUNTU_CODENAME="$UBUNTU_VERSION"
        ;;
    *)
        log "Nicht unterstützte Ubuntu-Version: $UBUNTU_VERSION. Verwende 'focal' als Standard."
        UBUNTU_CODENAME="focal"
        ;;
esac

# Füge MongoDB 7.0 Repository hinzu
log "Füge MongoDB 7.0 Repository für $UBUNTU_CODENAME hinzu..."
sudo apt-get install -y gnupg curl 2>&1 | tee -a "$LOG_FILE"
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor 2>&1 | tee -a "$LOG_FILE"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $UBUNTU_CODENAME/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list 2>&1 | tee -a "$LOG_FILE"

# Führe apt update aus, um die neuen Repositories zu laden
log "Aktualisiere apt Paketlisten..."
sudo apt-get update --allow-releaseinfo-change 2>&1 | tee -a "$LOG_FILE"

# Automatische Konfiguration für Unifi Backup-Frage setzen
log "Setze automatische Konfiguration für Unifi..."
echo "unifi unifi/has_backup boolean true" | sudo debconf-set-selections

# Upgrade der Pakete
log "Führe apt upgrade aus..."
sudo apt upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>&1 | tee -a "$LOG_FILE"

# Optional: MongoDB 7.0 installieren (falls nicht bereits vorhanden)
log "Prüfe auf MongoDB 7.0 Installation..."
if ! dpkg -l | grep -q "mongodb-org"; then
    log "Installiere MongoDB 7.0..."
    sudo apt-get install -y mongodb-org 2>&1 | tee -a "$LOG_FILE"
else
    log "MongoDB 7.0 ist bereits installiert."
fi

# Unifi-Upgrade prüfen und erzwingen
log "Prüfe auf Unifi-Updates..."
sudo apt-get install --only-upgrade -y unifi -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>&1 | tee -a "$LOG_FILE"

log "Update-Skript abgeschlossen!"
