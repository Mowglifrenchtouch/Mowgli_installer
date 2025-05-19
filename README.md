# 🚀 Mowgli_installer

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
- 🛰️ Configuration GPS + UART
- 🐳 Docker & Docker Compose
- 📁 Clonage automatique du dépôt [mowgli-docker](https://github.com/cedbossneo/mowgli-docker)
- 🔐 Génération du fichier `.env`
- 🚀 Déploiement des conteneurs ROS2
- 🧪 Suivi MQTT (`robot/state`)
- 🎨 Personnalisation logo terminal (`motd`)
- 🧼 Désinstallation propre avec backup
- ⚙️ Mise à jour du firmware (expérimental)

---

## 🚀 Installation

```bash
git clone https://github.com/juditech3D/Mowgli_autoinstaller.git
cd Mowgli_autoinstaller
chmod +x install-mowgli.sh
./install-mowgli.sh
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
G) Configuration GPS
C) Clonage dépôt mowgli-docker
E) Génération .env
O) Déploiement conteneurs Docker
M) Suivi MQTT robot_state
P) Personnalisation logo (motd)
H) Mise à jour de l’installer
Z) Désinstallation et restauration
F) Mise à jour firmware robot
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
