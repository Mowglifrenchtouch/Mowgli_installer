#!/bin/bash
# functions/mise_a_jour_firmware_robot.sh
# Mise à jour du firmware du robot (via st-flash)

mise_a_jour_firmware_robot() {
  echo "=== Mise à jour du firmware du robot ==="

  local BOARD="Yardforce500B"
  local CONFIG_FILE="/opt/mowgli/firmware/version.txt"
  local SERVER="http://192.168.0.10/firmware"
  local TMP_FW

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERREUR] Fichier de version introuvable : $CONFIG_FILE"
    pause_ou_touche
    return 1
  fi

  read -r LOCAL_VERSION LOCAL_CHANNEL < "$CONFIG_FILE"

  echo
  echo "Canal actuel détecté : $LOCAL_CHANNEL"
  echo "Version actuelle     : $LOCAL_VERSION"
  echo
  echo "Canaux disponibles :"
  echo "1) stable"
  echo "2) beta"
  echo "3) nightly"
  read -p "Choisissez le canal de mise à jour [1-3] (actuel : $LOCAL_CHANNEL) : " canal

  case "$canal" in
    2) CHANNEL="beta" ;;
    3) CHANNEL="nightly" ;;
    *) CHANNEL="stable" ;;
  esac

  REMOTE_VERSION=$(curl -fs "$SERVER/$BOARD/$CHANNEL/latest.txt")
  if [ -z "$REMOTE_VERSION" ]; then
    echo "[ERREUR] Impossible de récupérer la version distante pour $CHANNEL"
    pause_ou_touche
    return 1
  fi

  echo "Version distante disponible : $REMOTE_VERSION"

  if [ "$REMOTE_VERSION" == "$LOCAL_VERSION" ] && [ "$CHANNEL" == "$LOCAL_CHANNEL" ]; then
    echo "✅ Le firmware est déjà à jour."
    pause_ou_touche
    return
  fi

  echo "⚠️  Une mise à jour est disponible : $REMOTE_VERSION ($CHANNEL)"
  if ! ask_update_if_exists "Souhaitez-vous flasher ce nouveau firmware ?"; then
    echo "⏭️  Mise à jour du firmware annulée."
    pause_ou_touche
    return
  fi

  URL="$SERVER/$BOARD/$CHANNEL/firmware_$REMOTE_VERSION.bin"
  TMP_FW="firmware_$REMOTE_VERSION.bin"

  echo "⬇️  Téléchargement depuis $URL ..."
  if ! curl -f -o "$TMP_FW" "$URL"; then
    echo "[ERREUR] Échec du téléchargement."
    pause_ou_touche
    return 1
  fi

  echo "🔧 Flash en cours avec st-flash..."
  if st-flash write "$TMP_FW" 0x8000000; then
    echo "$REMOTE_VERSION $CHANNEL" | sudo tee "$CONFIG_FILE" > /dev/null
    echo "✅ Firmware mis à jour vers $REMOTE_VERSION ($CHANNEL)."
  else
    echo "❌ Flash échoué. Aucune modification appliquée."
  fi

  rm -f "$TMP_FW"
  pause_ou_touche
}
