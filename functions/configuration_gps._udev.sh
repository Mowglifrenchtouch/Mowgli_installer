#!/bin/bash
# Active UART4 et ajoute des règles UDEV pour GPS + carte Mowgli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_gps_udev() {
  local config_file="/boot/firmware/config.txt"
  local overlay="dtoverlay=uart4"
  local udev_file="/etc/udev/rules.d/50-mowgli.rules"
  local conf_file="$SCRIPT_DIR/gps_models.conf"

  echo "=== Configuration GPS + UART4 ==="
  echo "📄 Modifie : $config_file + $udev_file"
  echo

  # 📦 Active UART4 si manquant
  sauvegarder_fichier "$config_file"
  if ! grep -q "^$overlay" "$config_file"; then
    echo "$overlay" | sudo tee -a "$config_file" > /dev/null
    echo "✅ Overlay ajouté dans config.txt"
  else
    echo "ℹ️  Overlay UART4 déjà présent"
  fi

  echo
  echo "=== Ajout des règles UDEV ==="

  # 🧠 Règle obligatoire pour carte Mowgli
  if ! grep -q 'product}=="Mowgli"' "$udev_file" 2>/dev/null; then
    echo 'SUBSYSTEM=="tty", ATTRS{product}=="Mowgli", SYMLINK+="mowgli"' | sudo tee -a "$udev_file" > /dev/null
    echo "✅ Règle ajoutée pour la carte Mowgli"
  else
    echo "✅ Règle UDEV pour la carte Mowgli déjà présente"
  fi

  echo
  echo "=== Détection GPS USB ==="
  echo "📡 Recherche des périphériques GPS via lsusb..."

  local found=0
  mapfile -t usb_lines < <(lsusb)

  for line in "${usb_lines[@]}"; do
    if echo "$line" | grep -Eiq "u[-]?blox|ch340|gps|rtk|cp210|ftdi"; then
      id=$(echo "$line" | grep -oP 'ID \K[0-9a-f]{4}:[0-9a-f]{4}')
      vendor_id="${id%%:*}"
      product_id="${id##*:}"
      rule="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$vendor_id\", ATTRS{idProduct}==\"$product_id\", SYMLINK+=\"gps\""

      echo "🔍 GPS détecté : $line"

      if ! grep -q "$vendor_id.*$product_id" "$udev_file"; then
        echo "$rule" | sudo tee -a "$udev_file" > /dev/null
        echo "✅ Règle ajoutée pour $vendor_id:$product_id"
      else
        echo "ℹ️  Règle déjà présente pour $vendor_id:$product_id"
      fi
      found=1
    fi
  done

  # 📄 Ajoute GPS depuis gps_models.conf s'il existe
  if [ -f "$conf_file" ]; then
    echo
    echo "📄 Ajout de modèles GPS personnalisés depuis gps_models.conf..."
    grep -vE '^\s*(#|$)' "$conf_file" | while read -r id; do
      vendor_id="${id%%:*}"
      product_id="${id##*:}"
      rule="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$vendor_id\", ATTRS{idProduct}==\"$product_id\", SYMLINK+=\"gps\""

      if ! grep -q "$vendor_id.*$product_id" "$udev_file"; then
        echo "$rule" | sudo tee -a "$udev_file" > /dev/null
        echo "✅ Règle ajoutée depuis conf pour $vendor_id:$product_id"
      else
        echo "ℹ️  Déjà présent (conf) : $vendor_id:$product_id"
      fi
    done
  fi

  if [ "$found" -eq 0 ]; then
    echo "⚠️  Aucun GPS détecté automatiquement via lsusb."
    echo "💡 Branchez votre GPS puis relancez cette étape si besoin."
  fi

  echo
  echo "🔄 Redémarrage de UDEV..."
  sudo udevadm control --reload-rules && sudo udevadm trigger
  echo "✅ Règles UDEV appliquées."

  pause_ou_touche
}
