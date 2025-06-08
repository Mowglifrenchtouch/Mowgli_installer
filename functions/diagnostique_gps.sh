#!/bin/bash

# diagnostique_gps.sh
# Analyse des ports GPS (F9P / UM980 / UM960)

SCRIPT_NAME="Diagnostic GPS"

# Récupération de la liste des conteneurs actifs
DOCKER_CONTAINERS=$(docker ps -q)

# Fichier résumé pour affichage persistant dans le menu
RESUME_FILE="/tmp/diagnostic_gps_resume.txt"

# Affichage du menu si exécuté directement
if [[ "$0" == *"diagnostique_gps.sh" ]]; then
  echo "[🔍] $SCRIPT_NAME - Démarrage..."

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
  echo "[🧾] Résumé du diagnostic :" > "$RESUME_FILE"

  if [ -z "$PORTS" ]; then
    echo "[❌] Aucun port /dev/ttyACM* ou /dev/ttyUSB* détecté." | tee -a "$RESUME_FILE"
    echo "[💡] Vérifiez que votre module GPS est bien branché en USB."
  else
    for PORT in $PORTS; do
      echo "[🧪] Test du port : $PORT"
      sudo timeout 3 head -c 512 "$PORT" | hexdump -C | tee /tmp/gps_output.hex

      if grep -aE '\$G.G|\$..RMC' /tmp/gps_output.hex >/dev/null; then
        echo "  ➕ Trames NMEA détectées sur $PORT." | tee -a "$RESUME_FILE"
      elif grep -a "b5 62" /tmp/gps_output.hex >/dev/null; then
        echo "  ➕ Trames UBX détectées sur $PORT." | tee -a "$RESUME_FILE"
        echo "  💡 Unicore ou u-blox en mode UBX détecté. Pensez à activer NMEA si nécessaire." | tee -a "$RESUME_FILE"
      else
        echo "  ⚠️  Aucune trame connue détectée sur $PORT." | tee -a "$RESUME_FILE"
        echo "  ❔ Vérifiez la configuration du module (baudrate, protocole)." | tee -a "$RESUME_FILE"
      fi

      echo "  └── Contenu hexadécimal :" >> "$RESUME_FILE"
      cat /tmp/gps_output.hex >> "$RESUME_FILE"
      echo >> "$RESUME_FILE"
    done
  fi

  # Nettoyage
  rm -f /tmp/gps_output.hex

  # Redémarrage des conteneurs
  if [ -n "$DOCKER_CONTAINERS" ]; then
    echo "[🚀] Redémarrage des conteneurs Docker..."
    docker start $DOCKER_CONTAINERS >/dev/null
  fi

  echo "[✅] Diagnostic terminé. Résumé enregistré dans : $RESUME_FILE"
fi
