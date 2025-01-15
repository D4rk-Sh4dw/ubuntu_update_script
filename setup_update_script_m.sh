#!/bin/bash

# Farben für die Ausgabe
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Pfad und GitHub-URL
SCRIPT_PATH="/usr/local/bin/ubuntu_update_m.sh"
GITHUB_URL="https://raw.githubusercontent.com/D4rk-Sh4dw/ubuntu_update_script/main/ubuntu_update.sh"

# Funktion: Cron-Zeit abfragen
function ask_cron_time() {
    echo "Bitte geben Sie die Cron-Zeitparameter an:"
    read -p "Minute (0-59): " MINUTE
    read -p "Stunde (0-23): " HOUR
    read -p "Tag des Monats (1-31, * für jeden Tag): " DAY
    read -p "Monat (1-12, * für jeden Monat): " MONTH
    read -p "Wochentag (0-7, wobei 0 und 7 für Sonntag stehen, * für jeden Tag): " WEEKDAY
}

# System bereinigen
echo -e "${GREEN}Führe apt clean aus, um den lokalen Paket-Cache zu bereinigen...${RESET}"
sudo apt clean -y

echo -e "${GREEN}Führe apt autoremove aus, um nicht mehr benötigte Pakete zu entfernen...${RESET}"
sudo apt autoremove -y

# Prüfen, ob cron installiert ist
echo -e "${GREEN}Prüfe, ob cron installiert ist...${RESET}"
if ! dpkg -l | grep -q "^ii.*cron"; then
    echo -e "${RED}cron ist nicht installiert. Installiere cron...${RESET}"
    sudo apt update
    sudo apt install -y cron
    echo -e "${GREEN}cron wurde erfolgreich installiert.${RESET}"
else
    echo -e "${GREEN}cron ist bereits installiert.${RESET}"
fi

# Sicherstellen, dass cron läuft
echo -e "${GREEN}Stelle sicher, dass der cron-Dienst läuft...${RESET}"
sudo systemctl start cron
sudo systemctl enable cron
echo -e "${GREEN}cron-Dienst ist gestartet und aktiviert.${RESET}"

# Skript herunterladen
echo -e "${GREEN}Herunterladen des Skripts von GitHub...${RESET}"
if wget -O "$SCRIPT_PATH" "$GITHUB_URL"; then
    echo -e "${GREEN}Skript erfolgreich heruntergeladen nach $SCRIPT_PATH${RESET}"
else
    echo -e "${RED}Fehler beim Herunterladen des Skripts!${RESET}"
    exit 1
fi

# Skript ausführbar machen
echo -e "${GREEN}Setze Berechtigungen...${RESET}"
chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}Skript ist ausführbar.${RESET}"

# Überprüfen, ob ein Cronjob bereits existiert
EXISTING_CRONTAB=$(crontab -l 2>/dev/null | grep "$SCRIPT_PATH")
if [[ -n "$EXISTING_CRONTAB" ]]; then
    echo -e "${GREEN}Ein bestehender Cronjob für das Skript wurde gefunden:${RESET}"
    echo "$EXISTING_CRONTAB"
    echo -e "${GREEN}Der bestehende Cronjob wird aktualisiert.${RESET}"

    # Bestehenden Cronjob entfernen
    (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH") | crontab -
else
    echo -e "${GREEN}Kein bestehender Cronjob für das Skript gefunden.${RESET}"
fi

# Cron-Zeit abfragen
ask_cron_time

# Neuen/aktualisierten Cronjob hinzufügen
CRON_JOB="$MINUTE $HOUR $DAY $MONTH $WEEKDAY $SCRIPT_PATH"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}Cronjob wurde hinzugefügt oder aktualisiert:${RESET}"
echo "$CRON_JOB"
