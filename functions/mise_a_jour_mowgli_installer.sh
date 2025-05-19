#!/bin/bash
# functions/mise_a_jour_mowgli_installer.sh
# Mise à jour automatique du Mowgli Installer depuis un dépôt Git

mise_a_jour_installer() {
  local script_dir="$HOME/mowgli-installer"
  local config_file="$script_dir/update_installer.conf"
  local temp_dir="$HOME/.mowgli-installer-update"

  echo "=== Mise à jour du Mowgli Installer ==="

  # Vérifie la config
  if [ ! -f "$config_file" ]; then
    cp "$script_dir/update_installer.conf.example" "$config_file"
    echo "[WARN] Exemple de config créé à $config_file"
    echo "       Modifiez ce fichier pour définir votre dépôt."
    pause_ou_touche
    return
  fi

  sed -i '1 s/^\xEF\xBB\xBF//' "$config_file"
  sed -i 's/\r$//' "$config_file"
  source "$config_file"

  echo "🔍 Vérification du dépôt distant $REPO_URL [$BRANCH]"

  # Vérifie si le repo actuel est bien un dépôt Git
  if [ ! -d "$script_dir/.git" ]; then
    echo "[ERREUR] Le dossier $script_dir n’est pas un dépôt Git valide."
    pause_ou_touche
    return 1
  fi

  git -C "$script_dir" fetch origin "$BRANCH"
  local behind
  behind=$(git -C "$script_dir" rev-list --count HEAD..origin/"$BRANCH")

  if [ "$behind" -eq 0 ]; then
    echo "✅ Aucune mise à jour disponible."
    pause_ou_touche
    return
  fi

  echo "📦 $behind commit(s) en attente de mise à jour."

  if ! ask_update_if_exists "Souhaitez-vous mettre à jour le script ?"; then
    echo "⏭️  Mise à jour annulée."
    pause_ou_touche
    return
  fi

  echo "⬇️ Clonage temporaire depuis $REPO_URL..."
  rm -rf "$temp_dir"
  git clone --branch "$BRANCH" "$REPO_URL" "$temp_dir" || {
    echo "[ERREUR] Impossible de cloner le dépôt."
    pause_ou_touche
    return 1
  }

  echo "📁 Synchronisation des fichiers (hors .git)..."
  rsync -a --exclude='.git' "$temp_dir/" "$script_dir/"
  rm -rf "$temp_dir"

  echo "✅ Mowgli Installer mis à jour avec succès depuis $REPO_URL ($BRANCH)."
  pause_ou_touche
}
