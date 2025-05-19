#!/bin/bash
# functions/configuration_mode_distant_ser2net.sh
# Fournit des instructions et v√©rifie les pr√©requis pour le mode distant via ser2net

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

configuration_mode_distant() {
  echo "-> Configuration pour le mode distant (communication via ser2net)"
  echo

  echo "[INFO] Ce mode est utilis√© lorsque le robot transmet ses ports UART (IMU, GPS, etc.) √† un serveur distant."
  echo "[INFO] Les services ROS (ex : open_mower_ros) doivent tourner sur une machine distante."
  echo

  echo "Ì†ΩÌ≥ñ Tutoriel complet disponible ici :"
  echo "Ì†ΩÌ¥ó https://juditech3d.github.io/Guide-DIY-OpenMower-Mowgli-pour-Robots-Tondeuses-Yard500-et-500B/ser2net/"
  echo

  echo "Ì†ΩÌ¥ç V√©rification rapide de ser2net :"
  if systemctl is-active --quiet ser2net; then
    echo "[OK] Le service ser2net est actif."
  else
    echo "[WARN] Le service ser2net n'est pas actif ou non install√©."
    echo "Vous pouvez l'installer avec : sudo apt install ser2net"
  fi

  echo
  read -p "Souhaitez-vous consulter la configuration actuelle ? (o/N) : " voir
  if [[ "$voir" =~ ^[Oo]$ ]]; then
    echo
    if [ -f /etc/ser2net.conf ]; then
      echo "Contenu de /etc/ser2net.conf :"
      echo "----------------------------------------------------"
      grep -v '^#' /etc/ser2net.conf | grep -v '^$'
      echo "----------------------------------------------------"
    else
      echo "[ERREUR] Fichier de configuration introuvable."
    fi
  fi

  echo
  echo "[FIN] Cette configuration doit √™tre compl√©t√©e manuellement selon vos ports UART."
  pause_ou_touche
}
