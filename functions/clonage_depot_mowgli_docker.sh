#!/bin/bash
# functions/clonage_depot_mowgli_docker.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF_FILE="$SCRIPT_DIR/clone_mowgli_docker.conf"

# Chargement utilitaires
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
  echo "=== Clonage ou mise à jour du dépôt ${REPO_URL} (branche ${BRANCH}) ==="

  if ! command -v git >/dev/null 2>&1; then
    echo "Installation de git..."
    sudo apt update && sudo apt install -y git
  fi

  if [ -d "$TARGET_DIR/.git" ]; then
    echo "✅ Le dépôt est déjà présent dans $TARGET_DIR"
    if ask_update_if_exists "Souhaitez-vous mettre à jour ce dépôt (git fetch + reset) ?"; then
      git -C "$TARGET_DIR" fetch origin "$BRANCH" \
        && git -C "$TARGET_DIR" reset --hard "origin/$BRANCH" \
        || { echo "[ERREUR] Échec de mise à jour."; return 1; }
      echo "[OK] Dépôt mis à jour."
    else
      echo "⏭️  Mise à jour du dépôt ignorée."
    fi
  else
    echo "➡️ Clonage du dépôt dans $TARGET_DIR..."
    rm -rf "$TARGET_DIR"
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" \
      || { echo "[ERREUR] Échec de clonage."; return 1; }
    echo "[OK] Dépôt cloné dans $TARGET_DIR"
  fi

  pause_ou_touche
}
