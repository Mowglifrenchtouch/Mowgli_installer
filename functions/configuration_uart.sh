#!/bin/bash
# functions/configuration_uart.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_uart() {
  local config_file="/boot/firmware/config.txt"
  sauvegarder_fichier "$config_file"

  echo "=== Configuration UART ==="

  # Vérifie si UART est déjà activé
  if grep -q "^enable_uart=1" "$config_file"; then
    echo "✅ UART déjà activé dans $config_file"
    if ! ask_update_if_exists "Souhaitez-vous forcer la réécriture de enable_uart=1 ?"; then
      echo "⏭️  Saut de la configuration UART."
    else
      sudo sed -i 's/^enable_uart=.*/enable_uart=1/' "$config_file"
      echo "[OK] Ligne enable_uart mise à jour."
    fi
  else
    if grep -q "^enable_uart=" "$config_file"; then
      sudo sed -i 's/^enable_uart=.*/enable_uart=1/' "$config_file"
    else
      echo "enable_uart=1" | sudo tee -a "$config_file" > /dev/null
    fi
    echo "[OK] enable_uart=1 ajouté à $config_file"
  fi

  # Activation des overlays UART 2 à 5
  for uart in uart2 uart3 uart4 uart5; do
    if grep -q "^dtoverlay=${uart}" "$config_file"; then
      echo "[INFO] dtoverlay=${uart} déjà présent."
    else
      echo "dtoverlay=${uart}" | sudo tee -a "$config_file" > /dev/null
      echo ">> Overlay ${uart} ajouté"
    fi
  done

  pause_ou_touche
}
