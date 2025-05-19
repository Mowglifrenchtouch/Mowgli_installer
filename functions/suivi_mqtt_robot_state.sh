#!/bin/bash
# functions/suivi_mqtt_robot_state.sh
# Suivi en temps réel du topic MQTT robot/state

suivi_mqtt_robot_state() {
  local mqtt_host mqtt_port
  local mqtt_topic="robot/state"
  local env_file="$HOME/mowgli-docker/.env"

  echo "=== Suivi MQTT du topic : $mqtt_topic ==="

  # Vérifie si mosquitto_sub est installé
  if ! command -v mosquitto_sub >/dev/null 2>&1; then
    echo "Installation de mosquitto-clients..."
    sudo apt update
    sudo apt install -y mosquitto-clients
  fi

  # Récupère MQTT_BROKER et MQTT_PORT depuis .env si dispo
  if [ -f "$env_file" ]; then
    mqtt_host=$(grep -E '^MQTT_BROKER=' "$env_file" | cut -d= -f2 | tr -d '\r\n')
    mqtt_port=$(grep -E '^MQTT_PORT=' "$env_file" | cut -d= -f2 | tr -d '\r\n')
  fi

  # Valeurs par défaut ou saisies
  mqtt_host=${mqtt_host:-localhost}
  mqtt_port=${mqtt_port:-1883}

  read -p "Adresse du broker MQTT [$mqtt_host] : " input_host
  read -p "Port MQTT [$mqtt_port] : " input_port

  mqtt_host=${input_host:-$mqtt_host}
  mqtt_port=${input_port:-$mqtt_port}

  echo
  echo "🟢 Connexion à $mqtt_host:$mqtt_port (topic $mqtt_topic)"
  echo "Appuyez sur Ctrl+C pour quitter"
  echo

  # Test de connectivité avant tentative de souscription
  if ! timeout 2 bash -c "</dev/tcp/$mqtt_host/$mqtt_port" 2>/dev/null; then
    echo "❌ Impossible de se connecter à $mqtt_host:$mqtt_port"
    pause_ou_touche
    return 1
  fi

  # Abonnement MQTT
  mosquitto_sub -h "$mqtt_host" -p "$mqtt_port" -t "$mqtt_topic"
}
