#!/bin/bash
# functions/mise_a_jour_systeme.sh
# Mise à jour complète du système

mise_a_jour_systeme() {
  echo "🔄 Vérification des mises à jour système..."
  mapfile -t updates < <(apt list --upgradeable 2>/dev/null | sed '1d')

  if [ ${#updates[@]} -eq 0 ]; then
    echo "[OK] Aucune mise à jour disponible."
    pause_ou_touche
    return 0
  fi

  echo "🔔 Mises à jour disponibles : ${#updates[@]}"
  printf '%s\n' "${updates[@]}"
  if ask_update_if_exists "Souhaitez-vous appliquer les mises à jour ?"; then
    echo "📦 Mise à jour du système en cours..."
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    echo "[OK] Système mis à jour avec succès."
  else
    echo "⏭️  Mise à jour système ignorée."
  fi

  pause_ou_touche
}
