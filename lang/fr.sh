#!/bin/bash

LABEL_MENU=(
  "I) Installation complète"
  "U) Mise à jour du système"
  "J) Configuration UART"
  "T) Outils complémentaires"
  "D) Docker & Compose"
  "G) Configuration GPS"
  "C) Clonage dépôt mowgli-docker"
  "E) Génération .env"
  "O) Déploiement conteneurs Docker"
  "M) Suivi MQTT robot_state"
  "P) Personnalisation logo"
  "H) Mise à jour Mowgli Installer"
  "Z) Désinstallation et restauration"
  "F) Mise à jour firmware robot"
  "X) Quitter"
)

PROMPT="Choix> "
MSG_INVALID="Option invalide."
MSG_EXIT="À bientôt !"
