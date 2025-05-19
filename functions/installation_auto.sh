#!/bin/bash
# functions/installation_auto.sh
# Lancement de l'installation complète, en mode local ou distant (ser2net)

installation_auto() {
  echo "===== INSTALLATION COMPLÈTE ====="
  echo "Choisissez le type d'installation à effectuer :"
  echo "1) Locale   : tout s’installe ici (robot autonome)"
  echo "2) Distante : le robot communique avec un serveur via ser2net"
  read -p "Mode [1 par défaut] : " mode
  mode=${mode:-1}

  if [[ "$mode" == "1" ]]; then
    installation_complete
  else
    configuration_mode_distant
  fi
}
