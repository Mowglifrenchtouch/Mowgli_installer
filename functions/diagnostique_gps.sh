#!/bin/bash

# diagnostique_gps.sh
# Analyse des ports GPS (F9P / UM980 / UM960)

SCRIPT_NAME="Diagnostic GPS"
DATE_EXEC=$(date "+%d/%m/%Y %H:%M:%S")

# Récupération de la liste des conteneurs actifs
DOCKER_CONTAINERS=$(docker ps -q)
DOCKER_COUNT=$(echo "$DOCKER_CONTAINERS" | wc -w)

# Fichier résumé pour affichage persistant dans le menu
RESUME_FILE="/tmp/diagnostic_gps_resume.txt"

# Affichage du menu si exécuté directement
if [[ "$0" == *"diagnostique_gps.sh" ]]; then
  echo "[🔍] $SCRIPT_NAME - Démarrage..."

  echo "[🕒] Date du test : $DATE_EXEC" > "$RESUME_FILE"
  echo "🐳 Conteneurs Docker actifs : $DOCKER_COUNT (doit être 0 pour la libération de /dev/gps)" >> "$RESUME_FILE"

  echo "[⚠️] Cette action va interrompre temporairement tous les conteneurs Docker Mowgli."
  echo "Cela peut perturber une session de tonte en cours."
  echo -n "Souhaitez-vous continuer ? (y/N) : "
  read -r CONTINUE
  if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
    echo "[❌] Opération annulée par l'utilisateur."
    exit 1
  fi

  echo "[📦] Arrêt temporaire des conteneurs Docker pour libérer /dev/gps..."
  docker ps --format "- {{.Names}} ({{.Image}})"
  sleep 1
  docker stop $DOCKER_CONTAINERS >/dev/null

  # Délai pour libération des ports
  sleep 2

  echo "[🔎] Recherche des ports GPS USB..."
  PORTS=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null)
  echo >> "$RESUME_FILE"

  if [ -z "$PORTS" ]; then
    echo "[❌] Aucun port /dev/ttyACM* ou /dev/ttyUSB* détecté." | tee -a "$RESUME_FILE"
    echo "[💡] Vérifiez que votre module GPS est bien branché en USB." | tee -a "$RESUME_FILE"
  else
    for PORT in $PORTS; do
      echo "[🧪] Test du port : $PORT"
      sudo timeout 3 head -c 512 "$PORT" | hexdump -C > /tmp/gps_output.hex
      HEX_CONTENT=$(cat /tmp/gps_output.hex)

      if echo "$HEX_CONTENT" | grep -aE '\$G.G|\$..RMC' >/dev/null; then
        echo "  ➕ Trames NMEA détectées sur $PORT." | tee -a "$RESUME_FILE"
        echo "===== EXTRAIT DES DONNÉES NMEA SUR $PORT =====" >> "$RESUME_FILE"
        echo "$HEX_CONTENT" | grep -aE '\$G.G|\$..RMC' | head -n 5 >> "$RESUME_FILE"
        echo "... (voir log complet non affiché)" >> "$RESUME_FILE"
      elif echo "$HEX_CONTENT" | grep -a "b5 62" >/dev/null; then
        echo "  ➕ Trames UBX détectées sur $PORT." | tee -a "$RESUME_FILE"
        echo "  💡 Unicore ou u-blox en mode UBX détecté. Pensez à activer NMEA si nécessaire." | tee -a "$RESUME_FILE"
        echo "===== EXTRAIT DES DONNÉES UBX SUR $PORT =====" >> "$RESUME_FILE"
        echo "$HEX_CONTENT" | grep -a "b5 62" | head -n 5 >> "$RESUME_FILE"
        echo "... (voir log complet non affiché)" >> "$RESUME_FILE"
      else
        echo "  ⚠️  Aucune trame connue détectée sur $PORT." | tee -a "$RESUME_FILE"
        echo "  ❔ Vérifiez la configuration du module (baudrate, protocole)." | tee -a "$RESUME_FILE"
        echo "===== CONTENU HEXADÉCIMAL BRUT $PORT =====" >> "$RESUME_FILE"
        echo "$HEX_CONTENT" | head -n 10 >> "$RESUME_FILE"
        echo "..." >> "$RESUME_FILE"
      fi

      echo >> "$RESUME_FILE"
    done
  fi

  # Nettoyage
  rm -f /tmp/gps_output.hex

  # Redémarrage des conteneurs
  if [ -n "$DOCKER_CONTAINERS" ]; then
    echo "[🚀] Redémarrage des conteneurs Docker..."
    docker start $DOCKER_CONTAINERS >/dev/null
    echo "[✅] Conteneurs relancés avec succès." | tee -a "$RESUME_FILE"
    docker ps --format "table {{.Names}}\t{{.Status}}" | tee -a "$RESUME_FILE"
  fi

  echo "[✅] Diagnostic GPS terminé. Résumé enregistré dans : $RESUME_FILE"
fi
