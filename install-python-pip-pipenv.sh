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
  PYTHON_VERSION=$1

  echo -e "Starting installation...\n"
  dist_version=$( get_distribution_version )

  case "$dist_version" in

    tara|tessa|bionic|cosmic|disco|eoan)
      echo -e "Using Ubuntu/Mint ${dist_version}, proceeding with install...\n"

      # Install python
      sudo apt-get update
      sudo apt-get install -y \
	  build-essential \
          python${PYTHON_VERSION} \
          python${PYTHON_VERSION}-dev \
          python${PYTHON_VERSION}-distutils \
          wget

      # Get pip
      wget -O get-pip.py "https://bootstrap.pypa.io/get-pip.py"

      # Install pip
      python${PYTHON_VERSION} get-pip.py --user pip

      # Add pip to PATH
      NEW_PATH="${PATH}:/home/${USER}/.local/bin"
      
      touch .newpath
      echo -e "\nexport PATH=${NEW_PATH}" | \
        tee -a /home/${USER}/.bashrc .newpath
      source .newpath
      
      # Install pipenv
      pip${PYTHON_VERSION} install --user pipenv

      # Clean up
      rm get-pip.py .newpath

      echo "Installation successful."
      echo "Please close and open your shell for changes to take effect."

      ;;
    *)
      echo "Distribution not recognized...\nInstallation unsuccessful."
      echo 

    esac
  }

# Run the script
if [ -z "$1" ]
  then
    echo "No version of python selected to install!"
    echo
    echo "Usage:"
    echo "./install-python-pip-pipenv.sh 3.8"
    exit 1
  else
    do_install $1
fi
