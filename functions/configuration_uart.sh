#!/bin/bash
# functions/configuration_uart.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_uart() {
  local config_file="/boot/firmware/config.txt"
  sauvegarder_fichier "$config_file"

  echo "-> Configuration UART..."

  if ! grep -q "enable_uart=1" "$config_file"; then
    echo "enable_uart=1" | sudo tee -a "$config_file" > /dev/null
    echo "[OK] UART activé dans $config_file"
  else
    echo "[INFO] UART déjà activé."
  fi

  # Activation des overlays UART 2 à 5
  for uart in uart2 uart3 uart4 uart5; do
    sudo sed -i "/dtoverlay=${uart}/d" "$config_file"
    echo "dtoverlay=${uart}" | sudo tee -a "$config_file" > /dev/null
    echo ">> Overlay ${uart} ajouté"
  done

  pause_ou_touche
}
