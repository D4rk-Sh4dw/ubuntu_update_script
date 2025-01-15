#!/bin/bash

# Farben für die Ausgabe
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Log-Datei definieren
LOG_FILE="/var/log/ubuntu_update.log"

# Funktion zum Loggen von Nachrichten
function log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Loggen des Beginns des Skriptlaufs
log_message "${GREEN}Starte das Update-Skript...${RESET}"

# System bereinigen
log_message "${GREEN}Führe apt clean aus, um den lokalen Paket-Cache zu bereinigen...${RESET}"
if sudo apt clean -y >> "$LOG_FILE" 2>&1; then
    log_message "${GREEN}apt clean abgeschlossen.${RESET}"
else
    log_message "${RED}Fehler bei apt clean.${RESET}"
    exit 1
fi

log_message "${GREEN}Führe apt autoremove aus, um nicht mehr benötigte Pakete zu entfernen...${RESET}"
if sudo apt autoremove -y >> "$LOG_FILE" 2>&1; then
    log_message "${GREEN}apt autoremove abgeschlossen.${RESET}"
else
    log_message "${RED}Fehler bei apt autoremove.${RESET}"
    exit 1
fi

# Update und Upgrade mit erzwungenen Antworten
log_message "${GREEN}Führe apt update aus...${RESET}"
if sudo apt update -y >> "$LOG_FILE" 2>&1; then
    log_message "${GREEN}apt update abgeschlossen.${RESET}"
else
    log_message "${RED}Fehler bei apt update.${RESET}"
    exit 1
fi

log_message "${GREEN}Führe apt upgrade aus...${RESET}"
if sudo apt upgrade -y >> "$LOG_FILE" 2>&1; then
    log_message "${GREEN}apt upgrade abgeschlossen.${RESET}"
else
    log_message "${RED}Fehler bei apt upgrade.${RESET}"
    exit 1
fi

log_message "${GREEN}Updates erfolgreich abgeschlossen.${RESET}"

# Optional: Neustart des Systems
log_message "${GREEN}Starte das System neu...${RESET}"
if sudo reboot >> "$LOG_FILE" 2>&1; then
    log_message "${GREEN}System wird neu gestartet.${RESET}"
else
    log_message "${RED}Fehler beim Neustarten des Systems.${RESET}"
    exit 1
fi
