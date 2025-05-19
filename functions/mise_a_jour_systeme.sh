#!/bin/bash
# functions/mise_a_jour_systeme.sh
# Mise à jour complète du système

mise_a_jour_systeme() {
  echo "-> Vérification des mises à jour disponibles..."
  mapfile -t updates < <(apt list --upgradeable 2>/dev/null | sed '1d')

  if [ ${#updates[@]} -eq 0 ]; then
    echo "[OK] Aucune mise à jour disponible."
    pause_ou_touche
    return
  fi

  echo "Mises à jour disponibles : ${#updates[@]}"
  printf '%s\n' "${updates[@]}"
  read -p "Voulez-vous appliquer les mises à jour ? (o/N) : " rep
  if [[ "$rep" =~ ^[Oo]$ ]]; then
    echo "-> Mise à jour du système..."
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    echo "[OK] Système mis à jour."
  else
    echo "[ANNULÉ] Mises à jour ignorées."
  fi

  pause_ou_touche
}
