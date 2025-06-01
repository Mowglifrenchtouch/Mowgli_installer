#!/bin/bash
# functions/installation_outils_complementaires.sh
# Menu d'installation et désinstallation des outils CLI utiles

installer_paquet() {
  local pkg="$1"

  if [[ "$pkg" == "lazydocker" ]]; then
    echo "[INFO] Installation manuelle de lazydocker..."
    curl -Lo lazydocker.tar.gz https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_0.21.0_Linux_x86_64.tar.gz
    tar xf lazydocker.tar.gz
    sudo install lazydocker /usr/local/bin/
    rm -f lazydocker lazydocker.tar.gz
  else
    sudo apt install -y "$pkg"
  fi
}

installer_outils() {
  local conf_file="$SCRIPT_DIR/complementary_tools.conf"
  local -a outils
  local -a noms
  local -a choix
  local index=1

  echo "=== Installation des outils complémentaires ==="
  echo "🔧 Liste des outils disponibles :"

  if [[ ! -f "$conf_file" ]]; then
    echo "[ERREUR] Fichier de configuration manquant : $conf_file"
    return 1
  fi

  while IFS="|" read -r cmd desc; do
    [[ "$cmd" =~ ^#.*$ || -z "$cmd" ]] && continue
    outils+=("$cmd")
    noms+=("$desc")
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "  $index) $cmd  -  $desc ✅"
    else
      echo "  $index) $cmd  -  $desc ❌"
    fi
    ((index++))
  done < "$conf_file"

  echo "  a) Tout installer (y compris ceux déjà présents)"
  read -p "Sélectionnez les outils à installer (ex: 1 3 ou 'a') : " -a choix

  local to_install=()
  if [[ "${choix[0]}" == "a" ]]; then
    to_install=("${outils[@]}")
  else
    for c in "${choix[@]}"; do
      if [[ "$c" =~ ^[0-9]+$ && "$c" -ge 1 && "$c" -le "${#outils[@]}" ]]; then
        to_install+=("${outils[$((c - 1))]}")
      fi
    done
  fi

  if [ "${#to_install[@]}" -gt 0 ]; then
    sudo apt update
    for pkg in "${to_install[@]}"; do
      echo "📦 Installation de : $pkg"
      installer_paquet "$pkg"
    done
    echo "✅ Installation terminée."
  else
    echo "[INFO] Aucun outil sélectionné."
  fi

  echo
  echo "[INFO] Appuyez sur une touche pour continuer ou attendez 10 secondes..."
  read -t 10 -n 1 -s
}

