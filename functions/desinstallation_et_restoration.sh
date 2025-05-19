#!/bin/bash
# functions/desinstallation_et_restoration.sh
# Sous-menu Z : restauration & suppression

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

# 📁 Dossier de sauvegarde
BACKUP_DIR="$HOME/mowgli-installer/backups"
mkdir -p "$BACKUP_DIR"

# 💾 Fonction de sauvegarde locale (si pas déjà dans utils.sh)
sauvegarder_fichier() {
  local fichier="$1"
  local base
  base=$(basename "$fichier")
  if [ -f "$fichier" ]; then
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    cp "$fichier" "$BACKUP_DIR/${base}.${timestamp}.bak"
    echo "[INFO] Sauvegarde créée : $BACKUP_DIR/${base}.${timestamp}.bak"
  fi
}

# ♻️ Restaurer config.txt
restauration_uart() {
  local fichier="/boot/firmware/config.txt"
  local dernier
  dernier=$(ls -t "$BACKUP_DIR"/config.txt.*.bak 2>/dev/null | head -n1)

  if [ -f "$dernier" ]; then
    echo -e "Dernière sauvegarde trouvée : \033[1m$(basename "$dernier")\033[0m"
    read -p "Souhaitez-vous la restaurer ? (o/N) : " rep
    if [[ "$rep" =~ ^[Oo]$ ]]; then
      sudo cp "$dernier" "$fichier"
      echo "[OK] Restauration effectuée."
      tail -n 5 "$fichier"
    else
      echo "[ANNULÉ] Restauration ignorée."
    fi
  else
    echo "[INFO] Aucune sauvegarde trouvée pour $fichier"
  fi

  pause_ou_touche
}

# 🐳 Supprimer Docker
desinstaller_docker() {
  echo "-> Suppression de Docker & Compose..."
  sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo rm -rf /etc/docker /var/lib/docker /etc/apt/keyrings/docker.gpg
  echo "[OK] Docker supprimé."
  pause_ou_touche
}

# 🛠️ Supprimer outils via complementary_tools.conf
desinstaller_outils() {
  echo "-> Suppression des outils complémentaires..."

  local conf_file="$SCRIPT_DIR/complementary_tools.conf"
  local -a outils=()

  if [[ ! -f "$conf_file" ]]; then
    echo "[ERREUR] Fichier de configuration manquant : $conf_file"
    pause_ou_touche
    return 1
  fi

  while IFS="|" read -r cmd _desc; do
    [[ "$cmd" =~ ^#.*$ || -z "$cmd" ]] && continue
    if command -v "$cmd" >/dev/null 2>&1; then
      outils+=("$cmd")
    fi
  done < "$conf_file"

  if [[ "${#outils[@]}" -eq 0 ]]; then
    echo "[INFO] Aucun outil à désinstaller."
  else
    sudo apt purge -y "${outils[@]}" 2>/dev/null
    echo "[OK] Outils désinstallés : ${outils[*]}"
  fi

  pause_ou_touche
}

# 🧹 Supprimer dossier mowgli-docker
supprimer_dossier_mowgli() {
  local dossier="$HOME/mowgli-docker"
  if [ -d "$dossier" ]; then
    rm -rf "$dossier"
    echo "[OK] Dossier supprimé : $dossier"
  else
    echo "[INFO] Aucun dossier trouvé à : $dossier"
  fi
  pause_ou_touche
}

# 🔥 Tout supprimer
tout_supprimer() {
  echo "⚠️  Suppression complète de tous les composants liés à Mowgli"
  read -p "Confirmez-vous la suppression totale ? (o/N) : " confirm
  if [[ "$confirm" =~ ^[Oo]$ ]]; then
    desinstaller_docker
    desinstaller_outils
    supprimer_dossier_mowgli
    echo "[OK] Suppression complète effectuée."
  else
    echo "[ANNULÉ] Aucune action effectuée."
  fi
  pause_ou_touche
}

# 🧭 Menu Z : restauration & désinstallation
desinstallation_restoration() {
  while true; do
    echo
    echo "🧯 Sous-menu Z) Désinstallation et restauration"
    echo "1) Restaurer configuration UART"
    echo "2) Désinstaller Docker & Compose"
    echo "3) Désinstaller outils complémentaires"
    echo "4) Supprimer dépôt mowgli-docker"
    echo "5) Tout supprimer"
    echo "0) Retour au menu principal"
    read -p "Choix> " sub_choice

    case "$sub_choice" in
      1) restauration_uart ;;
      2) desinstaller_docker ;;
      3) desinstaller_outils ;;
      4) supprimer_dossier_mowgli ;;
      5) tout_supprimer ;;
      0) break ;;
      *) echo "[ERREUR] Option invalide." ;;
    esac
  done
}
