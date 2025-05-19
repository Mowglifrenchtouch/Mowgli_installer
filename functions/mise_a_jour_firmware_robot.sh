#!/bin/bash
# functions/mise_a_jour_firmware_robot.sh
# Mise à jour du firmware du robot (via st-flash)

mise_a_jour_firmware_robot() {
  echo "-> Mise à jour du firmware robot"

  local BOARD="Yardforce500B"
  local CONFIG_FILE="/opt/mowgli/firmware/version.txt"
  local SERVER="http://192.168.0.10/firmware"

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERREUR] Fichier de version introuvable : $CONFIG_FILE"
    return 1
  fi

  read LOCAL_VERSION LOCAL_CHANNEL < "$CONFIG_FILE"

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
    return 1
  fi

  echo "Version disponible : $REMOTE_VERSION"

  if [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ] || [ "$CHANNEL" != "$LOCAL_CHANNEL" ]; then
    echo "Une mise à jour est disponible !"
    URL="$SERVER/$BOARD/$CHANNEL/firmware_$REMOTE_VERSION.bin"
    TMP_FW="firmware_$REMOTE_VERSION.bin"

    echo "Téléchargement depuis $URL ..."
    curl -f -o "$TMP_FW" "$URL"
    if [ $? -ne 0 ]; then
      echo "[ERREUR] Téléchargement échoué."
      return 1
    fi

    echo "Flash en cours avec st-flash..."
    st-flash write "$TMP_FW" 0x8000000
    if [ $? -eq 0 ]; then
      echo "$REMOTE_VERSION $CHANNEL" | sudo tee "$CONFIG_FILE" > /dev/null
      echo "[OK] Mise à jour du firmware vers $REMOTE_VERSION ($CHANNEL) terminée."
    else
      echo "[ERREUR] Flash du firmware échoué."
    fi
    rm -f "$TMP_FW"
  else
    echo "Firmware déjà à jour."
  fi
}
