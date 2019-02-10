# Get updated docker install script
wget -q https://get.docker.com
cat index.html > get-docker.sh

# Add execute permissions
chmod +x get-docker.sh

# Run the install script
./get-docker.sh

# Add user to docker group to remove need for sudo
# Only needed for unix
sudo groupadd docker
sudo usermod -aG docker $USER

# Cleanup
rm get-docker.sh index.html
