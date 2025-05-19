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
    cp "$SCRIPT_DIR/clone_mowgli_docker.conf.example" "$CONF_FILE"
    echo "[WARN] Exemple de config clonage créé : $CONF_FILE"
    echo "       Éditez ce fichier pour personnaliser le dépôt, puis relancez l'option C)."
    pause_ou_touche
    return 1
  fi

  # Nettoyage du fichier (UTF-8 BOM + CRLF)
  sed -i '1 s/^\xEF\xBB\xBF//' "$CONF_FILE"
  sed -i 's/\r$//' "$CONF_FILE"
  source "$CONF_FILE"

  # 🧪 Vérification des variables obligatoires
  if [ -z "$REPO_URL" ] || [ -z "$BRANCH" ] || [ -z "$TARGET_DIR" ]; then
    echo "[ERREUR] Une ou plusieurs variables sont manquantes dans le fichier $CONF_FILE"
    echo "         Vérifiez : REPO_URL, BRANCH, TARGET_DIR"
    pause_ou_touche
    return 1
  fi

  echo "🔁 Dépôt      : $REPO_URL"
  echo "🔀 Branche    : $BRANCH"
  echo "📁 Cible      : $TARGET_DIR"
  echo

  # Vérification de la présence de git
  if ! command -v git >/dev/null 2>&1; then
    echo "⚙️  Git non détecté, installation en cours..."
    sudo apt update && sudo apt install -y git
  fi

  # Clonage ou mise à jour
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
