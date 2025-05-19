#!/bin/bash
# functions/clonage_depot_mowgli_docker.sh
# Clonage ou mise à jour du dépôt mowgli-docker avec fallback intelligent de branche

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF_FILE="$SCRIPT_DIR/clone_mowgli_docker.conf"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

clonage_depot_mowgli_docker() {
  echo "=== Clonage ou mise à jour du dépôt Mowgli Docker ==="

  # Générer un fichier config par défaut si absent
  if [ ! -f "$CONF_FILE" ]; then
    cp "$SCRIPT_DIR/clone_mowgli_docker.conf.example" "$CONF_FILE"
    echo "[WARN] Exemple de config clonage créé : $CONF_FILE"
    echo "       Éditez ce fichier si vous voulez changer l'URL ou la branche."
    pause_ou_touche
  fi

  # Nettoyage BOM et CRLF
  sed -i '1 s/^\xEF\xBB\xBF//' "$CONF_FILE"
  sed -i 's/\r$//' "$CONF_FILE"
  source "$CONF_FILE"

  # Vérifie si la branche existe sur le dépôt
  if ! git ls-remote --heads "$REPO_URL" "$BRANCH" | grep -q "$BRANCH"; then
    echo "⚠️  Branche '$BRANCH' introuvable sur le dépôt distant."
    echo "🔎 Tentative de détection de la branche par défaut…"
    BRANCH=$(git ls-remote --symref "$REPO_URL" HEAD | awk -F'[/ ]+' '/^ref:/ {print $4}')
    echo "✅ Branche par défaut détectée : $BRANCH"
  fi

  echo "🔁 Dépôt      : $REPO_URL"
  echo "🔀 Branche    : $BRANCH"
  echo "📁 Cible      : $TARGET_DIR"
  echo

  if ! command -v git >/dev/null 2>&1; then
    echo "⚙️  Installation de git…"
    sudo apt update && sudo apt install -y git
  fi

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
