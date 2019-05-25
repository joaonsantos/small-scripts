get_distribution() {
  lsb_dist=""

  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  # Returning an empty string here should be alright since the
  # case statements don't act unless you provide an actual value
  echo "$lsb_dist"
}

get_distribution_version() {
  # perform some very rudimentary platform detection
  lsb_dist=$( get_distribution )
  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

  case "$lsb_dist" in

    ubuntu|linuxmint)
      dist_version="$(lsb_release --codename | cut -f2)"

      if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
        dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
      fi
      ;;

    esac

    echo "$dist_version"
  }

do_install() {
  echo -e "Starting installation...\n"
  dist_version=$( get_distribution_version )

  case "$dist_version" in

    tara|tessa|bionic|cosmic)
      echo -e "Using Ubuntu/Mint ${dist_version}, proceeding with install...\n"

      # Install python
      sudo apt-get update && apt-get install -y \
          python3.7 \
          python3.7-dev \
          python3.7-distutils \
          wget

      # Get pip
      wget -q -O get-pip.py "https://bootstrap.pypa.io/get-pip.py"
      
      # Add pip to PATH
      NEW_PATH="${PATH}:/home/${USER}/.local/bin"

      echo "\nexport PATH=${NEW_PATH}" >> \
        sudo tee -a /home/${USER}/.bashrc
      source ~/.bashrc

      # Install pipvenv
      python3.7 get-pip.py -q --user pip \
        && pip3.7 install -q --user pipenv

      # Remove get-pip file
      rm get-pip.py

      ;;
    *)
      echo -e 'Distribution not recognized...\nInstallation unsuccessful.\n'

    esac
  }

# Run the script
do_install
