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
