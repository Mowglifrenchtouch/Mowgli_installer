#!/bin/bash
# functions/mise_a_jour_mowgli_installer.sh
# Mise à jour automatique du Mowgli Installer depuis un dépôt Git

mise_a_jour_installer() {
  local script_dir="$HOME/mowgli-installer"
  local config_file="$script_dir/update_installer.conf"
  local temp_dir="$HOME/.mowgli-installer-update"

  # Si fichier de config absent, on copie un exemple
  if [ ! -f "$config_file" ]; then
    cp "$script_dir/update_installer.conf.example" "$config_file"
    echo "[WARN] Exemple de config créé à $config_file"
    echo "       Modifiez ce fichier pour définir votre dépôt."
    return
  fi

  # Nettoyage éventuel CRLF
  sed -i '1 s/^\xEF\xBB\xBF//' "$config_file"
  sed -i 's/\r$//' "$config_file"

  # Lecture de la config
  source "$config_file"

  echo "-> Mise à jour depuis $REPO_URL [$BRANCH]..."

  # Clonage en dossier temporaire
  rm -rf "$temp_dir"
  git clone --branch "$BRANCH" "$REPO_URL" "$temp_dir" || {
    echo "[ERREUR] Impossible de cloner le dépôt."
    return 1
  }

  # Copie des fichiers vers l'installateur actuel (sauf .git)
  rsync -a --exclude=".git" "$temp_dir/" "$script_dir/"
  rm -rf "$temp_dir"

  echo "[OK] Mowgli Installer mis à jour depuis $REPO_URL ($BRANCH)."
}
