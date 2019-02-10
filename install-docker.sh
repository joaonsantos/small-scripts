# Get updated docker install script
wget -q https://get.docker.com
cat index.html > get-docker.sh

# Add execute permissions
chmod +x get-docker.sh

# Run the install script
./get-docker.sh

# Cleanup
rm get-docker.sh index.html
