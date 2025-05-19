#!/bin/bash
# functions/clonage_depot_mowgli_docker.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF_FILE="$SCRIPT_DIR/clone_mowgli_docker.conf"

# Chargement utilitaires (pause_ou_touche)
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

# Si le fichier de config n'existe pas, on le crée depuis l'exemple
if [ ! -f "$CONF_FILE" ]; then
  cp "$SCRIPT_DIR/clone_mowgli_docker.conf.example" "$CONF_FILE"
  echo "[WARN] Exemple de config clonage créé : $CONF_FILE"
  echo "       Éditez ce fichier pour personnaliser le dépôt, puis relancez l'option C)."
  return
fi

# Nettoyage éventuel
sed -i '1 s/^\xEF\xBB\xBF//' "$CONF_FILE"
sed -i 's/\r$//' "$CONF_FILE"
source "$CONF_FILE"

clonage_depot_mowgli_docker() {
  echo "-> Clonage / mise à jour du dépôt ${REPO_URL}..."

  if ! command -v git >/dev/null 2>&1; then
    echo "Installation de git..."
    sudo apt update && sudo apt install -y git
  fi

  if [ -d "$TARGET_DIR/.git" ]; then
    git -C "$TARGET_DIR" fetch origin "$BRANCH" \
      && git -C "$TARGET_DIR" reset --hard "origin/$BRANCH" \
      || { echo "[ERREUR] Échec de mise à jour."; return 1; }
  else
    rm -rf "$TARGET_DIR"
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" \
      || { echo "[ERREUR] Échec de clonage."; return 1; }
  fi

  echo "[OK] Dépôt mis à jour dans $TARGET_DIR"
  pause_ou_touche
}
