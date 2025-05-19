#!/bin/bash
# install-mowgli.sh : Script d'installation pour OpenMower Mowgli (mode terminal)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Suivi des modules dynamiques ===
STATUS_FILE="$SCRIPT_DIR/install-status.conf"

if [ ! -f "$STATUS_FILE" ]; then
  cat > "$STATUS_FILE" <<EOF
I=pending
U=pending
J=pending
T=pending
D=pending
G=pending
C=pending
E=pending
O=pending
M=pending
P=manual
H=pending
Z=pending
F=pending
EOF
fi

print_module_status() {
  local code="$1"
  local label="$2"
  local description="$3"
  local value=$(grep "^$code=" "$STATUS_FILE" 2>/dev/null | cut -d= -f2)
  case "$value" in
    done)   printf "[OK]  %s) %-30s -> %s\n" "$code" "$label" "$description" ;;
    manual) printf "[!!] %s) %-30s -> NON idempotent\n" "$code" "$label" ;;
    *)      printf "[--] %s) %-30s -> à faire\n" "$code" "$label" ;;
  esac
}

marquer_module_fait() {
  local code="$1"
  sed -i "s/^$code=.*/$code=done/" "$STATUS_FILE" 2>/dev/null || echo "$code=done" >> "$STATUS_FILE"
}

# Détection de la langue
LANG_SYS=$(locale | grep LANG= | cut -d= -f2)
LANG_CODE="fr"
[[ "$LANG_SYS" =~ en ]] && LANG_CODE="en"
LANG_FILE="$SCRIPT_DIR/${LANG_CODE}.sh"
if [ -f "$LANG_FILE" ]; then
  source "$LANG_FILE"
else
  echo "[WARN] Fichier de langue introuvable : $LANG_FILE. Fallback en français."
  source "$SCRIPT_DIR/fr.sh"
fi

DEBUG=${DEBUG:-0}
if [ "$EUID" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté avec sudo."
  echo "Lancez-le sans sudo : ./install-mowgli.sh"
  exit 1
fi

set -e

CONFIG_FILE="/boot/firmware/config.txt"
BACKUP_SUFFIX=".bak"
ENV_FILE=".env"

while true; do
  [[ "$DEBUG" -ne 1 ]] && clear
  NOW=$(date "+%d/%m/%Y %H:%M:%S")

  echo "===== ÉTAT DES MODULES ====="
  print_module_status I "Installation complète"         "OK"
  print_module_status U "Mise à jour système"           "idempotent"
  print_module_status J "Configuration UART"            "/boot/firmware/config.txt"
  print_module_status T "Outils complémentaires"         "sélectif"
  print_module_status D "Docker & Compose"              "idempotent"
  print_module_status G "Configuration GPS"             "dtoverlay=uart4"
  print_module_status C "Clonage mowgli-docker"         "git pull / clone"
  print_module_status E "Génération .env"               ".env modifiable"
  print_module_status O "Déploiement Docker"            "si compose actif"
  print_module_status M "Suivi MQTT"                    "via mosquitto_sub"
  print_module_status P "Personnalisation logo"         ""
  print_module_status H "Mise à jour de l’installer"    "Git remote sync"
  print_module_status Z "Désinstallation"               "reset + suppressions"
  print_module_status F "Mise à jour firmware robot"    "comparaison + flash"
  echo

  HOSTNAME=$(hostname)
  IP=$(hostname -I | awk '{print $1}')
  MAC=$(ip link show eth0 | awk '/ether/ {print $2}')
  SSID=$(iwgetid -r 2>/dev/null || echo "non connecté")
  UPTIME=$(uptime -p)
  TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo "n/a")
  LOAD=$(awk '{print $1, $2, $3}' /proc/loadavg)
  MEM=$(free -m | awk '/Mem/ {printf "%d MiB / %d MiB", $3, $2}')
  DISK=$(df -h / | awk 'END {print $4 " libres sur " $2}')
  UPDATE_COUNT=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
  SYSTEM_STATUS=$([ "$UPDATE_COUNT" -eq 0 ] && echo "à jour" || echo "mises à jour disponibles")

  if [ -d "$SCRIPT_DIR/.git" ]; then
    git -C "$SCRIPT_DIR" remote update > /dev/null 2>&1
    behind=$(git -C "$SCRIPT_DIR" rev-list --count HEAD..origin/main)
    INSTALLER_STATUS=$([ "$behind" -gt 0 ] && echo "mise à jour disponible (+${behind} commits)" || echo "à jour")
  else
    INSTALLER_STATUS="non versionné"
  fi

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
    D|d) install_docker ;;
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
      read -p "Souhaitez-vous redémarrer le Raspberry Pi ? (y/N) : " reboot_choice
      if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        echo "🔁 Redémarrage en cours..."
        sudo reboot
      else
        exit 0
      fi ;;
    *) echo "[ERREUR] Option invalide." ;;
  esac

  [[ "$DEBUG" -eq 1 ]] && echo -e "\n[DEBUG] Retour au menu principal.\n" || pause_ou_touche

done
