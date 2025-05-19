#!/bin/bash
# functions/installation_outils_complementaires.sh
# Menu d'installation et désinstallation des outils CLI utiles

installer_outils() {
  local conf_file="$SCRIPT_DIR/complementary_tools.conf"
  local -a outils
  local -a noms
  local -a choix
  local index=1

  echo "-> Outils complémentaires disponibles :"

  # Charger depuis le fichier de config
  if [[ ! -f "$conf_file" ]]; then
    echo "[ERREUR] Fichier de configuration manquant : $conf_file"
    return 1
  fi

  while IFS="|" read -r cmd desc; do
    [[ "$cmd" =~ ^#.*$ || -z "$cmd" ]] && continue
    outils+=("$cmd")
    noms+=("$desc")
    echo "  $index) $cmd  -  $desc"
    ((index++))
  done < "$conf_file"

  echo "  a) Tout installer"
  read -p "Sélectionnez les outils à installer (ex: 1 3 4 ou 'a') : " -a choix

  if [[ "${choix[0]}" == "a" ]]; then
    sudo apt update
    sudo apt install -y "${outils[@]}"
  else
    local to_install=()
    for c in "${choix[@]}"; do
      if [[ "$c" =~ ^[0-9]+$ && "$c" -ge 1 && "$c" -le "${#outils[@]}" ]]; then
        to_install+=("${outils[$((c - 1))]}")
      fi
    done
    if [ "${#to_install[@]}" -gt 0 ]; then
      sudo apt update
      sudo apt install -y "${to_install[@]}"
    else
      echo "[INFO] Aucun outil sélectionné."
    fi
  fi

  pause_ou_touche
}

