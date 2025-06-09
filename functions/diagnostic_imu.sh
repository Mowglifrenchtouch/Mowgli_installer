#!/bin/bash

# diagnostic_imu.sh
# Diagnostic de l'IMU via la carte mère Mowgli connectée en USB

SCRIPT_NAME="Diagnostic IMU"
RESUME_FILE="/tmp/diagnostic_imu_resume.txt"
LOG_FILE="/tmp/diagnostic_imu_debug.log"

DATE_EXEC=$(date "+%d/%m/%Y %H:%M:%S")
echo "[🔍] $SCRIPT_NAME - Démarrage..." | tee "$LOG_FILE"
echo "[🧾] Résumé du diagnostic :" > "$RESUME_FILE"
echo "🕒 Date du test : $DATE_EXEC" >> "$RESUME_FILE"

# Compter les conteneurs Docker actifs
RUNNING_DOCKERS=$(docker ps -q | wc -l)
echo "🐳 Conteneurs Docker actifs : $RUNNING_DOCKERS (doit être > 0 pour la détection de l'IMU)" >> "$RESUME_FILE"

if [ "$RUNNING_DOCKERS" -eq 0 ]; then
  echo "[❌] Aucun conteneur Docker actif. L'IMU ne pourra pas être détectée." | tee -a "$RESUME_FILE" "$LOG_FILE"
  echo "[💡] Veuillez lancer les conteneurs Docker avant de relancer ce test." | tee -a "$RESUME_FILE" "$LOG_FILE"
  echo -n "[❓] Voulez-vous forcer le redémarrage des conteneurs maintenant ? (o/N) : "
  read -r restart_choice
  if [[ "$restart_choice" =~ ^[OoYy]$ ]]; then
    echo "[🚀] Redémarrage des conteneurs Docker..." | tee -a "$RESUME_FILE" "$LOG_FILE"
    docker compose down && docker compose up -d
    echo "[✅] Conteneurs relancés avec succès." | tee -a "$RESUME_FILE" "$LOG_FILE"
    docker ps --format "table {{.Names}}\t{{.Status}}" | tee -a "$RESUME_FILE" "$LOG_FILE"
    echo "[ℹ️] Veuillez relancer le diagnostic maintenant que les services sont actifs."
  fi
  exit 1
fi

# Vérification de la connexion USB de la carte mère
IMU_USB_PORT=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -n 1)
if [ -z "$IMU_USB_PORT" ]; then
  echo "[❌] Aucun port USB pour la carte mère/IMU n'a été détecté." | tee -a "$RESUME_FILE" "$LOG_FILE"
  echo "[💡] Assurez-vous que la carte mère est bien connectée en USB." | tee -a "$RESUME_FILE" "$LOG_FILE"
else
  echo "[🔌] Port détecté : $IMU_USB_PORT (USB vers carte mère YardForce/Mowgli)" | tee -a "$RESUME_FILE" "$LOG_FILE"
fi

# Détection automatique du chemin imu.sh
USER_HOME=$(getent passwd "$USER" | cut -d: -f6)
IMU_SCRIPT="$USER_HOME/mowgli-docker/utils/imu.sh"
if [ ! -f "$IMU_SCRIPT" ]; then
  echo "[❌] Fichier imu.sh introuvable à l'emplacement attendu : $IMU_SCRIPT" | tee -a "$RESUME_FILE" "$LOG_FILE"
  exit 1
fi

# Appel du script imu.sh et récupération des trames
IMU_OUTPUT=$(bash "$IMU_SCRIPT")
echo "$IMU_OUTPUT" | tee -a "$LOG_FILE"
echo "" >> "$RESUME_FILE"
echo "===== EXTRAIT DES DONNÉES IMU =====" >> "$RESUME_FILE"
echo "$IMU_OUTPUT" | head -n 10 >> "$RESUME_FILE"
echo "... (voir log complet dans $LOG_FILE)" >> "$RESUME_FILE"
echo "" >> "$RESUME_FILE"

# Identification de l'IMU
if echo "$IMU_OUTPUT" | grep -q "MPU-6050"; then
  IMU_NAME="MPU-6050"
elif echo "$IMU_OUTPUT" | grep -q "MPU-9250"; then
  IMU_NAME="MPU-9250"
elif echo "$IMU_OUTPUT" | grep -qi "bno085\|bno055"; then
  IMU_NAME="BNO0xx"
elif echo "$IMU_OUTPUT" | grep -qi "icm20948"; then
  IMU_NAME="ICM-20948"
else
  IMU_NAME="Non identifié"
fi

# Vérifier si l'IMU est connectée
if [ "$IMU_NAME" != "Non identifié" ]; then
  echo "🔎 IMU détectée : $IMU_NAME (connectée)" | tee -a "$RESUME_FILE"
else
  echo "🔎 IMU détectée : $IMU_NAME" | tee -a "$RESUME_FILE"
fi

# Résumé filtré
if echo "$IMU_OUTPUT" | grep -q "Trames"; then
  echo "[✔️] Trames IMU détectées avec succès." >> "$RESUME_FILE"
else
  echo "[⚠️] Aucune trame IMU claire détectée." >> "$RESUME_FILE"
fi

# Vérification de la présence de valeurs numériques utiles
if echo "$IMU_OUTPUT" | grep -Eo '[0-9]+\.[0-9]+' | awk '$1 > 0 { exit 0 } END { exit 1 }'; then
  echo "[✔️] Données IMU valides : valeurs numériques supérieures à zéro détectées." >> "$RESUME_FILE"
else
  echo "[⚠️] Aucune valeur numérique exploitable trouvée (>= 0)." >> "$RESUME_FILE"
fi

echo "[✅] Diagnostic IMU terminé. Résumé disponible dans : $RESUME_FILE" | tee -a "$LOG_FILE"
echo

echo "===== 🧾 RÉSUMÉ DU DIAGNOSTIC IMU ====="
cat "$RESUME_FILE"
echo "======================================"
