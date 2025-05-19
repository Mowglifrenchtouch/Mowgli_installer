#!/bin/bash
# functions/mise_a_jour_mowgli_installer.sh
# Mise à jour automatique du Mowgli Installer depuis un dépôt Git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/update_installer.conf"
TEMP_DIR="$HOME/.mowgli-installer-update"

[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

mise_a_jour_installer() {
  echo "=== Mise à jour du Mowgli Installer ==="

  # Crée un fichier de config d'exemple si absent
  if [ ! -f "$CONFIG_FILE" ]; then
    cp "$SCRIPT_DIR/update_installer.conf.example" "$CONFIG_FILE"
    echo "[WARN] Exemple de config créé : $CONFIG_FILE"
    echo "       Veuillez l’éditer pour définir le dépôt, puis relancez."
    pause_ou_touche
    return 1
  fi

  # Nettoyage BOM/CRLF
  sed -i '1 s/^\xEF\xBB\xBF//' "$CONFIG_FILE"
  sed -i 's/\r$//' "$CONFIG_FILE"
  source "$CONFIG_FILE"

  # Validation des variables
  if [ -z "$REPO_URL" ] || [ -z "$BRANCH" ]; then
    echo "[ERREUR] REPO_URL ou BRANCH non défini dans $CONFIG_FILE"
    pause_ou_touche
    return 1
  fi

  echo "🔁 Dépôt      : $REPO_URL"
  echo "🔀 Branche    : $BRANCH"
  echo "📁 Répertoire : $SCRIPT_DIR"
  echo

  # Vérifie que le dossier actuel est bien un dépôt Git
  if [ ! -d "$SCRIPT_DIR/.git" ]; then
    echo "[ERREUR] Ce répertoire n'est pas un dépôt Git valide."
    pause_ou_touche
    return 1
  fi

  # Vérifie si une mise à jour est nécessaire
  git -C "$SCRIPT_DIR" fetch origin "$BRANCH"
  local behind
  behind=$(git -C "$SCRIPT_DIR" rev-list --count HEAD..origin/"$BRANCH")

  if [ "$behind" -eq 0 ]; then
    echo "✅ Aucune mise à jour disponible."
    pause_ou_touche
    return
  fi

  echo "📦 $behind mise(s) à jour disponible(s) sur '$BRANCH'."

  if ! ask_update_if_exists "Souhaitez-vous appliquer la mise à jour maintenant ?"; then
    echo "⏭️  Mise à jour annulée."
    pause_ou_touche
    return
  fi

  echo "⬇️  Clonage temporaire de la branche '$BRANCH'..."
  rm -rf "$TEMP_DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR" || {
    echo "[ERREUR] Échec du clonage du dépôt."
    pause_ou_touche
    return 1
  }

  echo "🔄 Synchronisation des fichiers (hors .git)..."
  rsync -a --exclude='.git' "$TEMP_DIR/" "$SCRIPT_DIR/"
  rm -rf "$TEMP_DIR"

  echo "✅ Mowgli Installer mis à jour avec succès depuis $REPO_URL ($BRANCH)."
  pause_ou_touche
}
