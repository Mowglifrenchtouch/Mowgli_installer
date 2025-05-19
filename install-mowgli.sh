#!/bin/bash
# install-mowgli.sh : Script d'installation pour OpenMower Mowgli (mode terminal)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Chargement de toutes les fonctions
MODULE_DIR="$SCRIPT_DIR/functions"
if [ -d "$MODULE_DIR" ]; then
  for module in "$MODULE_DIR"/*.sh; do
    [ -r "$module" ] && source "$module"
  done
else
  echo "[ERREUR] Dossier functions introuvable : $MODULE_DIR"
  exit 1
fi

# 🌍 Langue
LANG_SYS=$(locale | grep LANG= | cut -d= -f2)
LANG_CODE="fr"
[[ "$LANG_SYS" =~ en ]] && LANG_CODE="en"
LANG_FILE="$SCRIPT_DIR/lang/${LANG_CODE}.sh"
if [ -f "$LANG_FILE" ]; then
  source "$LANG_FILE"
else
  echo "[WARN] Fichier de langue introuvable : $LANG_FILE. Fallback en français."
  source "$SCRIPT_DIR/lang/fr.sh"
fi

DEBUG=${DEBUG:-0}
STATUS_FILE="$SCRIPT_DIR/install-status.conf"
CONFIG_FILE="/boot/firmware/config.txt"
ENV_FILE=".env"

# 🔐 Pas de sudo
if [ "$EUID" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté avec sudo."
  echo "Lancez-le sans sudo : ./install-mowgli.sh"
  exit 1
fi

set -e

# ✅ Statuts initiaux (sans P)
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
H=pending
Z=pending
F=pending
EOF
fi

print_module_status() {
  local code="$1" label="$2" desc="$3"
  local value=$(grep "^$code=" "$STATUS_FILE" 2>/dev/null | cut -d= -f2)
  case "$value" in
    done)   printf "[✅] %s) %-30s -> %s\n" "$code" "$label" "$desc" ;;
    *)      printf "[⏳] %s) %-30s -> à faire\n" "$code" "$label" ;;
  esac
}

marquer_module_fait() {
  local code="$1"
  sed -i "s/^$code=.*/$code=done/" "$STATUS_FILE" 2>/dev/null || echo "$code=done" >> "$STATUS_FILE"
}

wrap_and_mark_done() {
  local code="$1"; shift
  local command="$@"
  if eval "$command"; then
    marquer_module_fait "$code"
  else
    echo "[ERREUR] La commande a échoué → $command"
    pause_ou_touche
  fi
}

reset_statuts_modules() {
  echo "⚠️  Cette action va réinitialiser tous les statuts des modules."
  read -p "Êtes-vous sûr ? (o/N) : " confirm
  if [[ "$confirm" =~ ^[Oo]$ ]]; then
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
H=pending
Z=pending
F=pending
EOF
    echo "✅ Tous les modules ont été réinitialisés."
  else
    echo "⏭️  Réinitialisation annulée."
  fi
  pause_ou_touche
}

# 🔁 Menu principal
while true; do
  [[ "$DEBUG" -ne 1 ]] && clear && cat <<'BANNER'
    __  ___                    ___       ____           __        ____         
   /  |/  /___ _      ______ _/ (_)     /  _/___  _____/ /_____ _/ / /__  _____
  / /|_/ / __ \ | /| / / __ `/ / /_____ / // __ \/ ___/ __/ __ `/ / / _ \/ ___/
 / /  / / /_/ / |/ |/ / /_/ / / /_____/ // / / (__  ) /_/ /_/ / / /  __/ /    
/_/  /_/\____/|__/|__/\__, /_/_/     /___/_/ /_/____/\__/\__,_/_/_/\___/_/     
                     /____/                                                  
BANNER

  NOW=$(date "+%d/%m/%Y %H:%M:%S")

  echo "===== ÉTAT DES MODULES ====="
  print_module_status I "Installation complète"       "globale"
  print_module_status U "Mise à jour système"         "apt upgrade"
  print_module_status J "Configuration UART"          "/boot/firmware/config.txt"
  print_module_status T "Outils complémentaires"       "htop, lazydocker..."
  print_module_status D "Docker & Compose"            "idempotent"
  print_module_status G "Configuration GPS"           "dtoverlay=uart4"
  print_module_status C "Clonage mowgli-docker"       "git clone/pull"
  print_module_status E "Génération .env"             ".env modifiable"
  print_module_status O "Déploiement Docker"          "docker compose"
  print_module_status M "Suivi MQTT"                  "mosquitto_sub"
  print_module_status S "Mode distant (ser2net)"      "UART → TCP (local → serveur)"
  print_module_status H "Mise à jour de l’installer"  "via Git"
  print_module_status Z "Désinstallation"             "reset + purge"
  print_module_status F "MàJ firmware robot"          "st-flash"
  echo

  # ℹ️ Infos système
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
  SYSTEM_STATUS=$([ "$UPDATE_COUNT" -eq 0 ] && echo "à jour" || echo "mises à jour dispo")

  if [ -d "$SCRIPT_DIR/.git" ]; then
    git -C "$SCRIPT_DIR" remote update > /dev/null 2>&1
    behind=$(git -C "$SCRIPT_DIR" rev-list --count HEAD..origin/main)
    INSTALLER_STATUS=$([ "$behind" -gt 0 ] && echo "mise à jour dispo (+${behind} commits)" || echo "à jour")
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
  echo "C) Clonage dépôt mowgli-docker"
  echo "E) Génération .env"
  echo "O) Déploiement conteneurs Docker"
  echo "M) Suivi MQTT robot_state"
  echo "S) Mode distant (ser2net)"
  echo "H) Mise à jour de l’installer"
  echo "Z) Désinstallation et restauration"
  echo "F) Mise à jour firmware robot"
  echo "R) Réinitialiser les statuts"
  echo "X) Quitter"

  read -p "Choix> " choice
  case "$choice" in
    I|i) installation_auto ;;
    U|u) wrap_and_mark_done U mise_a_jour_systeme ;;
    J|j) wrap_and_mark_done J configuration_uart ;;
    T|t) wrap_and_mark_done T installer_outils ;;
    D|d) wrap_and_mark_done D installer_docker ;;
    G|g) wrap_and_mark_done G configuration_gps ;;
    C|c) wrap_and_mark_done C clonage_depot_mowgli_docker ;;
    E|e) wrap_and_mark_done E generation_env ;;
    O|o) wrap_and_mark_done O deploiement_conteneurs ;;
    M|m) wrap_and_mark_done M suivi_mqtt_robot_state ;;
    S|s) wrap_and_mark_done S configuration_mode_distant ;;
    H|h) wrap_and_mark_done H mise_a_jour_installer ;;
    Z|z) wrap_and_mark_done Z desinstallation_restoration ;;
    F|f) wrap_and_mark_done F mise_a_jour_firmware_robot ;;
    R|r) reset_statuts_modules ;;
    X|x)
      echo "À bientôt !"
      read -p "$CONFIRM_REBOOT" reboot_choice
      [[ "$reboot_choice" =~ ^[YyOo]$ ]] && sudo reboot || exit 0 ;;
    *) echo "[INFO] Option invalide." ;;
  esac

  [[ "$DEBUG" -eq 1 ]] && echo "[DEBUG] Retour au menu" || pause_ou_touche
done
