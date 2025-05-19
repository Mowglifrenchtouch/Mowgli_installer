#!/bin/bash
# functions/docker.sh
# Installation complète de Docker et Docker Compose

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

installer_docker() {
  echo "=== Installation de Docker et Docker Compose ==="

  # Vérifie si docker est déjà présent
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "✅ Docker et Docker Compose sont déjà installés."
    if ! ask_update_if_exists "Souhaitez-vous forcer leur réinstallation ?"; then
      echo "⏭️  Installation ignorée."
      pause_ou_touche
      return
    fi
  fi

  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release

  # Ajout clé GPG si absente
  KEYRING="/etc/apt/keyrings/docker.gpg"
  if [ ! -f "$KEYRING" ]; then
    echo "🔐 Ajout de la clé GPG Docker..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
      | sudo gpg --dearmor -o "$KEYRING"
  else
    echo "✅ Clé GPG Docker déjà présente."
  fi

  # Ajout du dépôt stable Docker si absent
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

  # Installation
  echo "📦 Installation des paquets Docker..."
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Ajout utilisateur au groupe docker
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"

  echo "🐳 Docker version : $(docker --version)"
  echo "🐙 Docker Compose version : $(docker compose version)"
  echo "[OK] Docker & Compose installés."

  pause_ou_touche
}
