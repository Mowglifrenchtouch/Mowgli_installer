#!/bin/bash
# functions/configuration_gps_udev.sh
# Active l’overlay UART4 et configure la règle UDEV pour le GPS + carte mère Mowgli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_gps_udev() {
  local config_file="/boot/firmware/config.txt"
  local overlay="dtoverlay=uart4"
  local udev_file="/etc/udev/rules.d/50-mowgli.rules"

  echo "=== Configuration GPS + UART4 ==="
  echo "📄 Modifie : $config_file + $udev_file"
  echo

  # Sauvegarde du fichier firmware
  sauvegarder_fichier "$config_file"

  if ! grep -q "^$overlay" "$config_file"; then
    echo "$overlay" | sudo tee -a "$config_file" > /dev/null
    echo "✅ Overlay ajouté dans config.txt"
  else
    echo "ℹ️  Overlay UART4 déjà présent"
  fi

  echo
  echo "=== Ajout des règles UDEV ==="

  # Ajoute toujours la règle pour la carte mère Mowgli
  if ! grep -q 'product}=="Mowgli"' "$udev_file" 2>/dev/null; then
    echo 'SUBSYSTEM=="tty", ATTRS{product}=="Mowgli", SYMLINK+="mowgli"' | sudo tee -a "$udev_file" > /dev/null
    echo "✅ Règle UDEV ajoutée pour la carte mère Mowgli"
  else
    echo "✅ Règle UDEV pour la carte mère déjà présente"
  fi

  echo
  echo "=== Détection GPS USB ==="
  echo "📡 Recherche des périphériques GPS USB via lsusb..."

  gps_found=0
echo

lsusb | while read -r line; do
 if echo "$line" | grep -Eiq "u[-]?blox|ch340|gps|rtk|cp210|ftdi"; then
    echo "🔍 Périphérique USB détecté : $line"
    id=$(echo "$line" | grep -oP 'ID \K[0-9a-f]{4}:[0-9a-f]{4}')
    vendor_id="${id%%:*}"
    product_id="${id##*:}"
    rule="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$vendor_id\", ATTRS{idProduct}==\"$product_id\", SYMLINK+=\"gps\""

    if ! grep -q "$rule" "$udev_file" 2>/dev/null; then
      echo "$rule" | sudo tee -a "$udev_file" > /dev/null
      echo "✅ Règle UDEV ajoutée pour GPS ($vendor_id:$product_id)"
    else
      echo "ℹ️  Règle UDEV déjà existante pour GPS ($vendor_id:$product_id)"
    fi

    gps_found=1
  fi
done

if [ "$gps_found" -eq 0 ]; then
  echo "❌ Aucun périphérique GPS connu détecté via lsusb."
  echo "ℹ️  Branchez votre module GPS USB puis relancez cette option."
fi


  echo
  echo "🔄 Redémarrage des règles UDEV..."
  sudo udevadm control --reload-rules && sudo udevadm trigger
  echo "✅ UDEV rechargé."

  pause_ou_touche
}
