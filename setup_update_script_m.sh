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

# Aktualisiere apt Paketlisten
log "Aktualisiere apt Paketlisten..."
sudo apt update --allow-releaseinfo-change -o Dpkg::Options::="--force-confold" -y 2>&1 | tee -a "$LOG_FILE"

# Upgrade der Pakete, ohne Interaktivität
log "Führe apt upgrade aus..."
sudo apt upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>&1 | tee -a "$LOG_FILE"

# Optional: Upgrade von Unifi-Paketen ohne Interaktivität
log "Prüfe auf Unifi-Updates..."
sudo apt-get install --only-upgrade -y unifi -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" 2>&1 | tee -a "$LOG_FILE"

log "Update-Skript abgeschlossen!"
