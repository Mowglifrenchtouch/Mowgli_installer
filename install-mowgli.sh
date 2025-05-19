#!/bin/bash
# install-mowgli.sh : Script d'installation pour OpenMower Mowgli (mode terminal)

# === État des modules installés / validés ===
# ✔️  installation_auto            → à faire (composite)
# ✔️  mise_a_jour_systeme         → à idempotenter
# ✔️  configuration_uart          → à faire (vérifier dans /boot/firmware/config.txt)
# ✔️  installer_outils            → à faire (htop, lazydocker...)
# ✔️  install_docker              → ✅ fait (idempotent + confirmation)
# ✔️  configuration_gps           → à faire
# ✔️  clonage_depot_mowgli_docker → à faire (git pull si déjà là ?)
# ✔️  generation_env              → à faire (.env déjà présent ?)
# ✔️  deploiement_conteneurs      → à faire (docker compose ps ?)
# ✔️  suivi_mqtt_robot_state      → à faire (MQTT actif ?)
# ✔️  personalisation_logo        → volontairement NON idempotent ✅
# ✔️  mise_a_jour_installer       → déjà géré (git behind)
# ✔️  desinstallation_restoration → à faire (backup + reset ?)
# ✔️  mise_a_jour_firmware_robot  → optionnel (flash detecté ?)

# Définir le dossier du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Détection automatique de la langue (via fichiers en.sh / fr.sh à la racine)
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

# Option debug (ne pas effacer le terminal)
DEBUG=${DEBUG:-0}

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

# Fonctions de vérification idempotentes (extraits simplifiés)
ask_update_if_exists() {
  local message="$1"
  echo -n "$message (y/N) : "
  read -r answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

check_docker_installed() {
  if command -v docker &>/dev/null && docker compose version &>/dev/null; then
    echo "✅ Docker et Docker Compose sont déjà installés."
    ask_update_if_exists "Souhaitez-vous les mettre à jour ?"
    return $? # 0 = update, 1 = skip
  else
    return 0 # pas installé → installer
  fi
}

install_docker() {
  if ! check_docker_installed; then
    echo "⏭️  Installation Docker ignorée."
    return
  fi

  echo "⚙️  Installation de Docker et Docker Compose..."
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose
}

# Boucle principale
while true; do
  [[ "$DEBUG" -ne 1 ]] && clear

  NOW=$(date "+%d/%m/%Y %H:%M:%S")

  echo "===== ÉTAT DES MODULES ====="
  echo "✔️  I) Installation complète         → à faire (composite)"
  echo "✔️  U) Mise à jour système          → à idempotenter"
  echo "✔️  J) Configuration UART           → à faire (/boot/firmware/config.txt)"
  echo "✔️  T) Outils complémentaires        → à faire (htop, lazydocker...)"
  echo "✅  D) Docker & Compose              → OK (idempotent)"
  echo "✔️  G) Configuration GPS            → à faire"
  echo "✔️  C) Clonage mowgli-docker        → à faire (déjà cloné ?)"
  echo "✔️  E) Génération .env              → à faire (.env existant ?)"
  echo "✔️  O) Déploiement Docker           → à faire (conteneurs actifs ?)"
  echo "✔️  M) Suivi MQTT                   → à faire"
  echo "❗  P) Personnalisation logo        → volontairement non idempotent"
  echo "✔️  H) Mise à jour de l’installer   → déjà géré"
  echo "✔️  Z) Désinstallation              → à faire (reset/restore)"
  echo "✔️  F) Mise à jour firmware robot   → optionnel"
  echo

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
