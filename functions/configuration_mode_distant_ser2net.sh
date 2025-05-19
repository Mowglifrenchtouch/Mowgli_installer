#!/bin/bash
# functions/configuration_mode_distant_ser2net.sh
# Fournit des instructions et vérifie les prérequis pour le mode distant via ser2net

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_mode_distant() {
  echo "=== Mode distant : communication via ser2net ==="
  echo
  echo "[INFO] Ce mode est utilisé lorsque le robot transmet ses ports UART (IMU, GPS, etc.)"
  echo "       à une machine distante (comme un serveur ou un PC hébergeant ROS)."
  echo
  echo "📘 Tutoriel en ligne :"
  echo "🔗 https://juditech3d.github.io/Guide-DIY-OpenMower-Mowgli-pour-Robots-Tondeuses-Yard500-et-500B/ser2net/"
  echo

  echo "🔍 Vérification du service ser2net..."
  if systemctl is-active --quiet ser2net; then
    echo "✅ Le service ser2net est actif."
  else
    echo "⚠️  Le service ser2net n'est pas actif ou non installé."
    echo "➡️  Pour l'installer : sudo apt install ser2net"
  fi

  echo
  read -p "Souhaitez-vous afficher le contenu de /etc/ser2net.conf ? (o/N) : " voir
  if [[ "$voir" =~ ^[Oo]$ ]]; then
    echo
    if [ -f /etc/ser2net.conf ]; then
      echo "📄 Contenu de /etc/ser2net.conf (hors commentaires) :"
      echo "----------------------------------------------------"
      grep -vE '^\s*#|^$' /etc/ser2net.conf
      echo "----------------------------------------------------"
    else
      echo "❌ Fichier /etc/ser2net.conf introuvable."
    fi
  fi

  echo
  local compose_file="$HOME/mowgli-docker/docker-compose.ser2net.yaml"
  if [ -f "$compose_file" ]; then
    echo "📦 Fichier docker-compose.ser2net.yaml détecté."
    read -p "Souhaitez-vous lancer le conteneur ser2net via Docker ? (o/N) : " docker_ser2net
    if [[ "$docker_ser2net" =~ ^[Oo]$ ]]; then
      echo
      # Vérifie s'il y a déjà des conteneurs Docker actifs
      active_containers=$(docker ps -q | wc -l)
      if [ "$active_containers" -gt 0 ]; then
        echo "⚠️  Des conteneurs Docker sont déjà en cours d'exécution."
        echo "    Cela peut entrer en conflit avec ser2net."
        read -p "Souhaitez-vous les arrêter avant de lancer ser2net ? (o/N) : " stop_docker
        if [[ "$stop_docker" =~ ^[Oo]$ ]]; then
          docker stop $(docker ps -q)
          echo "🛑 Conteneurs arrêtés."
        else
          echo "⏭️  Lancement de ser2net sans interruption des conteneurs existants."
        fi
      fi

      echo "🚀 Démarrage du conteneur ser2net..."
      cd "$HOME/mowgli-docker" || return 1
      docker compose -f docker-compose.ser2net.yaml up -d && echo "✅ Conteneur ser2net lancé."
      cd - > /dev/null
    fi
  else
    echo "ℹ️ Aucun fichier docker-compose.ser2net.yaml trouvé dans ~/mowgli-docker/"
  fi

  echo
  read -p "Souhaitez-vous redémarrer le service ser2net système maintenant ? (o/N) : " redem
  if [[ "$redem" =~ ^[Oo]$ ]]; then
    redemarrer_ser2net
  fi

  echo
  echo "🛠️  Cette configuration doit être ajustée manuellement selon les ports UART exposés et les ports TCP souhaités."
  pause_ou_touche
}

redemarrer_ser2net() {
  echo
  echo "🔄 Redémarrage du service ser2net..."
  sudo systemctl restart ser2net

  echo "🔒 Activation automatique au démarrage..."
  sudo systemctl enable ser2net

  echo "🔍 Vérification du statut..."
  if systemctl is-active --quiet ser2net; then
    echo "✅ Le service ser2net fonctionne correctement."
  else
    echo "❌ Le service ser2net n'a pas pu démarrer correctement."
    echo "🧪 Consultez les logs avec : journalctl -u ser2net -xe"
  fi
}
