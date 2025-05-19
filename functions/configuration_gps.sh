#!/bin/bash
# functions/configuration_gps.sh
# Active l’overlay UART4 dans /boot/firmware/config.txt pour le GPS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_gps() {
  local config_file="/boot/firmware/config.txt"
  local overlay="dtoverlay=uart4"

  echo "=== Configuration du GPS (activation de UART4) ==="
  echo "📄 Fichier cible : $config_file"
  echo

  # Sauvegarde avant modification
  sauvegarder_fichier "$config_file"

  if grep -q "^$overlay" "$config_file"; then
    echo "✅ L’overlay '$overlay' est déjà présent."
    if ask_update_if_exists "Souhaitez-vous le réécrire ?"; then
      sudo sed -i "/^$overlay/d" "$config_file"
      echo "$overlay" | sudo tee -a "$config_file" > /dev/null
      echo "🔁 Overlay UART4 réécrit dans $config_file"
    else
      echo "⏭️  Aucun changement effectué."
    fi
  else
    echo "$overlay" | sudo tee -a "$config_file" > /dev/null
    echo "✅ Overlay UART4 ajouté dans $config_file"
  fi

  pause_ou_touche
}
