#!/bin/bash
# Fichier de langue : Français FR

# 🔁 Messages généraux
CONFIRM_REBOOT="Souhaitez-vous redémarrer le Raspberry Pi ? (o/N) : "
RETURN_MENU="[INFO] Retour au menu principal."
REINITIALISATION_ANNULEE="⛔ Réinitialisation annulée."
REINITIALISATION_OK="✅ Tous les modules ont été réinitialisés."

# 🧩 Modules
MODULE_I_DESC="Installation complète"
MODULE_U_DESC="Mise à jour du système"
MODULE_J_DESC="Configuration UART"
MODULE_T_DESC="Outils complémentaires"
MODULE_D_DESC="Docker & Compose"
MODULE_G_DESC="Configuration GPS"
MODULE_C_DESC="Clonage dépôt mowgli-docker"
MODULE_E_DESC="Génération .env"
MODULE_O_DESC="Déploiement conteneurs Docker"
MODULE_M_DESC="Suivi MQTT robot_state"
MODULE_P_DESC="Personnalisation logo (motd)"
MODULE_H_DESC="Mise à jour de l’installeur"
MODULE_Z_DESC="Désinstallation et restauration"
MODULE_F_DESC="Mise à jour firmware robot"

# 🛠️ Diagnostic
DIAG_MENU_TITLE="===== MENU DIAGNOSTIC DE DÉPANNAGE ====="
DIAG_OPTION_1="1) Diagnostic GPS complet (USB/NMEA/UBX)"
DIAG_OPTION_2="2) Voir le dernier diagnostic GPS résumé"
DIAG_OPTION_3="3) Voir les logs GPS"
DIAG_OPTION_4="4) Test de connexion IMU via carte mère"
DIAG_OPTION_5="5) Voir le dernier diagnostic IMU résumé"
DIAG_OPTION_6="6) Voir les logs IMU"
DIAG_OPTION_7="7) Redémarrer les conteneurs Docker si inactifs"
DIAG_OPTION_8="8) Retour au menu principal"
DIAG_PROMPT="Choix> "

# ✅ États
IMU_DETECTED="🔎 IMU détectée :"
IMU_NOT_DETECTED="⚠️  Aucune trame identifiable. IMU absente ou mal configurée."
IMU_PORT_FOUND="🔌 Port détecté :"
IMU_NO_PORT="❌ Aucun port USB pour la carte mère/IMU n'a été détecté."
IMU_HINT="💡 Assurez-vous que la carte mère est bien connectée en USB."
GPS_SUMMARY_PATH="Résumé disponible dans : /tmp/diagnostic_gps_resume.txt"
IMU_SUMMARY_PATH="Résumé disponible dans : /tmp/diagnostic_imu_resume.txt"
GPS_NO_DATA="⚠️  Aucune donnée GPS détectée."
GPS_UBLOX_DETECTED="📡 Module GPS détecté : u-blox"
GPS_UNICORE_DETECTED="📡 Module GPS détecté : Unicore (UM980/UM982)"

# 🚀 Redémarrage Docker
DOCKER_RESTARTING="[INFO] Redémarrage des conteneurs Docker..."
DOCKER_RESTART_OK="✅ Conteneurs Docker redémarrés avec succès."
DOCKER_RESTART_FAIL="❌ Échec du redémarrage des conteneurs Docker."

# 🧭 Divers
RETURN_MSG="Appuyez sur une touche pour continuer..."
REBOOTING="✅ Reboot en cours..."

# 🌐 Mode distant (Ser2Net)
MODE_DISTANT_DESC="Configuration du mode distant (Ser2Net)"
MODE_DISTANT_DONE="✅ Mode distant configuré avec succès."
MODE_DISTANT_ERROR="❌ Erreur lors de la configuration du mode distant."
MODE_DISTANT_DEPLOY_OK="✅ Ser2Net déployé avec succès."
MODE_DISTANT_DEPLOY_FAIL="❌ Échec du déploiement de Ser2Net."
MODE_DISTANT_CONFIRM="Souhaitez-vous configurer le mode distant Ser2Net ? (o/N) : "

# 🐳 Docker
DOCKER_INSTALLED="✅ Docker & Compose installés."
DOCKER_ALREADY_INSTALLED="ℹ️  Docker est déjà installé."
DOCKER_INSTALL_FAIL="❌ Échec de l'installation de Docker."

# 📦 Dépôt mowgli-docker
CLONE_REPO_DESC="Clonage du dépôt mowgli-docker"
CLONE_REPO_DEFAULT="Dépôt par défaut :"
CLONE_REPO_CUSTOM="Dépôt personnalisé utilisé :"
CLONE_REPO_SUCCESS="✅ Dépôt cloné avec succès."
CLONE_REPO_FAIL="❌ Échec du clonage du dépôt."
CLONE_REPO_SELECT="Souhaitez-vous utiliser un dépôt personnalisé ? (o/N) : "

# 🧬 .env
ENV_GENERATION_OK="✅ Fichier .env généré avec succès."
ENV_GENERATION_FAIL="❌ Échec de la génération du fichier .env."
ENV_ALREADY_EXISTS="ℹ️  Le fichier .env existe déjà."
ENV_OVERWRITE="Souhaitez-vous le remplacer ? (o/N) : "

# 🛠️ Outils complémentaires
TOOLS_MENU_TITLE="===== OUTILS COMPLÉMENTAIRES ====="
TOOLS_ALREADY_INSTALLED="✅ Outil déjà installé :"
TOOLS_INSTALL_OK="✅ Outil installé avec succès :"
TOOLS_INSTALL_FAIL="❌ Échec de l'installation de :"

# 🔁 Mise à jour installeur
INSTALLER_UP_TO_DATE="✅ Aucune mise à jour disponible."
INSTALLER_UPDATE_AVAILABLE="📦 Des mises à jour sont disponibles."
INSTALLER_UPDATE_DONE="✅ Mise à jour appliquée."
INSTALLER_UPDATE_CANCELED="⏭️  Mise à jour annulée."
INSTALLER_INVALID_CONFIG="❌ Fichier de configuration invalide pour la mise à jour."

# 🔧 Utilitaires généraux
ASK_UPDATE_CONFIRM="Souhaitez-vous appliquer la mise à jour maintenant ? (o/N) : "
INVALID_CHOICE="[ERREUR] Choix invalide."
CONTINUE_PROMPT="[INFO] Appuyez sur une touche pour continuer ou attendez 10 secondes..."
