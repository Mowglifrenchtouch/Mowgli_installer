#!/bin/bash
# functions/generation_fichier_env.sh
# Génère ou met à jour le fichier .env dans mowgli-docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

generation_env() {
  local target_dir="$HOME/mowgli-docker"
  local env_file="$target_dir/.env"
  local example_file="$target_dir/.env.example"

  echo "=== Génération / mise à jour du fichier .env ==="

  if [ ! -d "$target_dir" ]; then
    echo "[ERREUR] Le dossier $target_dir est introuvable."
    echo "         Veuillez d'abord le cloner via l’option C)."
    pause_ou_touche
    return 1
  fi

  if [ ! -f "$env_file" ]; then
    if [ -f "$example_file" ]; then
      cp "$example_file" "$env_file"
      echo "✅ Fichier .env créé à partir de .env.example"
    else
      echo "[ERREUR] Aucun fichier .env ni .env.example trouvé dans $target_dir"
      pause_ou_touche
      return 1
    fi
  else
    echo "✅ Le fichier .env existe déjà."
    if ! ask_update_if_exists "Souhaitez-vous mettre à jour les variables ROS_IP / MOWER_IP / MQTT_BROKER ?"; then
      echo "⏭️  Mise à jour ignorée."
      pause_ou_touche
      return
    fi
    sauvegarder_fichier "$env_file"
  fi

  local detected_ip
  detected_ip=$(hostname -I | awk '{print $1}')

  read -p "Adresse IP de ROS (ROS_IP) [$detected_ip] : " ros_ip
  ros_ip=${ros_ip:-$detected_ip}

  read -p "Adresse IP du robot (MOWER_IP) [192.168.1.200] : " mower_ip
  mower_ip=${mower_ip:-192.168.1.200}

  read -p "Adresse du broker MQTT (MQTT_BROKER) [localhost] : " mqtt_broker
  mqtt_broker=${mqtt_broker:-localhost}

  sed -i "s/^ROS_IP=.*/ROS_IP=$ros_ip/" "$env_file" || echo "ROS_IP=$ros_ip" >> "$env_file"
  sed -i "s/^MOWER_IP=.*/MOWER_IP=$mower_ip/" "$env_file" || echo "MOWER_IP=$mower_ip" >> "$env_file"
  sed -i "s/^MQTT_BROKER=.*/MQTT_BROKER=$mqtt_broker/" "$env_file" || echo "MQTT_BROKER=$mqtt_broker" >> "$env_file"

  echo "✅ Fichier .env mis à jour avec :"
  grep -E 'ROS_IP|MOWER_IP|MQTT_BROKER' "$env_file"

  pause_ou_touche
}
