#!/bin/bash
# functions/utils.sh
# Fonctions utilitaires globales

pause_ou_touche() {
  echo
  echo "[INFO] Appuyez sur une touche pour continuer ou attendez 10 secondes..."
  read -t 10 -n 1 -s || true
  echo
}

ask_update_if_exists() {
  local message="$1"
  echo -n "$message (y/N) : "
  read -r answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

sauvegarder_fichier() {
  local fichier="$1"
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local backup_dir="$script_dir/backups"

  if [ -f "$fichier" ]; then
    mkdir -p "$backup_dir"
    local base
    base=$(basename "$fichier")
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local dest="$backup_dir/${base}.${timestamp}.bak"

    cp "$fichier" "$dest"
    echo "[INFO] Sauvegarde créée : $dest"

    # Supprimer les anciennes sauvegardes (ne conserver que les 2 plus récentes)
    local count
    count=$(ls -1 "$backup_dir"/${base}.*.bak 2>/dev/null | wc -l)
    if [ "$count" -gt 2 ]; then
      ls -1t "$backup_dir"/${base}.*.bak | tail -n +3 | xargs -r rm --
      echo "[INFO] Anciennes sauvegardes supprimées (max 2 conservées)."
    fi
  else
    echo "[WARN] Aucun fichier à sauvegarder : $fichier introuvable"
  fi
}

print_module_status() {
  local code="$1" label="$2" desc="$3"
  local value=$(grep "^$code=" "$STATUS_FILE" 2>/dev/null | cut -d= -f2)
  case "$value" in
    done) printf "[✅] %s) %-30s -> %s\n" "$code" "$label" "$desc" ;;
    *)    printf "[⏳] %s) %-30s -> à faire\n" "$code" "$label" ;;
  esac
}
