#!/bin/bash
# functions/configuration_mode_distant_ser2net.sh
# Fournit des instructions et vérifie les prérequis pour le mode distant via ser2net

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_mode_distant() {
  echo "=== Mode distant : communication via ser2net ==="
  echo
  echo "[INFO] Ce mode est utilisé lorsque le robot transmet ses ports UART (IMU, GPS, etc.) à un serveur distant."
  echo "[INFO] Les services ROS (ex : open_mower_ros) doivent tourner sur une machine distante (PC ou serveur)."
  echo

  echo "📘 Tutoriel complet disponible ici :"
  echo "🔗 https://juditech3d.github.io/Guide-DIY-OpenMower-Mowgli-pour-Robots-Tondeuses-Yard500-et-500B/ser2net/"
  echo

  echo "🔍 Vérification du service ser2net..."
  if systemctl is-active --quiet ser2net; then
    echo "✅ Le service ser2net est actif."
  else
    echo "⚠️  Le service ser2net n'est pas actif ou non installé."
    echo "ℹ️  Pour l'installer : sudo apt install ser2net"
  fi

  echo
  read -p "Souhaitez-vous consulter le contenu actuel de /etc/ser2net.conf ? (o/N) : " voir
  if [[ "$voir" =~ ^[Oo]$ ]]; then
    echo
    if [ -f /etc/ser2net.conf ]; then
      echo "📄 Contenu de /etc/ser2net.conf :"
      echo "----------------------------------------------------"
      grep -vE '^\s*#|^$' /etc/ser2net.conf
      echo "----------------------------------------------------"
    else
      echo "❌ Fichier de configuration introuvable."
    fi
  fi

  echo
  echo "🛠️ Cette configuration doit être adaptée manuellement selon vos ports UART et besoins réseau."
  pause_ou_touche
}
