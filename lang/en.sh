#!/bin/bash
# Language file: English EN

# 🔁 General messages
CONFIRM_REBOOT="Do you want to reboot the Raspberry Pi? (y/N): "
RETURN_MENU="[INFO] Returning to main menu."
REINITIALISATION_ANNULEE="⛔ Reset canceled."
REINITIALISATION_OK="✅ All modules have been reset."

# 🧩 Modules
MODULE_I_DESC="Full installation"
MODULE_U_DESC="System update"
MODULE_J_DESC="UART configuration"
MODULE_T_DESC="Additional tools"
MODULE_D_DESC="Docker & Compose"
MODULE_G_DESC="GPS configuration"
MODULE_C_DESC="Clone mowgli-docker repo"
MODULE_E_DESC="Generate .env file"
MODULE_O_DESC="Docker containers deployment"
MODULE_M_DESC="MQTT robot_state monitoring"
MODULE_P_DESC="Logo customization (motd)"
MODULE_H_DESC="Installer update"
MODULE_Z_DESC="Uninstall and restore"
MODULE_F_DESC="Robot firmware update"

# 🛠️ Diagnostic
DIAG_MENU_TITLE="===== TROUBLESHOOTING MENU ====="
DIAG_OPTION_1="1) Full GPS diagnostic (USB/NMEA/UBX)"
DIAG_OPTION_2="2) View last GPS diagnostic summary"
DIAG_OPTION_3="3) View GPS logs"
DIAG_OPTION_4="4) Test IMU connection via mainboard"
DIAG_OPTION_5="5) View last IMU diagnostic summary"
DIAG_OPTION_6="6) View IMU logs"
DIAG_OPTION_7="7) Restart Docker containers if inactive"
DIAG_OPTION_8="8) Return to main menu"
DIAG_PROMPT="Choice> "

# ✅ States
IMU_DETECTED="🔎 IMU detected:"
IMU_NOT_DETECTED="⚠️  No identifiable IMU frames. IMU absent or misconfigured."
IMU_PORT_FOUND="🔌 Port detected:"
IMU_NO_PORT="❌ No USB port for mainboard/IMU detected."
IMU_HINT="💡 Make sure the mainboard is properly connected via USB."
GPS_SUMMARY_PATH="Summary available at: /tmp/diagnostic_gps_resume.txt"
IMU_SUMMARY_PATH="Summary available at: /tmp/diagnostic_imu_resume.txt"

# 🚀 Docker Restart
DOCKER_RESTARTING="[INFO] Restarting Docker containers..."
DOCKER_RESTART_OK="✅ Docker containers restarted successfully."
DOCKER_RESTART_FAIL="❌ Failed to restart Docker containers."

# 🧭 Misc
RETURN_MSG="Press any key to continue..."
REBOOTING="✅ Rebooting..."

# 🌐 Remote mode (Ser2Net)
MODE_DISTANT_DESC="Remote mode configuration (Ser2Net)"
MODE_DISTANT_DONE="✅ Remote mode successfully configured."
MODE_DISTANT_ERROR="❌ Error configuring remote mode."
MODE_DISTANT_DEPLOY_OK="✅ Ser2Net successfully deployed."
MODE_DISTANT_DEPLOY_FAIL="❌ Failed to deploy Ser2Net."
MODE_DISTANT_CONFIRM="Do you want to configure remote Ser2Net mode? (y/N): "

# 🐳 Docker
DOCKER_INSTALLED="✅ Docker & Compose installed."
DOCKER_ALREADY_INSTALLED="ℹ️  Docker is already installed."
DOCKER_INSTALL_FAIL="❌ Failed to install Docker."

# 📦 mowgli-docker repo
CLONE_REPO_DESC="Cloning mowgli-docker repo"
CLONE_REPO_DEFAULT="Default repository:"
CLONE_REPO_CUSTOM="Using custom repository:"
CLONE_REPO_SUCCESS="✅ Repository successfully cloned."
CLONE_REPO_FAIL="❌ Failed to clone repository."
CLONE_REPO_SELECT="Do you want to use a custom repository? (y/N): "

# 🧬 .env
ENV_GENERATION_OK="✅ .env file generated successfully."
ENV_GENERATION_FAIL="❌ Failed to generate .env file."
ENV_ALREADY_EXISTS="ℹ️  .env file already exists."
ENV_OVERWRITE="Do you want to replace it? (y/N): "

# 🛠️ Additional tools
TOOLS_MENU_TITLE="===== ADDITIONAL TOOLS ====="
TOOLS_ALREADY_INSTALLED="✅ Tool already installed:"
TOOLS_INSTALL_OK="✅ Tool installed successfully:"
TOOLS_INSTALL_FAIL="❌ Failed to install:"

# 🔁 Installer update
INSTALLER_UP_TO_DATE="✅ No updates available."
INSTALLER_UPDATE_AVAILABLE="📦 Updates available."
INSTALLER_UPDATE_DONE="✅ Update applied."
INSTALLER_UPDATE_CANCELED="⏭️  Update canceled."
INSTALLER_INVALID_CONFIG="❌ Invalid config file for update."

# 🔧 General utilities
ASK_UPDATE_CONFIRM="Do you want to apply the update now? (y/N): "
INVALID_CHOICE="[ERROR] Invalid choice."
CONTINUE_PROMPT="[INFO] Press a key to continue or wait 10 seconds..."

# 📡 GPS Modules
GPS_MODULE_UBLOX="🔎 u-blox module detected"
GPS_MODULE_UM9XX="🔎 Unicore UM9XX module detected"
GPS_NO_DATA="⚠️  No GPS data received. Check the connection."

# 📊 IMU Values
IMU_ZERO_VALUES="⚠️  IMU returned only 0 values. Sensor might not be streaming."
IMU_VALID_VALUES="✅ IMU values detected. Data stream OK."

# 🔁 Docker runtime
DOCKER_EXPECTED_ZERO="ℹ️  For diagnosis, the number of active containers should be zero."
DOCKER_EXPECTED_ACTIVE="ℹ️  For IMU detection, containers must be active."
DOCKER_COUNT="🔢 Active Docker containers:"
DOCKER_FORCE_RESTART_CONFIRM="No containers active. Do you want to restart them? (y/N): "
