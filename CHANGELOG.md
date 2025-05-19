# 📦 CHANGELOG – Mowgli_installer

Toutes les modifications notables de ce projet sont documentées ici.

---

## [v2.0.0] – 2025-05-19

### ✨ Nouveautés principales

- 💡 Refonte complète de l’interface terminale
- 🎛️ Ajout d’un **menu interactif ASCII** avec détection automatique de la langue (FR/EN)
- 🧠 Support **multilingue** via fichiers `fr.sh` / `en.sh` à la racine
- 🔁 Système **idempotent** : chaque fonction teste si elle a déjà été exécutée ou installée
- 💾 Ajout d’un système de **sauvegarde automatique** avant chaque modification système

### ✅ Fonctions rendues interactives et idempotentes

- `installation_auto` → choix local ou distant
- `configuration_uart` → activation UART vérifiée et modifiable sans doublons
- `configuration_gps` → ajout intelligent de `dtoverlay=uart4`
- `clonage_depot_mowgli_docker` → confirmation avant mise à jour
- `generation_env` → modification guidée des variables `.env`
- `install_docker` → détection complète + installation propre (clé, dépôt, plugins)
- `deploiement_conteneurs` → évite relancement inutile
- `suivi_mqtt_robot_state` → test de connectivité + port personnalisable
- `mise_a_jour_systeme` → affiche les MAJ disponibles et demande confirmation
- `mise_a_jour_firmware_robot` → vérifie la version, télécharge et flashe si besoin
- `mise_a_jour_installer` → vérifie les commits à distance avant de synchroniser
- `installer_outils` → sélection intelligente uniquement des outils manquants
- `configuration_mode_distant` → tutoriel + détection de ser2net + config affichable
- `desinstallation_restoration` → menu complet de suppression/restauration avec confirmation

### 🔧 Divers

- ✅ Affichage clair de l’état des modules dans le menu principal
- 🔌 Prise en charge de `/boot/firmware/config.txt` pour UART & GPS
- 🔄 Option « Quitter » avec redémarrage du Raspberry Pi intégré
- 🌐 Nouveau lien GitHub : renommage du dépôt en `Mowgli_installer`

---

## [v1.0.0] – Version initiale (par [@Pepeuch](https://github.com/Pepeuch))

- Script simple d'installation automatique de l'environnement OpenMower/Mowgli
- Compatible Raspberry Pi
- Fonctions de base pour UART, GPS, ROS2, Docker
