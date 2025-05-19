#!/bin/bash
# functions/configuration_gps.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_gps() {
  local config_file="/boot/firmware/config.txt"
  local overlay="dtoverlay=uart4"

  echo "=== Configuration GPS (UART4) ==="
  sauvegarder_fichier "$config_file"

  if grep -q "^$overlay" "$config_file"; then
    echo "✅ $overlay déjà présent dans $config_file"
    if ask_update_if_exists "Souhaitez-vous forcer la réécriture de $overlay ?"; then
      sudo sed -i "/^$overlay/d" "$config_file"
      echo "$overlay" | sudo tee -a "$config_file" > /dev/null
      echo "🔁 Overlay UART4 réécrit."
    else
      echo "⏭️  Saut de la configuration GPS."
    fi
  else
    echo "$overlay" | sudo tee -a "$config_file" > /dev/null
    echo "✅ Overlay UART4 ajouté dans $config_file"
  fi

  pause_ou_touche
}

