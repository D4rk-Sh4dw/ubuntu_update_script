#!/bin/bash

# Sicherstellen, dass das Skript als root oder mit sudo-Rechten ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
  echo "Dieses Skript muss mit root-Rechten ausgeführt werden!" 
  exit 1
fi

# Backup erstellen
echo "Erstelle ein vollständiges Backup..."
mongodump --out /path/to/backup/$(date +%F)

# MongoDB stoppen
echo "Stoppe MongoDB..."
systemctl stop mongod

# Funktion zum Hinzufügen des Repositories
add_repo() {
  local version=$1
  local repo_url="deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$version multiverse"
  local key_url="https://www.mongodb.org/static/pgp/server-$version.asc"
  
  echo "Füge MongoDB $version Repository hinzu..."
  echo "$repo_url" | tee /etc/apt/sources.list.d/mongodb-org-$version.list
  curl -fsSL "$key_url" | tee /etc/apt/trusted.gpg.d/mongodb.asc
  apt-get update
}

# Funktion zum Entfernen des Repositories
remove_repo() {
  local version=$1
  echo "Entferne MongoDB $version Repository..."
  rm -f /etc/apt/sources.list.d/mongodb-org-$version.list
  apt-get update
}

# Upgrade auf MongoDB 3.6 - Initial
echo "Starte mit MongoDB 3.6..."
add_repo "3.6"
apt-get install -y mongodb-org=3.6.*
systemctl start mongod
echo "MongoDB 3.6 installiert und gestartet."

# Entferne MongoDB 3.6 Repository
remove_repo "3.6"

# Upgrade auf MongoDB 4.0
echo "Upgrade von MongoDB 3.6 auf 4.0..."
add_repo "4.0"
apt-get install -y mongodb-org=4.0.*
systemctl restart mongod
echo "MongoDB 4.0 installiert und neu gestartet."

# Entferne MongoDB 4.0 Repository
remove_repo "4.0"

# Upgrade auf MongoDB 4.2
echo "Upgrade von MongoDB 4.0 auf 4.2..."
add_repo "4.2"
apt-get install -y mongodb-org=4.2.*
systemctl restart mongod
echo "MongoDB 4.2 installiert und neu gestartet."

# Entferne MongoDB 4.2 Repository
remove_repo "4.2"

# Upgrade auf MongoDB 4.4
echo "Upgrade von MongoDB 4.2 auf 4.4..."
add_repo "4.4"
apt-get install -y mongodb-org=4.4.*
systemctl restart mongod
echo "MongoDB 4.4 installiert und neu gestartet."

# Entferne MongoDB 4.4 Repository
remove_repo "4.4"

# Upgrade auf MongoDB 5.0
echo "Upgrade von MongoDB 4.4 auf 5.0..."
add_repo "5.0"
apt-get install -y mongodb-org=5.0.*
systemctl restart mongod
echo "MongoDB 5.0 installiert und neu gestartet."

# Entferne MongoDB 5.0 Repository
remove_repo "5.0"

# Upgrade auf MongoDB 6.0
echo "Upgrade von MongoDB 5.0 auf 6.0..."
add_repo "6.0"
apt-get install -y mongodb-org=6.0.*
systemctl restart mongod
echo "MongoDB 6.0 installiert und neu gestartet."

# Entferne MongoDB 6.0 Repository
remove_repo "6.0"

# Upgrade auf MongoDB 7.0
echo "Upgrade von MongoDB 6.0 auf 7.0..."
add_repo "7.0"
apt-get install -y mongodb-org=7.0.*
systemctl restart mongod
echo "MongoDB 7.0 installiert und neu gestartet."

# Entferne MongoDB 7.0 Repository
remove_repo "7.0"

# Abschluss
echo "Das Upgrade auf MongoDB 7.0 ist abgeschlossen! Bitte überprüfe die Logs auf mögliche Fehler."
