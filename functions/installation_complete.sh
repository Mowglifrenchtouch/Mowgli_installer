#!/bin/bash
# functions/installation_complete.sh
# Installation complète locale des modules nécessaires pour Mowgli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

installation_complete() {
  echo "=== Installation complète locale ==="
  echo "[INFO] Chaque étape sera exécutée avec statut idempotent."

  # Exécute chaque module et marque comme terminé
  wrap_and_mark_done U mise_a_jour_systeme
  wrap_and_mark_done J configuration_uart
  wrap_and_mark_done G configuration_gps
  wrap_and_mark_done D install_docker
  wrap_and_mark_done C clonage_depot_mowgli_docker
  wrap_and_mark_done E generation_env
  wrap_and_mark_done O deploiement_conteneurs
  wrap_and_mark_done M suivi_mqtt_robot_state

  echo
  echo "✅ Installation complète terminée."
  pause_ou_touche
}
