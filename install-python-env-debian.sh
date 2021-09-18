#!/bin/bash
set -e

do_install() {
    PYTHON_VERSION=$1
    
    echo -e "Starting installation...\n"
    echo -e "Using Ubuntu/Mint/Debian ${dist_version}, proceeding with install...\n"
    
    # Install python
    sudo apt-get update
    sudo apt-get install -y \
    build-essential \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-distutils \
    curl \
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
    
    # Install poetry
    curl -sSL \
    https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python${PYTHON_VERSION}
    
    # Clean up
    rm get-pip.py .newpath
    
    echo "Installation successful."
    echo "Please close and open your shell for changes to take effect."
}

# Run the script
if [ -z "$1" ]
then
    echo "No version of python selected to install!"
    echo
    echo "Usage:"
    echo "$0 3.9"
    exit 1
else
    do_install $1
fi
