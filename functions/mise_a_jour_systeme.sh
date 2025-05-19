#!/bin/bash
# functions/mise_a_jour_systeme.sh
# Mise à jour complète du système

mise_a_jour_systeme() {
  echo "=== Mise à jour du système ==="
  echo "-> Vérification des mises à jour disponibles..."

  mapfile -t updates < <(apt list --upgradeable 2>/dev/null | sed '1d')

  if [ ${#updates[@]} -eq 0 ]; then
    echo "✅ Aucune mise à jour disponible."
    pause_ou_touche
    return
  fi

  echo "📦 ${#updates[@]} mises à jour disponibles :"
  printf '  • %s\n' "${updates[@]}"

  if ask_update_if_exists "Souhaitez-vous appliquer ces mises à jour ?"; then
    echo "🛠️ Mise à jour en cours..."
    if sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y; then
      echo "✅ Système mis à jour avec succès."
    else
      echo "❌ Une erreur est survenue pendant la mise à jour."
    fi
  else
    echo "⏭️  Mises à jour ignorées."
  fi

  pause_ou_touche
}
