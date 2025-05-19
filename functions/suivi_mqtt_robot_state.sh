#!/bin/bash
# functions/suivi_mqtt_robot_state.sh
# Suivi en temps réel du topic MQTT robot/state

suivi_mqtt_robot_state() {
  local mqtt_host mqtt_port
  local mqtt_topic="robot/state"
  local env_file="$HOME/mowgli-docker/.env"

  echo "-> Suivi MQTT du topic : $mqtt_topic"

  # Vérifie si mosquitto-clients est installé
  if ! command -v mosquitto_sub >/dev/null 2>&1; then
    echo "Installation de mosquitto-clients..."
    sudo apt update
    sudo apt install -y mosquitto-clients
  fi

  # Tente de récupérer MQTT_BROKER (et optionnellement MQTT_PORT)
  if [ -f "$env_file" ]; then
    mqtt_host=$(grep -E '^MQTT_BROKER=' "$env_file" | cut -d= -f2)
    mqtt_port=$(grep -E '^MQTT_PORT=' "$env_file" | cut -d= -f2)
  fi

  # Si non défini, on demande à l'utilisateur
  if [ -z "$mqtt_host" ]; then
    read -p "Adresse du broker MQTT [localhost] : " mqtt_host
    mqtt_host=${mqtt_host:-localhost}
  fi

  if [ -z "$mqtt_port" ]; then
    mqtt_port=1883
  fi

  echo
  echo "Connexion au broker MQTT $mqtt_host:$mqtt_port sur le topic : $mqtt_topic"
  echo "Appuyez sur Ctrl+C pour quitter"
  echo

  # Connexion au topic
  mosquitto_sub -h "$mqtt_host" -p "$mqtt_port" -t "$mqtt_topic"
}
