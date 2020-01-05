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

    disco)
      echo -e "Using Ubuntu ${dist_version}, proceeding with install...\n"
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable edge"
      sudo apt-get install -y docker-ce

      ;;
    eoan)
      echo -e "Using Ubuntu ${dist_version}, proceeding with install...\n"
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

      sudo add-apt-repository "deb [arch=amd64]
      https://download.docker.com/linux/ubuntu disco stable edge"
      sudo apt-get install -y docker-ce

      ;;
    *)
      echo -e "Using unsupported distribution..."
      echo -e "Please, follow the steps at https://docs.docker.com/install"
      exit 0
      ;;

    esac

  # Get updated docker install script
  wget -q https://get.docker.com
  cat index.html > get-docker.sh

  # Add execute permissions
  chmod +x get-docker.sh

  # Run the install script
  ./get-docker.sh

  # Cleanup
  rm get-docker.sh index.html
}

# Run installation
do_install

# Add user to docker group to remove need for sudo
# Only needed for unix
sudo groupadd docker
sudo usermod -aG docker $USER

echo -e 'Installation successful.\n'
