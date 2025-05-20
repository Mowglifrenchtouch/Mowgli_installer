#!/bin/bash
# install.sh – Script d'installation rapide du Mowgli Installer

INSTALL_DIR="$HOME/Mowgli_installer"
REPO_URL="https://github.com/Mowglifrenchtouch/Mowgli_installer.git"

echo "🚀 Installation du Mowgli Installer..."

# Vérifie si le dossier existe déjà
if [ -d "$INSTALL_DIR" ]; then
  echo "📁 Le dossier $INSTALL_DIR existe déjà."
  read -p "Souhaitez-vous le supprimer et refaire une installation propre ? (o/N) : " confirm
  if [[ "$confirm" =~ ^[OoYy]$ ]]; then
    rm -rf "$INSTALL_DIR"
  else
    echo "❌ Installation annulée."
    exit 1
  fi
fi

# Clone le dépôt
git clone https://github.com/Mowglifrenchtouch/Mowgli_installer.git "$INSTALL_DIR"

# Change vers le répertoire du projet
cd "$INSTALL_DIR" || {
  echo "❌ Erreur : impossible d'accéder au dossier $INSTALL_DIR"
  exit 1
}

# Lance le script principal
exec ./install-mowgli.sh