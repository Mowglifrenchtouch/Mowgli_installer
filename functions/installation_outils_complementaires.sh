#!/bin/bash
# functions/installation_outils_complementaires.sh
# Menu d'installation intelligente des outils CLI utiles

installer_outils() {
  local conf_file="$SCRIPT_DIR/complementary_tools.conf"
  local -a outils noms installables
  local -a choix
  local index=1

  echo "=== Installation des outils complémentaires ==="

  # Chargement du fichier de config
  if [[ ! -f "$conf_file" ]]; then
    echo "[ERREUR] Fichier de configuration manquant : $conf_file"
    pause_ou_touche
    return 1
  fi

  echo "🔧 Liste des outils disponibles :"
  while IFS="|" read -r cmd desc; do
    [[ "$cmd" =~ ^#.*$ || -z "$cmd" ]] && continue
    outils+=("$cmd")
    noms+=("$desc")

    if command -v "$cmd" >/dev/null 2>&1; then
      echo "  $index) $cmd  -  $desc ✅"
    else
      echo "  $index) $cmd  -  $desc ❌"
      installables+=("$cmd")
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

  if [ "${#to_install[@]}" -eq 0 ]; then
    echo "[INFO] Aucun outil à installer."
  else
    echo "📦 Installation de : ${to_install[*]}"
    sudo apt update
    sudo apt install -y "${to_install[@]}"
    echo "✅ Installation terminée."
  fi

  pause_ou_touche
}
