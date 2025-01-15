#!/bin/bash

# Farben für die Ausgabe
GREEN="\033[0;32m"
RESET="\033[0m"

# Pfad und GitHub-URL
SCRIPT_PATH="/usr/local/bin/ubuntu_update.sh"
GITHUB_URL="https://raw.githubusercontent.com/D4rk-Sh4dw/ubuntu_update_script/refs/heads/main/ubuntu_update.sh"

# Funktion: Cron-Zeit abfragen
function ask_cron_time() {
    echo "Bitte geben Sie die Cron-Zeitparameter an:"
    read -p "Minute (0-59): " MINUTE
    read -p "Stunde (0-23): " HOUR
    read -p "Tag des Monats (1-31, * für jeden Tag): " DAY
    read -p "Monat (1-12, * für jeden Monat): " MONTH
    read -p "Wochentag (0-7, wobei 0 und 7 für Sonntag stehen, * für jeden Tag): " WEEKDAY
}

# Skript herunterladen
echo -e "${GREEN}Herunterladen des Skripts von GitHub...${RESET}"
if curl -o "$SCRIPT_PATH" -L "$GITHUB_URL"; then
    echo -e "${GREEN}Skript erfolgreich heruntergeladen nach $SCRIPT_PATH${RESET}"
else
    echo -e "${RED}Fehler beim Herunterladen des Skripts!${RESET}"
    exit 1
fi

# Skript ausführbar machen
echo -e "${GREEN}Setze Berechtigungen...${RESET}"
chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}Skript ist ausführbar.${RESET}"

# Cron-Zeit abfragen
ask_cron_time

# Cronjob hinzufügen
CRON_JOB="$MINUTE $HOUR $DAY $MONTH $WEEKDAY $SCRIPT_PATH"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}Cronjob wurde hinzugefügt:${RESET}"
echo "$CRON_JOB"
