#!/bin/bash
# functions/deploiement_conteneurs_docker.sh
# Lance docker compose pour dÃ©marrer les conteneurs mowgli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

deploiement_conteneurs() {
  local target_dir="$HOME/mowgli-docker"
  local compose_file="$target_dir/docker-compose.yml"

  echo "-> DÃ©ploiement des conteneurs Docker..."

  # VÃ©rifie que Docker est bien installÃ©
  if ! command -v docker >/dev/null 2>&1; then
    echo "[ERREUR] Docker n'est pas installÃ©. Lancez d'abord l'option D)."
    return 1
  fi

  # VÃ©rifie que le dÃ©pÃ´t est bien clonÃ©
  if [ ! -d "$target_dir" ]; then
    echo "[ERREUR] Le dossier $target_dir n'existe pas. Clonez le dÃ©pÃ´t avec l'option C)."
    return 1
  fi

  # VÃ©rifie que le fichier docker-compose existe
  if [ ! -f "$compose_file" ]; then
    echo "[ERREUR] Aucun fichier docker-compose.yml trouvÃ© dans $target_dir"
    return 1
  fi

  # Sauvegarde (si modification future)
  sauvegarder_fichier "$compose_file"

  cd "$target_dir" || return 1

  echo "í ½í´„ Pull des images Docker (si nÃ©cessaire)..."
  docker compose pull

  echo "í ½íº€ DÃ©marrage des conteneurs en arriÃ¨re-plan..."
  docker compose up -d

  echo "âœ… Conteneurs en cours dâ€™exÃ©cution :"
  docker compose ps

  cd - > /dev/null || return 0

  pause_ou_touche
}
