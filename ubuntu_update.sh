#!/bin/bash

# Log-Datei festlegen
LOG_FILE="/var/log/ubuntu_update.log"

# Startmeldung in die Log-Datei schreiben
echo "---------------------------" >> "$LOG_FILE"
echo "$(date): Update gestartet" >> "$LOG_FILE"

# Updates durchführen
apt update >> "$LOG_FILE" 2>&1
apt upgrade -y >> "$LOG_FILE" 2>&1

# Überprüfen, ob ein Neustart erforderlich ist
if [ -f /var/run/reboot-required ]; then
    echo "$(date): Neustart erforderlich. System wird neu gestartet." >> "$LOG_FILE"
    echo "---------------------------" >> "$LOG_FILE"
    # Neustart durchführen
    reboot
else
    echo "$(date): Kein Neustart erforderlich. Update abgeschlossen." >> "$LOG_FILE"
    echo "---------------------------" >> "$LOG_FILE"
fi
