#!/bin/bash

# Vérification : ne pas exécuter ce script avec sudo
if [ "$EUID" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté avec sudo."
  echo "→ Lance-le avec : ./install-mowgli.sh"
  echo "   (Le script utilisera sudo uniquement quand c'est nécessaire)"
  exit 1
fi

set -e

# Affichage en-tête à chaque étape
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
MAC=$(ip link show eth0 | awk '/ether/ {print $2}')
SSID=$(iwgetid -r 2>/dev/null || echo "non connecté")
UPTIME=$(uptime -p)
TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo "n/a")
LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
MEM=$(free -m | awk '/Mem/ {printf "%d MiB / %d MiB", $3, $2}')
DISK=$(df -h / | awk 'END {print $4 " libres sur " $2}')
ROS_IP=$(grep ROS_IP ~/mowgli-docker/.env 2>/dev/null | cut -d= -f2)
MOWER_IP=$(grep MOWER_IP ~/mowgli-docker/.env 2>/dev/null | cut -d= -f2)
DOCKER_STATUS=$(docker ps -q | wc -l)

cat <<EOBANNER

    __  ___                    ___
   /  |/  /___ _      ______ _/ (_)
  / /|_/ / __ \ | /| / / __ \`/ / / 
 / /  / / /_/ / |/ |/ / /_/ / / /  
/_/  /_/\____/|__/|__/\__, /_/_/   
                     /____/        

Hostname     : $HOSTNAME
IP locale    : $IP
Adresse MAC  : $MAC
Wi-Fi (SSID) : $SSID
Uptime       : $UPTIME
Température  : $TEMP
Charge CPU   : $LOAD
RAM utilisée : $MEM
Disque libre : $DISK

Docker       : $DOCKER_STATUS conteneur(s) actif(s)
ROS_IP       : ${ROS_IP:-non défini}
MOWER_IP     : ${MOWER_IP:-non défini}
EOBANNER


clear

echo "=== Étape 1 : Mise à jour du système ==="
sudo apt update && sudo apt upgrade -y


### UART CONFIGURATION ###
echo "=== Étape 2 : Activation des UART 2/3/4/5 dans /boot/firmware/config.txt ==="
CONFIG_FILE="/boot/firmware/config.txt"
for uart in uart2 uart3 uart4 uart5; do
  if ! grep -q "dtoverlay=${uart}" "$CONFIG_FILE"; then
    echo "dtoverlay=${uart}" | sudo tee -a "$CONFIG_FILE"
  fi
done


### UDEV GPS CONFIG ###
echo "=== Étape 3 : Configuration des règles UDEV ==="
UDEV_FILE="/etc/udev/rules.d/50-mowgli.rules"
echo 'SUBSYSTEM=="tty", ATTRS{product}=="Mowgli", SYMLINK+="mowgli"' | sudo tee "$UDEV_FILE" > /dev/null

read -p $'\nQuel type de GPS veux-tu configurer ?\n1) USB - simpleRTK2B (u-blox)\n2) USB - RTK1010Board (ESP32 USB CDC)\n3) USB - UM982 (CH340)\n4) UART - connecté sur ttyAMA4\nFais ton choix (1-4) : ' gps_choice

case $gps_choice in
  1)
    RULE='SUBSYSTEM=="tty", ATTRS{idVendor}=="1546", ATTRS{idProduct}=="01a9", SYMLINK+="gps"'
    ;;
  2)
    RULE='SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="4001", SYMLINK+="gps"'
    ;;
  3)
    RULE='SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="gps"'
    ;;
  4)
    RULE='KERNEL=="ttyAMA4", SYMLINK+="gps"'
    ;;
  *)
    RULE=""
    echo "Choix invalide. Aucun GPS configuré."
    ;;
esac

if [ ! -z "$RULE" ] && ! grep -Fxq "$RULE" "$UDEV_FILE"; then
  echo "$RULE" | sudo tee -a "$UDEV_FILE"
fi

sudo udevadm control --reload-rules && sudo udevadm trigger


### RC.LOCAL CONFIG ###
echo "→ Création de rc.local protégée (sauvegarde si existant personnalisé)"
RCLOCAL="/etc/rc.local"
if [ -f "$RCLOCAL" ] && ! grep -q "ttyAMA2" "$RCLOCAL"; then
  sudo cp "$RCLOCAL" "${RCLOCAL}.bak"
  echo "Sauvegarde de l'ancien rc.local → rc.local.bak"
fi
sudo tee "$RCLOCAL" > /dev/null <<'EOF'
#!/bin/bash
stty -F /dev/ttyAMA2 115200 raw -echo -echoe -echok
stty -F /dev/ttyAMA3 115200 raw -echo -echoe -echok
stty -F /dev/ttyAMA4 460800 raw -echo -echoe -echok
stty -F /dev/ttyAMA5 115200 raw -echo -echoe -echok
exit 0
EOF
sudo chmod +x "$RCLOCAL"
sudo systemctl enable rc-local


### DOCKER INSTALLATION ###
echo "→ Installation de Docker depuis get.docker.com"
curl -fsSL https://get.docker.com | sh

echo "→ Installation du plugin docker compose"
sudo apt install -y docker-compose-plugin || {
  echo "Plugin officiel non trouvé, installation manuelle..."
  mkdir -p ~/.docker/cli-plugins
  curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64 \
    -o ~/.docker/cli-plugins/docker-compose
  chmod +x ~/.docker/cli-plugins/docker-compose
}


echo "=== Étape 5 : Ajout de l'utilisateur courant au groupe docker ==="
sudo usermod -aG docker $USER


echo "=== Étape 6 : Clonage ou mise à jour du dépôt mowgli-docker ==="
sudo apt install -y git
cd ~

read -p "Souhaites-tu utiliser un dépôt Git personnalisé ? (o/N) : " use_custom_repo
if [[ "$use_custom_repo" =~ ^[Oo]$ ]]; then
  read -p "→ Entre l'URL complète de ton dépôt Git : " GIT_REPO
else
  GIT_REPO="https://github.com/cedbossneo/mowgli-docker"
fi

if [ -d "mowgli-docker/.git" ]; then
  echo "→ Le dossier mowgli-docker existe déjà, mise à jour..."
  cd mowgli-docker
  git remote set-url origin "$GIT_REPO"
  git pull
else
  echo "→ Clonage du dépôt : $GIT_REPO"
  git clone "$GIT_REPO" mowgli-docker
  cd mowgli-docker
fi



echo "=== Étape 7 : Création interactive du fichier .env avec sauvegarde ==="
ENV_FILE=".env"
CURRENT_IP=$(hostname -I | awk '{print $1}')

read -p "Adresse IP actuelle détectée : $CURRENT_IP. Appuie sur Entrée pour l’utiliser ou entre une autre IP : " ROS_IP
ROS_IP=${ROS_IP:-$CURRENT_IP}

read -p "Adresse IP de la tondeuse (laisser vide si identique) : " MOWER_IP
MOWER_IP=${MOWER_IP:-$ROS_IP}

DEFAULT_IMAGE="ghcr.io/cedbossneo/mowgli-docker:cedbossneo"
read -p "Souhaites-tu utiliser une image Docker personnalisée ? (o/N) : " custom_image
if [[ "$custom_image" =~ ^[Oo]$ ]]; then
  read -p "→ Entre l'image Docker complète (ex: ghcr.io/utilisateur/mon-image:tag) : " IMAGE
else
  IMAGE="$DEFAULT_IMAGE"
fi

TMPENV=$(mktemp)
cat <<EOF > "$TMPENV"
# Adresse IP de la machine exécutant le conteneur Docker
ROS_IP=$ROS_IP

# Adresse IP de la tondeuse
MOWER_IP=$MOWER_IP

# Image Docker à utiliser
IMAGE=$IMAGE
EOF

if [ -f "$ENV_FILE" ] && ! cmp -s "$TMPENV" "$ENV_FILE"; then
  cp "$ENV_FILE" "${ENV_FILE}.bak"
  echo "→ Sauvegarde de l'ancien fichier .env → .env.bak"
fi

mv "$TMPENV" "$ENV_FILE"

echo "=== Fichier .env généré ==="
cat "$ENV_FILE"
echo "==========================="


### OUTILS DIVERS ###
echo "=== Étape 8 : Installation d'un gestionnaire Docker en ligne de commande ==="
    echo "1) Oui, installer lazydocker (recommandé)"
    echo "2) Oui, installer ctop (alternatif)"
    echo "3) Non"
    read -p "Ton choix (1-3) : " docker_cli
    docker_cli=${docker_cli:-3}

    case $docker_cli in
      1)
        echo "→ Installation de lazydocker..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        echo "→ Création de la commande simplifiée : dockermgr"
        sudo tee /usr/local/bin/dockermgr > /dev/null <<EOL
#!/bin/bash
exec lazydocker
EOL
        sudo chmod +x /usr/local/bin/dockermgr
        ;;
      2)
        echo "→ Installation de ctop..."
        sudo apt install -y ctop
        echo "→ Création de la commande simplifiée : dockermgr"
        sudo tee /usr/local/bin/dockermgr > /dev/null <<EOL
#!/bin/bash
exec ctop
EOL
        sudo chmod +x /usr/local/bin/dockermgr
        ;;
      3)
        echo "→ Aucun gestionnaire CLI Docker installé."
        ;;
      *)
        echo "Choix invalide. Aucun outil installé."
        ;;
    esac

echo "=== Étape 9 : Installation d'un gestionnaire de fichiers en ligne de commande ==="
echo "1) Oui, installer Midnight Commander (mc)"
echo "2) Oui, installer ranger"
echo "3) Non"
read -p "Ton choix (1-3) : " fileman_choice
fileman_choice=${fileman_choice:-3}

case $fileman_choice in
1)
echo "→ Installation de Midnight Commander..."
sudo apt install -y mc
echo "→ Commande disponible : mc"
;;
2)
echo "→ Installation de ranger..."
sudo apt install -y ranger
echo "→ Commande disponible : ranger"
;;
3)
echo "→ Aucun gestionnaire de fichiers installé."
;;
*)
echo "Choix invalide. Aucun outil installé."
;;
esac

echo "=== Installation terminée avec succès ! Redémarre le Pi pour finaliser. ==="


echo "=== Étape 10 : Installation d'outils pour le développement et le debug ==="
echo "Souhaites-tu installer des outils de développement et de debug ?"
echo "1) Tous les outils (recommandé)"
echo "2) Outils essentiels seulement"
echo "3) Aucun outil"
read -p "Ton choix (1-3) : " debug_tools
debug_tools=${debug_tools:-2}

case $debug_tools in
1)
echo "→ Installation de tous les outils :"
echo " - htop, ncdu, lsof, strace, gdb, minicom"
echo " - tmux, bat, fd-find, ripgrep"
echo " - nmap, iptraf-ng"
sudo apt install -y htop ncdu lsof strace gdb minicom \
                        tmux bat fd-find ripgrep \
                        nmap iptraf-ng
;;
2)
echo "→ Installation des outils essentiels :"
echo " - htop, ncdu, git, tmux, minicom"
sudo apt install -y htop ncdu git tmux minicom
;;
3)
echo "→ Aucun outil de debug/dev installé."
;;
*)
echo "Choix invalide. Aucun outil installé."
;;
esac

echo "→ Ajout du motd dynamique"
sudo tee /etc/profile.d/mowgli-motd.sh > /dev/null <<'EOF'
#!/bin/bash

# MOWGLI in orange (ANSI 256)
echo -e "\e[38;5;208m"
cat << "BANNER"
███╗   ███╗ ██████╗ ██╗    ██╗ ██████╗ ██╗     ██╗
████╗ ████║██╔═══██╗██║    ██║██╔════╝ ██║     ██║
██╔████╔██║██║   ██║██║ █╗ ██║██║  ███║██║     ██║
██║╚██╔╝██║██║   ██║██║███╗██║██║   ██║██║     ██║
██║ ╚═╝ ██║╚██████╔╝╚███╔███╔╝╚██████╔╝███████╗██║
╚═╝     ╚═╝ ╚═════╝  ╚══╝╚══╝  ╚═════╝ ╚══════╝╚═╝
BANNER

echo -e "\e[0m\n\e[1;37mFOR\e[0m"

# OpenMower in green
echo -e "\e[1;32m"
cat << "OM"
   ██████╗ ██████╗ ███████╗███╗   ██╗███╗   ███╗ ██████╗ ██╗    ██╗███████╗██████╗ 
  ██╔═══██╗███╔═██╗██╔════╝████╗  ██║████╗ ████║██╔═══██╗██║    ██║██╔════╝██╔══██╗
  ██║   ██║██████╔╝█████╗  ██╔██╗ ██║██╔████╔██║██║   ██║██║ █╗ ██║█████╗  ██████╔╝
  ██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║╚██╔╝██║██║   ██║██║███╗██║██╔══╝  ██╔══██╗
  ╚██████╔╝██║     ███████╗██║ ╚████║██║ ╚═╝ ██║╚██████╔╝╚███╔███╔╝███████╗██║  ██║
   ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝
OM

echo -e "\e[0m"

# Infos système
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
MAC=$(ip link show eth0 | awk '/ether/ {print $2}')
SSID=$(iwgetid -r 2>/dev/null || echo "non connecté")
UPTIME=$(uptime -p)
TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo "n/a")
LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
MEM=$(free -m | awk '/Mem/ {printf "%d MiB / %d MiB", $3, $2}')
DISK=$(df -h / | awk 'END {print $4 " libres sur " $2}')
ROS_IP=$(grep ROS_IP ~/mowgli-docker/.env 2>/dev/null | cut -d= -f2)
MOWER_IP=$(grep MOWER_IP ~/mowgli-docker/.env 2>/dev/null | cut -d= -f2)
DOCKER_STATUS=$(docker ps -q | wc -l)

echo "Hostname     : $HOSTNAME"
echo "IP locale    : $IP"
echo "Adresse MAC  : $MAC"
echo "Wi-Fi (SSID) : $SSID"
echo "Uptime       : $UPTIME"
echo "Température  : $TEMP"
echo "Charge CPU   : $LOAD"
echo "RAM utilisée : $MEM"
echo "Disque libre : $DISK"
echo ""
echo "Docker       : $DOCKER_STATUS conteneur(s) actif(s)"
echo "ROS_IP       : ${ROS_IP:-non défini}"
echo "MOWER_IP     : ${MOWER_IP:-non défini}"
EOF

sudo chmod +x /etc/profile.d/mowgli-motd.sh

### DEPLOIEMENT ###
echo "=== Étape 11 : Choix du mode de déploiement Docker ==="
echo "1) Local : ROS et Mowgli sur la même machine (default)"
echo "2) ROS distant + ser2net"
echo "3) ROS distant (remote.pi)"
read -p "Choix (1-3) : " docker_mode
docker_mode=${docker_mode:-1}

case $docker_mode in
  1)
    sudo docker compose up -d
    ;;
  2)
    sudo docker compose -f docker-compose.ser2net.yaml up -d
    ;;
  3)
    sudo docker compose -f docker-compose.remote.pi.yaml up -d
    ;;
  *)
    echo "Choix invalide. Aucun conteneur lancé."
    ;;
esac

echo "→ Déconnecte-toi / reconnecte-toi pour activer l'accès Docker sans sudo"

read -p $'\nRedémarrer maintenant ? (o/N) : ' reboot_now
[[ "$reboot_now" =~ ^[Oo]$ ]] && sudo reboot
