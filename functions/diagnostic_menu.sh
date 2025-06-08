#!/bin/bash
# diagnostic_menu.sh : Menu général de diagnostic Mowgli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

menu_diagnostic_mowgli() {
  while true; do
    clear
    echo "===== MENU DIAGNOSTIC DE DÉPANNAGE ====="
    echo "1) Diagnostic GPS complet (USB/NMEA/UBX)"
    echo "2) Voir le dernier diagnostic GPS résumé"
    echo "3) Voir les logs GPS"
    echo "4) Test de connexion IMU via carte mère"
    echo "5) Voir le dernier diagnostic IMU résumé"
    echo "6) Voir les logs IMU"
    echo "7) Retour au menu principal"
    echo
    read -p "Choix> " diag_choice
    case "$diag_choice" in
      1)
        echo "[INFO] Lancement du diagnostic GPS..."
        bash "$SCRIPT_DIR/functions/diagnostique_gps.sh"
        if grep -q '\[ERREUR\]' /tmp/diagnostic_gps_resume.txt 2>/dev/null; then
          echo
          echo "[⚠️] Une erreur a été détectée dans le diagnostic GPS. Affichage des logs :"
          cat /tmp/diagnostic_gps_debug.log 2>/dev/null || echo "[⚠️] Aucun fichier de log détaillé trouvé."
        fi
        read -n1 -r -p "Appuyez sur une touche pour continuer..." key
        ;;
      2)
        if [ -f /tmp/diagnostic_gps_resume.txt ]; then
          echo "[📋] Contenu du dernier diagnostic GPS :"
          echo
          echo "🕒 Date : $(stat -c %y /tmp/diagnostic_gps_resume.txt | cut -d'.' -f1)"
          RUNNING_DOCKERS=$(docker ps -q | wc -l)
          echo "🐳 Nombre de conteneurs Docker en cours : $RUNNING_DOCKERS (doit être 0 pour tester le GPS)"
          echo
          cat /tmp/diagnostic_gps_resume.txt
          echo
          read -p "Souhaitez-vous afficher les logs détaillés ? (o/N) : " show_logs
          if [[ "$show_logs" =~ ^[OoYy]$ ]]; then
            LOG_FILE="/tmp/diagnostic_gps_debug.log"
            if [ -f "$LOG_FILE" ]; then
              echo
              echo "📄 Logs détaillés :"
              cat "$LOG_FILE"
            else
              echo "[⚠️] Aucun fichier de log détaillé trouvé."
            fi
          fi
        else
          echo "[⚠️] Aucun diagnostic GPS trouvé."
        fi
        read -n1 -r -p "Appuyez sur une touche pour continuer..." key
        ;;
      3)
        LOG_FILE="/tmp/diagnostic_gps_debug.log"
        if [ -f "$LOG_FILE" ]; then
          echo "📄 Logs GPS détaillés :"
          cat "$LOG_FILE"
        else
          echo "[⚠️] Aucun fichier de log GPS trouvé."
        fi
        read -n1 -r -p "Appuyez sur une touche pour continuer..." key
        ;;
      4)
        echo "[INFO] Test de connexion IMU..."
        bash "$SCRIPT_DIR/functions/diagnostic_imu.sh"
        if grep -q '\[ERREUR\]' /tmp/diagnostic_imu_resume.txt 2>/dev/null; then
          echo
          echo "[⚠️] Une erreur a été détectée dans le diagnostic IMU. Affichage des logs :"
          cat /tmp/diagnostic_imu_debug.log 2>/dev/null || echo "[⚠️] Aucun fichier de log détaillé trouvé."
        fi
        read -n1 -r -p "Appuyez sur une touche pour continuer..." key
        ;;
      5)
        if [ -f /tmp/diagnostic_imu_resume.txt ]; then
          echo "[📋] Contenu du dernier diagnostic IMU :"
          echo
          echo "🕒 Date : $(stat -c %y /tmp/diagnostic_imu_resume.txt | cut -d'.' -f1)"
          RUNNING_DOCKERS=$(docker ps -q | wc -l)
          echo "🐳 Nombre de conteneurs Docker en cours : $RUNNING_DOCKERS (doit être 0 pour un test propre)"
          echo
          cat /tmp/diagnostic_imu_resume.txt
          echo
          read -p "Souhaitez-vous afficher les logs détaillés ? (o/N) : " show_logs
          if [[ "$show_logs" =~ ^[OoYy]$ ]]; then
            LOG_FILE="/tmp/diagnostic_imu_debug.log"
            if [ -f "$LOG_FILE" ]; then
              echo
              echo "📄 Logs détaillés :"
              cat "$LOG_FILE"
            else
              echo "[⚠️] Aucun fichier de log détaillé trouvé."
            fi
          fi
        else
          echo "[⚠️] Aucun diagnostic IMU trouvé."
        fi
        read -n1 -r -p "Appuyez sur une touche pour continuer..." key
        ;;
      6)
        LOG_FILE="/tmp/diagnostic_imu_debug.log"
        if [ -f "$LOG_FILE" ]; then
          echo "📄 Logs IMU détaillés :"
          cat "$LOG_FILE"
        else
          echo "[⚠️] Aucun fichier de log IMU trouvé."
        fi
        read -n1 -r -p "Appuyez sur une touche pour continuer..." key
        ;;
      7)
        break
        ;;
      *)
        echo "[ERREUR] Choix invalide."
        sleep 1
        ;;
    esac
  done
}
