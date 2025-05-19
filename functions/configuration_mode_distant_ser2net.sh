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
  read -p "Souhaitez-vous redémarrer le service ser2net maintenant ? (o/N) : " redem
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
