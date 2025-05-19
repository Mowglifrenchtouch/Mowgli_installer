#!/bin/bash
# functions/generation_fichier_env.sh

generation_env() {
  local target_dir="$HOME/mowgli-docker"
  local env_file="$target_dir/.env"
  local example_file="$target_dir/.env.example"

  echo "=== Génération / mise à jour du fichier .env ==="

  if [ ! -d "$target_dir" ]; then
    echo "[ERREUR] Le dossier $target_dir n'existe pas. Clonez-le d'abord avec l'option C)."
    pause_ou_touche
    return 1
  fi

  if [ ! -f "$env_file" ]; then
    if [ -f "$example_file" ]; then
      cp "$example_file" "$env_file"
      echo "[OK] Fichier .env créé à partir de .env.example"
    else
      echo "[ERREUR] Aucun fichier .env ni .env.example trouvé."
      pause_ou_touche
      return 1
    fi
  else
    echo "✅ Fichier .env déjà présent dans $target_dir"
    if ! ask_update_if_exists "Souhaitez-vous mettre à jour les variables ROS_IP / MOWER_IP / MQTT_BROKER ?"; then
      echo "⏭️  Mise à jour ignorée."
      pause_ou_touche
      return
    fi
    sauvegarder_fichier "$env_file"
  fi

  # Détection automatique IP locale
  local detected_ip
  detected_ip=$(hostname -I | awk '{print $1}')

  read -p "Adresse IP de ROS (ROS_IP) [${detected_ip}] : " ros_ip
  ros_ip=${ros_ip:-$detected_ip}

  read -p "Adresse IP du robot (MOWER_IP) [192.168.1.200] : " mower_ip
  mower_ip=${mower_ip:-192.168.1.200}

  read -p "Adresse du broker MQTT (MQTT_BROKER) [localhost] : " mqtt_broker
  mqtt_broker=${mqtt_broker:-localhost}

  # Mise à jour du fichier
  sed -i "s/^ROS_IP=.*/ROS_IP=$ros_ip/" "$env_file"
  sed -i "s/^MOWER_IP=.*/MOWER_IP=$mower_ip/" "$env_file"
  sed -i "s/^MQTT_BROKER=.*/MQTT_BROKER=$mqtt_broker/" "$env_file"

  echo "[OK] Fichier .env mis à jour avec :"
  grep -E 'ROS_IP|MOWER_IP|MQTT_BROKER' "$env_file"

  pause_ou_touche
}
