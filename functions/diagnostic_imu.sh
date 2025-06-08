#!/bin/bash

# diagnostic_imu.sh
# Diagnostic de l'IMU via la carte mère Mowgli connectée en USB

SCRIPT_NAME="Diagnostic IMU"
RESUME_FILE="/tmp/diagnostic_imu_resume.txt"

echo "[🔍] $SCRIPT_NAME - Démarrage..."
echo "[🧾] Résumé du diagnostic :" > "$RESUME_FILE"

# Recherche d'un ST-Link (USB vers carte mère YardForce/Mowgli)
IMU_USB_PORT=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -n 1)

if [ -z "$IMU_USB_PORT" ]; then
  echo "[❌] Aucun port USB pour la carte mère/IMU n'a été détecté." | tee -a "$RESUME_FILE"
  echo "[💡] Assurez-vous que la carte mère est bien connectée en USB."
else
  echo "[🔌] Port détecté : $IMU_USB_PORT" | tee -a "$RESUME_FILE"

  echo "[📡] Lecture de trames IMU sur $IMU_USB_PORT..."
  sudo timeout 3 cat "$IMU_USB_PORT" > /tmp/imu_output.log

  if grep -aE '\$IMU|\$YPR' /tmp/imu_output.log >/dev/null; then
    echo "  ➕ Trames IMU (YPR/NMEA) détectées." | tee -a "$RESUME_FILE"
  elif grep -aE 'ACC|GYRO|MAG' /tmp/imu_output.log >/dev/null; then
    echo "  ➕ Trames brut de capteur détectées (accéléro, gyroscope, magnéto)." | tee -a "$RESUME_FILE"
  else
    echo "  ⚠️  Aucune trame identifiable. IMU absente ou mal configurée." | tee -a "$RESUME_FILE"
  fi

  echo "  └── Contenu extrait :" >> "$RESUME_FILE"
  cat /tmp/imu_output.log >> "$RESUME_FILE"
  echo >> "$RESUME_FILE"

  rm -f /tmp/imu_output.log
fi

echo "[✅] Diagnostic IMU terminé. Résumé disponible dans : $RESUME_FILE"
