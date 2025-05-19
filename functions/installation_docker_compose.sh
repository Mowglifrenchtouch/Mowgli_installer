#!/bin/bash
# functions/installation_docker_compose.sh
# Installation complète de Docker et Docker Compose

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

installer_docker() {
  echo "=== Installation de Docker et Docker Compose ==="

  # Vérifie si Docker est déjà présent
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "✅ Docker et Docker Compose sont déjà installés."
    if ! ask_update_if_exists "Souhaitez-vous forcer leur réinstallation ?"; then
      echo "⏭️  Installation ignorée."
      pause_ou_touche
      return
    fi
  fi

  echo "📦 Préparation de l'installation..."
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release

  # Ajout de la clé GPG Docker
  KEYRING="/etc/apt/keyrings/docker.gpg"
  if [ ! -f "$KEYRING" ]; then
    echo "🔐 Ajout de la clé GPG Docker..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
      | sudo gpg --dearmor -o "$KEYRING"
  else
    echo "✅ Clé GPG Docker déjà présente."
  fi

  # Ajout du dépôt Docker stable
  if ! grep -q "^deb .*docker" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
    echo "➕ Ajout du dépôt Docker stable..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=$KEYRING] \
      https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
    echo "✅ Dépôt Docker déjà présent."
  fi

  # Installation des paquets Docker
  echo "📥 Installation de Docker..."
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Ajout au groupe docker
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"

  echo
  echo "🐳 Docker version : $(docker --version)"
  echo "🐙 Docker Compose version : $(docker compose version)"
  echo "✅ Docker et Docker Compose installés avec succès."
  pause_ou_touche
}
