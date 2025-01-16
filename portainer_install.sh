#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
NC='\033[0m' # Keine Farbe

echo -e "${GREEN}Portainer IPvlan-Installationsskript gestartet...${NC}"

# 1. Docker installieren (falls nicht vorhanden)
if ! [ -x "$(command -v docker)" ]; then
  echo -e "${GREEN}Docker wird installiert...${NC}"
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce
  echo -e "${GREEN}Docker erfolgreich installiert.${NC}"
else
  echo -e "${GREEN}Docker ist bereits installiert.${NC}"
fi

# 2. Docker-Compose installieren (optional, falls benötigt)
if ! [ -x "$(command -v docker-compose)" ]; then
  echo -e "${GREEN}Docker Compose wird installiert...${NC}"
  curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo -e "${GREEN}Docker Compose erfolgreich installiert.${NC}"
else
  echo -e "${GREEN}Docker Compose ist bereits installiert.${NC}"
fi

# 3. Docker-Volume für Portainer erstellen
echo -e "${GREEN}Docker-Volume für Portainer wird erstellt...${NC}"
docker volume create portainer_data

# 4. IPvlan-Netzwerk erstellen
echo -e "${GREEN}IPvlan-Netzwerk wird erstellt...${NC}"
read -p "Geben Sie das Subnetz (z. B. 192.168.1.0/24): " SUBNET
read -p "Geben Sie das Gateway (z. B. 192.168.1.1): " GATEWAY
read -p "Geben Sie das Parent-Interface an (z. B. eth0): " PARENT_INTERFACE

docker network create -d ipvlan \
  --subnet=$SUBNET \
  --gateway=$GATEWAY \
  -o parent=$PARENT_INTERFACE \
  ipvlan_net

echo -e "${GREEN}IPvlan-Netzwerk erfolgreich erstellt.${NC}"

# 5. Portainer-Container starten
echo -e "${GREEN}Portainer wird gestartet...${NC}"
docker run -d \
  --name portainer \
  --restart=always \
  --network ipvlan_net \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo -e "${GREEN}Portainer wurde erfolgreich installiert und ist unter https://<IP-Adresse>:9443 erreichbar.${NC}"

# Hinweis für den Benutzer
echo -e "${GREEN}Öffnen Sie Ihren Browser und gehen Sie zu https://<Ihre-IP>:9443, um die Weboberfläche zu verwenden.${NC}"
echo -e "${GREEN}Nutzen Sie das IPvlan-Netzwerk 'ipvlan_net' für Ihre Container.${NC}"
