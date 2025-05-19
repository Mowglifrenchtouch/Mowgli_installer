#!/bin/bash
# install-mowgli.sh : Script d'installation pour OpenMower Mowgli (mode terminal)

# Définir le dossier du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Détection automatique de la langue (via dossier lang/)
LANG_DIR="$SCRIPT_DIR/lang"
LANG_SYS=$(locale | grep LANG= | cut -d= -f2)
LANG_CODE="fr"
[[ "$LANG_SYS" =~ en ]] && LANG_CODE="en"

LANG_FILE="$LANG_DIR/${LANG_CODE}.sh"
if [ -f "$LANG_FILE" ]; then
  source "$LANG_FILE"
else
  echo "[WARN] Fichier de langue introuvable : $LANG_FILE. Fallback en français."
  source "$LANG_DIR/fr.sh"
fi

# Option debug (ne pas effacer le terminal)
DEBUG=${DEBUG:-0}

# --- Normalisation des modules en LF (Unix) pour éviter les erreurs CRLF) ---
if ! command -v dos2unix >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y dos2unix
fi
for fn in "$SCRIPT_DIR"/functions/*.sh; do
  dos2unix "$fn" 2>/dev/null || true
done

# Ne pas exécuter avec sudo
if [ "$EUID" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté avec sudo."
  echo "Lancez-le sans sudo : ./install-mowgli.sh"
  exit 1
fi

set -e

# Variables
CONFIG_FILE="/boot/firmware/config.txt"
BACKUP_SUFFIX=".bak"
ENV_FILE=".env"

# Collecte infos système
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
MAC=$(ip link show eth0 | awk '/ether/ {print $2}')
SSID=$(iwgetid -r 2>/dev/null || echo "non connecté")
UPTIME=$(uptime -p)
TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo "n/a")
LOAD=$(awk '{print $1, $2, $3}' /proc/loadavg)
MEM=$(free -m | awk '/Mem/ {printf "%d MiB / %d MiB", $3, $2}')
DISK=$(df -h / | awk 'END {print $4 " libres sur " $2}')
NOW=$(date "+%d/%m/%Y %H:%M:%S")

# Vérification mises à jour
UPDATE_COUNT=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
SYSTEM_STATUS=$([ "$UPDATE_COUNT" -eq 0 ] && echo "à jour" || echo "mises à jour disponibles")

# Vérification version du script
if [ -d "$SCRIPT_DIR/.git" ]; then
  git -C "$SCRIPT_DIR" remote update > /dev/null 2>&1
  behind=$(git -C "$SCRIPT_DIR" rev-list --count HEAD..origin/main)
  INSTALLER_STATUS=$([ "$behind" -gt 0 ] && echo "mise à jour disponible (+${behind} commits)" || echo "à jour")
else
  INSTALLER_STATUS="non versionné"
fi

# Chargement des modules
MODULE_DIR="$SCRIPT_DIR/functions"
if [ -d "$MODULE_DIR" ]; then
  for module in "$MODULE_DIR"/*.sh; do
    [ -r "$module" ] && source "$module"
  done
else
  echo "[WARN] Dossier modules introuvable: $MODULE_DIR"
fi

# Chargement des utilitaires communs
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

# Boucle principale
while true; do
  [[ "$DEBUG" -ne 1 ]] && clear

  cat << "BANNER"
    __  ___                    ___       ____           __        ____         
   /  |/  /___ _      ______ _/ (_)     /  _/___  _____/ /_____ _/ / /__  _____
  / /|_/ / __ \ | /| / / __ `/ / /_____ / // __ \/ ___/ __/ __ `/ / / _ \/ ___/
 / /  / / /_/ / |/ |/ / /_/ / / /_____// // / / (__  ) /_/ /_/ / / /  __/ /    
/_/  /_/\____/|__/|__/\__, /_/_/     /___/_/ /_/____/\__/\__,_/_/_/\___/_/     
                     /____/
BANNER

  echo "[$NOW]"
  echo "Hostname       : $HOSTNAME"
  echo "IP locale      : $IP"
  echo "Adresse MAC    : $MAC"
  echo "WiFi (SSID)    : $SSID"
  echo "Uptime         : $UPTIME"
  echo "Température    : $TEMP"
  echo "Charge CPU     : $LOAD"
  echo "RAM utilisée   : $MEM"
  echo "Disque libre   : $DISK"
  echo "État système   : $SYSTEM_STATUS"
  echo "Etat Mowgli_Installer : $INSTALLER_STATUS"
  echo

  echo "===== INSTALLATION & CONFIGURATION ====="
  echo "I) Installation complète"
  echo "U) Mise à jour du système"
  echo "J) Configuration UART"
  echo "T) Outils complémentaires"
  echo "D) Docker & Compose"
  echo "G) Configuration GPS"
  echo "C) Clonage depot mowgli-docker"
  echo "E) Generation .env"
  echo "O) Deploiement conteneurs Docker"
  echo "M) Suivi MQTT robot_state"
  echo "P) Personalisation logo"
  echo "H) Mise a jour Mowgli installer"
  echo "Z) Desinstallation et restauration"
  echo "F) Mise à jour firmware robot"
  echo "X) Quitter"

  read -p "Choix> " choice
  case "$choice" in
    I|i) installation_auto ;;
    U|u) mise_a_jour_systeme ;;
    J|j) configuration_uart ;;
    T|t) installer_outils ;;
    D|d) installer_docker ;;
    G|g) configuration_gps ;;
    C|c) clonage_depot_mowgli_docker ;;
    E|e) generation_env ;;
    O|o) deploiement_conteneurs ;;
    M|m) suivi_mqtt_robot_state ;;
    P|p) personalisation_logo ;;
    H|h) mise_a_jour_installer ;;
    Z|z) desinstallation_restoration ;;
    F|f) mise_a_jour_firmware_robot ;;
    X|x)
      echo "À bientôt !"
      exit 0 ;;
    *) echo "[ERREUR] Option invalide." ;;
  esac

  [[ "$DEBUG" -eq 1 ]] && echo -e "\n[DEBUG] Retour au menu principal.\n" || pause_ou_touche
done
