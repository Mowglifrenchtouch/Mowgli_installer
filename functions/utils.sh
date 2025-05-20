#!/bin/bash
# functions/utils.sh
# Fonctions utilitaires globales

pause_ou_touche() {
  echo
  echo "[INFO] Appuyez sur une touche pour continuer ou attendez 10 secondes..."
  read -t 10 -n 1 -s || true
  echo
}

ask_update_if_exists() {
  local message="$1"
  echo -n "$message (y/N) : "
  read -r answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

sauvegarder_fichier() {
  local fichier="$1"
  local backup_dir="$HOME/Mowgli_installer/backups"

  if [ -f "$fichier" ]; then
    mkdir -p "$backup_dir"
    local base
    base=$(basename "$fichier")
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local dest="$backup_dir/${base}.${timestamp}.bak"

    cp "$fichier" "$dest"
    echo "[INFO] Sauvegarde créée : $dest"
  else
    echo "[WARN] Aucun fichier à sauvegarder : $fichier introuvable"
  fi
}
