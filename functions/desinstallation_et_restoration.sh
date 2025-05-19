#!/bin/bash
# functions/desinstallation_et_restoration.sh
# Sous-menu Z : restauration & suppression

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

# Dossier backup
BACKUP_DIR="$HOME/mowgli-installer/backups"
mkdir -p "$BACKUP_DIR"

# Ì†ΩÌ¥ê Fonction g√©n√©rique de sauvegarde
sauvegarder_fichier() {
  local fichier="$1"
  local base
  base=$(basename "$fichier")
  if [ -f "$fichier" ]; then
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    cp "$fichier" "$BACKUP_DIR/${base}.${timestamp}.bak"
    echo "[INFO] Sauvegarde cr√©√©e : $BACKUP_DIR/${base}.${timestamp}.bak"
  fi
}

# ‚ôªÔ∏è Restaurer le dernier config.txt sauvegard√© (UART)
restauration_uart() {
  local fichier="/boot/firmware/config.txt"
  local dernier
  dernier=$(ls -t "$BACKUP_DIR"/config.txt.*.bak 2>/dev/null | head -n1)

  if [ -f "$dernier" ]; then
    echo -e "Derni√®re sauvegarde trouv√©e : \033[1m$(basename "$dernier")\033[0m"
    read -p "Souhaitez-vous la restaurer ? (o/N) : " rep
    if [[ "$rep" =~ ^[Oo]$ ]]; then
      sudo cp "$dernier" "$fichier"
      echo "[OK] Restauration effectu√©e."
      tail -n 5 "$fichier"
    else
      echo "[ANNUL√â] Restauration ignor√©e."
    fi
  else
    echo "[INFO] Aucune sauvegarde trouv√©e pour $fichier"
  fi

  pause_ou_touche
}

# Ì†ΩÌ∞≥ D√©sinstaller Docker proprement
desinstaller_docker() {
  echo "-> Suppression de Docker & Compose..."
  sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo rm -rf /etc/docker /var/lib/docker /etc/apt/keyrings/docker.gpg
  echo "[OK] Docker supprim√©."
  pause_ou_touche
}

# Ì†ΩÌ¥ß D√©sinstaller outils install√©s via complementary_tools.conf
desinstaller_outils() {
  echo "-> Suppression des outils compl√©mentaires..."

  local conf_file="$SCRIPT_DIR/complementary_tools.conf"
  local -a outils=()

  if [[ ! -f "$conf_file" ]]; then
    echo "[ERREUR] Fichier de configuration manquant : $conf_file"
    return 1
  fi

  while IFS="|" read -r cmd _desc; do
    [[ "$cmd" =~ ^#.*$ || -z "$cmd" ]] && continue
    outils+=("$cmd")
  done < "$conf_file"

  if [[ "${#outils[@]}" -eq 0 ]]; then
    echo "[INFO] Aucun outil trouv√© √† d√©sinstaller."
    return 0
  fi

  sudo apt purge -y "${outils[@]}" 2>/dev/null
  echo "[OK] Outils d√©sinstall√©s."
  pause_ou_touche
}

# Ì†ΩÌ≥Å Supprimer le dossier mowgli-docker
supprimer_dossier_mowgli() {
  local dossier="$HOME/mowgli-docker"
  if [ -d "$dossier" ]; then
    rm -rf "$dossier"
    echo "[OK] Dossier $dossier supprim√©."
  else
    echo "[INFO] Le dossier $dossier n'existe pas."
  fi
  pause_ou_touche
}

# ‚ö†Ô∏è Suppression compl√®te
tout_supprimer() {
  echo "‚ö†Ô∏è Suppression compl√®te de tous les composants..."
  read -p "√ätes-vous s√ªr ? Cela supprimera tout. (o/N) : " confirm
  if [[ "$confirm" =~ ^[Oo]$ ]]; then
    desinstaller_docker
    desinstaller_outils
    supprimer_dossier_mowgli
    echo "[OK] Tous les composants ont √©t√© supprim√©s."
  else
    echo "[ANNUL√â] Rien n‚Äôa √©t√© supprim√©."
  fi

  pause_ou_touche
}

# Ì†ΩÌ≥ã Menu Z
desinstallation_restoration() {
  while true; do
    echo
    echo "Ì†ΩÌ≥ã Sous-menu Z) D√©sinstallation et restauration"
    echo "1) Restaurer configuration UART"
    echo "2) D√©sinstaller Docker & Compose"
    echo "3) D√©sinstaller outils compl√©mentaires"
    echo "4) Supprimer d√©p√¥t mowgli-docker"
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
