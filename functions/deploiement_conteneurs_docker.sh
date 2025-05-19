#!/bin/bash
# functions/deploiement_conteneurs_docker.sh
# Lance docker compose pour démarrer les conteneurs mowgli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

deploiement_conteneurs() {
  local target_dir="$HOME/mowgli-docker"
  local compose_file="$target_dir/docker-compose.yaml"

  echo "=== Déploiement des conteneurs Docker ==="

  # Vérifie que Docker est bien installé
  if ! command -v docker >/dev/null 2>&1; then
    echo "[ERREUR] Docker n'est pas installé. Veuillez exécuter l'option D) d'abord."
    pause_ou_touche
    return 1
  fi

  # Vérifie que le dossier cible existe
  if [ ! -d "$target_dir" ]; then
    echo "[ERREUR] Le dossier $target_dir n'existe pas. Utilisez l'option C) pour cloner le dépôt."
    pause_ou_touche
    return 1
  fi

  # Vérifie que le fichier docker-compose existe
  if [ ! -f "$compose_file" ]; then
    echo "[ERREUR] Fichier docker-compose.yaml introuvable dans $target_dir"
    pause_ou_touche
    return 1
  fi

  # Vérifie si des conteneurs sont déjà actifs
  local active_containers
  active_containers=$(docker compose -f "$compose_file" ps -q | wc -l)

  if [ "$active_containers" -gt 0 ]; then
    echo "✅ Des conteneurs sont déjà actifs."
    if ! ask_update_if_exists "Souhaitez-vous les redémarrer ?"; then
      echo "⏭️  Déploiement ignoré."
      pause_ou_touche
      return
    fi
  fi

  # Sauvegarde
  sauvegarder_fichier "$compose_file"

  echo "📦 Mise à jour des images (si besoin)..."
  (cd "$target_dir" && docker compose pull)

  echo "🚀 Lancement des conteneurs..."
  (cd "$target_dir" && docker compose up -d)

  echo "✅ Conteneurs actuellement en cours d’exécution :"
  (cd "$target_dir" && docker compose ps)

  pause_ou_touche
}
