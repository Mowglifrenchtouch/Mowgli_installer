# 📦 CHANGELOG – Mowgli_installer

Toutes les modifications notables de ce projet sont documentées ici.

---

## [v2.0.0] – 2025-05-19

### ✨ Nouveautés principales

- 💡 Refonte complète de l’interface terminale
- 🎛️ Ajout d’un **menu interactif ASCII** avec détection de la langue système (FR/EN)
- 🧠 Support **multilingue** via fichiers `fr.sh` / `en.sh` à la racine
- 🔁 Nouveau système **idempotent** : chaque fonction teste si elle a déjà été exécutée
- 💾 Ajout d’une **sauvegarde automatique** avant chaque modification système (bientôt actif sur tous les modules)
- 🐳 Fonction `install_docker()` réécrite avec :
  - Vérification intelligente de l'installation
  - Demande de confirmation avant mise à jour
- ✅ Affichage de l'**état des modules** dans le menu
- 🔌 Prise en charge de `/boot/firmware/config.txt` pour UART & GPS
- 🔄 Option « Quitter » permet de **redémarrer le Raspberry Pi**
- 🌐 Mise à jour du lien GitHub et renommage du dépôt en `Mowgli_installer`

---

## [v1.0.0] – Version initiale (par [@Pepeuch](https://github.com/Pepeuch))

- Script simple d'installation automatique de l'environnement OpenMower/Mowgli
- Compatible Raspberry Pi
- Fonctions de base pour UART, GPS, ROS2, Docker
