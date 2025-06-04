# 🚀 Mowgli_installer Beta v1

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Shell Script](https://img.shields.io/badge/script-bash-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)
![Langues](https://img.shields.io/badge/langues-FR%20%7C%20EN-orange)
![Status: Stable](https://img.shields.io/badge/status-stable-brightgreen)

> 💡 Refonte interactive du script original développé par [Pepeuch](https://github.com/Pepeuch)

Script interactif pour installer et configurer tout l’environnement **OpenMower Mowgli** sur un robot tondeuse (YardForce 500/500B) avec Raspberry Pi.

> 🧠 Pensé pour les débutants  
> 💡 100% terminal — pas besoin de savoir coder  
> 🛠️ Compatible installation **locale** (tout sur le robot) ou **distante** (via ser2net)

---

## 📦 Fonctions principales

- 🛠 Mise à jour du système
- 🔌 Activation des UART (IMU, GPS…)
- 🛰️ Configuration GPS + règles UDEV automatiques
- 🐳 Docker & Docker Compose
- 📁 Clonage automatique du dépôt [mowgli-docker](https://github.com/cedbossneo/mowgli-docker)
- 🔐 Génération du fichier `.env` (auto-détection IP WiFi)
- 🚀 Déploiement des conteneurs ROS2
- 🧪 Suivi MQTT (`robot/state`)
- 🌐 Support du mode distant (exposition UART via `ser2net`)
- 🧼 Désinstallation propre avec backup
- ⚙️ Mise à jour du firmware (expérimental)
---

## 🚀 Installation

Installation rapide : 

```bash
curl -sSL https://raw.githubusercontent.com/Mowglifrenchtouch/mowgli_installer/main/install.sh | bash
```
📦 Options disponibles :

--reset : supprime l’installation existante et réinstalle depuis zéro
(utile si un dossier ~/mowgli_installer est déjà présent)

```bash
curl -sSL https://raw.githubusercontent.com/Mowglifrenchtouch/mowgli_installer/main/install.sh | bash -s -- --reset
```

Installation manuel : 

Vous pouvez aussi cloner manuellement le dépôt et lancer install-mowgli.sh.

```bash
git clone https://github.com/Mowglifrenchtouch/mowgli_installer.git
cd Mowgli_installer
chmod +x install-mowgli.sh
./install-mowgli.sh
```
## 🚀 Lancer l'installateur Mowgli
Une fois installé, vous pouvez exécuter l'interface de configuration Mowgli avec une simple commande dans votre terminal :

```bash
mowgli
```
✅ Ce lanceur automatique gère pour vous le lancement de l’interface install-mowgli.sh

Et vous pouvez l’exécuter à tout moment !

## 🔄 Forcer la réinstallation (optionnel)
Pour forcer la suppression du dossier existant et refaire une installation propre, utilisez :

```bash
mowgli --reset
```
## 📦 Première installation (si vous n’avez pas encore le lanceur)

```bash
git clone https://github.com/Mowglifrenchtouch/Mowgli_installer.git
cd Mowgli_installer
chmod +x scripts/mowgli install-mowgli.sh
sudo cp scripts/mowgli /usr/local/bin/mowgli
mowgli

```

---

## 🧭 Menu principal

```
===== INSTALLATION & CONFIGURATION =====
I) Installation complète (locale ou distante)
U) Mise à jour du système
J) Configuration UART
T) Outils complémentaires (htop, lazydocker, etc.)
D) Docker & Compose
G) Configuration GPS (overlay + udev)
C) Clonage dépôt mowgli-docker
E) Génération .env (avec IP WiFi)
O) Déploiement conteneurs Docker
M) Suivi MQTT robot_state
S) Mode distant (ser2net)
H) Mise à jour de Mowgli_installer
Z) Désinstallation et restauration
F) Mise à jour firmware robot
R) Réinitialiser les statuts
X) Quitter

```

---

## 🌐 Mode distant avec ser2net

Ce mode permet d’installer ROS sur un serveur distant et d’exposer les ports série du robot via `ser2net`.

👉 Guide complet :  
🔗 [Configuration ser2net pour OpenMower](https://juditech3d.github.io/Guide-DIY-OpenMower-Mowgli-pour-Robots-Tondeuses-Yard500-et-500B/ser2net/)

---

## 🙏 Crédits

- ⚙️ @cedbossneo — Dépôt mowgli-docker
- 🧠 @Pepeuch — Créateur du script original de base
- 🧰 @juditech3D — Refonte, automatisation, multilingue, interface terminale

---

## 📄 Licence

MIT
