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
  echo -e 'Starting installation...\n'
  dist_version=$( get_distribution_version )

  case "$dist_version" in

    tessa|bionic)
      echo 'deb https://cloud.r-project.org/bin/linux/ubuntu cosmic-cran35/' >> \
        sudo tee -a /etc/apt/sources.list

      # Add repo key for apt secure
      gpg --keyserver keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9
      gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

      sudo apt-get update
      sudo apt-get install -y r-base r-base-dev
      ;;

    esac

    echo -e 'Installation finished successfully.'
    echo -e 'Use R command or Rscripts command to start your journey in r!\n'
  }

# Run the script
do_install
