#!/bin/bash
# install.sh – Script d'installation rapide du Mowgli Installer

INSTALL_DIR="$HOME/Mowgli_installer"
REPO_URL="https://github.com/Mowglifrenchtouch/Mowgli_installer.git"

RESET=0

# Analyse les arguments
for arg in "$@"; do
  case $arg in
    --reset|-r)
      RESET=1
      ;;
  esac
done

echo "🚀 Installation du Mowgli Installer..."

# Vérifie si le dossier existe déjà
if [ -d "$INSTALL_DIR" ]; then
  if [ "$RESET" -eq 1 ]; then
    echo "🔁 Réinstallation forcée (option --reset)"
    rm -rf "$INSTALL_DIR"
  else
    echo "📁 Le dossier $INSTALL_DIR existe déjà."
    read -p "Souhaitez-vous le supprimer et refaire une installation propre ? (o/N) : " confirm
    if [[ "$confirm" =~ ^[OoYy]$ ]]; then
      rm -rf "$INSTALL_DIR"
    else
      echo "📂 Lancement du script existant..."
      cd "$INSTALL_DIR" || {
        echo "❌ Erreur : impossible d'accéder au dossier $INSTALL_DIR"
        exit 1
      }
      exec ./install-mowgli.sh
    fi
  fi
fi

# Clone le dépôt
git clone "$REPO_URL" "$INSTALL_DIR"

# Change vers le répertoire du projet
cd "$INSTALL_DIR" || {
  echo "❌ Erreur : impossible d'accéder au dossier $INSTALL_DIR"
  exit 1
}

# Lance le script principal
exec ./install-mowgli.sh