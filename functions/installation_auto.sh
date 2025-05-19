#!/bin/bash
# functions/installation_auto.sh
# Lancement de l'installation complÃ¨te, en mode local ou distant (ser2net)

installation_auto() {
  echo "===== INSTALLATION COMPLÃTE ====="
  echo "Choisissez le type d'installation Ã  effectuer :"
  echo "1) Locale  : tout sâinstalle ici (robot autonome)"
  echo "2) Distante : robot communique avec un serveur via ser2net"
  read -p "Mode [1 par dÃ©faut] : " mode
  mode=${mode:-1}

  if [[ "$mode" == "1" ]]; then
    installation_complete
  else
    configuration_mode_distant
  fi
}
