#!/bin/bash
# functions/configuration_gps.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_gps() {
  echo "-> Configuration du GPS (UART déjà supposé activé)"
  echo
  echo "[INFO] Le GPS est activé via overlays."
  echo "[INFO] Aucun paramètre supplémentaire requis ici pour l’instant."

  pause_ou_touche
}
