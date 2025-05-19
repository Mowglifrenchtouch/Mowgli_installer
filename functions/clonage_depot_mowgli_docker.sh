#!/bin/bash
# functions/clonage_depot_mowgli_docker.sh
# Clonage ou mise à jour du dépôt mowgli-docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF_FILE="$SCRIPT_DIR/clone_mowgli_docker.conf"

# Chargement des fonctions utilitaires
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

clonage_depot_mowgli_docker() {
  echo "=== Clonage ou mise à jour du dépôt Mowgli Docker ==="

  # Création automatique du fichier de configuration si absent
  if [ ! -f "$CONF_FILE" ]; then
    cat > "$CONF_FILE" <<EOF
# clone_mowgli_docker.conf
# Configuration pour cloner le dépôt mowgli-docker

REPO_URL="https://github.com/cedbossneo/mowgli-docker.git"
BRANCH="main"
TARGET_DIR="\$HOME/mowgli-docker"
EOF
    echo "[WARN] Fichier de config clonage créé : $CONF_FILE"
    echo "       Vous pouvez le modifier si nécessaire, puis relancer l'option C)."
    pause_ou_touche
    return
  fi

  # Nettoyage UTF-8 BOM / CRLF
  sed -i '1 s/^\xEF\xBB\xBF//' "$CONF_FILE"
  sed -i 's/\r$//' "$CONF_FILE"
  source "$CONF_FILE"

  echo "🔁 Dépôt      : $REPO_URL"
  echo "🔀 Branche    : $BRANCH"
  echo "📁 Cible      : $TARGET_DIR"
  echo

  # Vérifie que git est installé
  if ! command -v git >/dev/null 2>&1; then
    echo "⚙️  Git non détecté, installation en cours..."
    sudo apt update && sudo apt install -y git
  fi

  # Mise à jour si le dépôt est déjà cloné
  if [ -d "$TARGET_DIR/.git" ]; then
    echo "✅ Le dépôt existe déjà dans : $TARGET_DIR"
    if ask_update_if_exists "Souhaitez-vous le mettre à jour (git fetch + reset) ?"; then
      git -C "$TARGET_DIR" fetch origin "$BRANCH" \
        && git -C "$TARGET_DIR" reset --hard "origin/$BRANCH" \
        || { echo "[ERREUR] Échec de mise à jour."; pause_ou_touche; return 1; }
      echo "[OK] Dépôt mis à jour avec succès."
    else
      echo "⏭️  Mise à jour ignorée."
    fi
  else
    echo "➡️  Clonage du dépôt dans : $TARGET_DIR"
    rm -rf "$TARGET_DIR"
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" \
      || { echo "[ERREUR] Échec du clonage."; pause_ou_touche; return 1; }
    echo "[OK] Dépôt cloné avec succès."
  fi

  pause_ou_touche
}
