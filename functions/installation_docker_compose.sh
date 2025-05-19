#!/bin/bash
# functions/docker.sh
# Fonctions d'installation de Docker et Docker Compose

installer_docker() {
  echo "-> Installation de Docker et Docker Compose..."
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release

  # Ajout de la clé GPG officielle
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  # Ajout du dépôt Docker stable
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Installation des paquets Docker
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Ajout de l'utilisateur courant au groupe docker
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"

  echo "Docker version : $(docker --version)"
  echo "Docker Compose version : $(docker compose version)"
  echo "[OK] Docker & Compose installés."
}
