#!/bin/bash

LABEL_MENU=(
  "I) Full Installation"
  "U) System Update"
  "J) UART Configuration"
  "T) Extra Tools"
  "D) Docker & Compose"
  "G) GPS Configuration"
  "C) Clone mowgli-docker repo"
  "E) Generate .env"
  "O) Deploy Docker Containers"
  "M) Monitor MQTT robot_state"
  "P) Customize Boot Logo"
  "H) Update Mowgli Installer"
  "Z) Uninstall & Restore"
  "F) Firmware Update (Robot)"
  "X) Exit"
)

PROMPT="Select> "
MSG_INVALID="Invalid option."
MSG_EXIT="Goodbye!"
