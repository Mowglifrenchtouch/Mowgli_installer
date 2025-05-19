#!/bin/bash
# functions/personalisation_logo_motd.sh
# Remplace le logo MOTD par un fichier personnalisé

personalisation_logo() {
  local logo_source="$HOME/mowgli-installer/assets/logo.txt"
  local target_file="/etc/motd"

  echo "-> Personnalisation du logo affiché au démarrage..."

  if [ ! -f "$logo_source" ]; then
    echo "[ERREUR] Le fichier $logo_source n'existe pas."
    echo "Créez votre logo ASCII personnalisé dans ce fichier."
    return 1
  fi

  # Sauvegarde automatique
  if [ -f "$target_file" ]; then
    sauvegarder_fichier "$target_file"
  fi

  # Si déjà identique, ne rien faire
  if cmp -s "$logo_source" "$target_file"; then
    echo "[INFO] Le logo est déjà à jour. Aucun changement nécessaire."
    return 0
  fi

  echo "Copie de $logo_source vers $target_file"
  sudo cp "$logo_source" "$target_file"

  echo "[OK] Logo MOTD mis à jour. Il s'affichera à la prochaine connexion terminal."
  pause_ou_touche
}
