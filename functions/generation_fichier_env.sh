#!/bin/bash
# functions/generation_fichier_env.sh
# Génère ou met à jour le fichier .env dans mowgli-docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$SCRIPT_DIR/functions/utils.sh" ] && source "$SCRIPT_DIR/functions/utils.sh"

generation_env() {
  local target_dir="$HOME/mowgli-docker"
  local env_file="$target_dir/.env"
  local example_file="$target_dir/.env.example"
  local compose_file="$target_dir/docker-compose.yaml"

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

  # Vérifie que l'interface wlan0 est active
  if ! ip link show wlan0 | grep -q "state UP"; then
    echo "❌ Le robot n’est pas connecté en WiFi (interface wlan0 inactive)."
    echo "ℹ️  Veuillez connecter le Raspberry Pi en WiFi avant de continuer."
    pause_ou_touche
    return 1
  fi

  # Récupère l’IP WiFi
  local detected_ip
  detected_ip=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  if [ -z "$detected_ip" ]; then
    echo "❌ Impossible de récupérer l’adresse IP WiFi du Raspberry Pi."
    echo "ℹ️  Vérifiez que vous êtes bien connecté à un réseau via wlan0."
    pause_ou_touche
    return 1
  fi

  read -p "Adresse IP de ROS (ROS_IP) [$detected_ip] : " ros_ip
  ros_ip=${ros_ip:-$detected_ip}

  read -p "Adresse IP du robot (MOWER_IP) [$detected_ip] : " mower_ip
  mower_ip=${mower_ip:-$detected_ip}

  read -p "Adresse du broker MQTT (MQTT_BROKER) [$detected_ip] : " mqtt_broker
  mqtt_broker=${mqtt_broker:-$detected_ip}

  sed -i "s/^ROS_IP=.*/ROS_IP=$ros_ip/" "$env_file" || echo "ROS_IP=$ros_ip" >> "$env_file"
  sed -i "s/^MOWER_IP=.*/MOWER_IP=$mower_ip/" "$env_file" || echo "MOWER_IP=$mower_ip" >> "$env_file"
  sed -i "s/^MQTT_BROKER=.*/MQTT_BROKER=$mqtt_broker/" "$env_file" || echo "MQTT_BROKER=$mqtt_broker" >> "$env_file"

  echo "✅ Fichier .env mis à jour avec :"
  grep -E 'ROS_IP|MOWER_IP|MQTT_BROKER' "$env_file"

  # Redémarrage auto si docker-compose est présent
  if [ -f "$compose_file" ]; then
    echo
    echo "🔁 Le fichier docker-compose.yaml a été détecté."
    if ask_update_if_exists "Souhaitez-vous redémarrer les conteneurs Docker pour appliquer les nouvelles variables ?"; then
      cd "$target_dir" || return 1
      docker compose down
      docker compose up -d
      cd - > /dev/null
      echo "✅ Conteneurs redémarrés avec succès."
    fi
  fi

  pause_ou_touche
}
