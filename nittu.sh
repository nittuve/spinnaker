#!/bin/bash
set -e
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update
sudo apt-get -y install jq openjdk-11-jdk
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh
sudo mkdir -p /home/spinnaker
sudo chown spinnaker:spinnaker /home/spinnaker
sudo apt-get -y install jq apt-transport-https
hal config storage s3 edit --bucket vnittu-spinnaker-2 --region us-east-1 --root-folder vnittu --access-key-id AKIAVCMU5ZZ3SV3C2FZX --secret-access-key
hal config storage edit --type s3
hal config security authn oauth2 edit --client-id 427616cee2c6165e7b31 --client-secret f2dcfbaf48dac9e5b8a030f81db18e8b23bd2909 --provider github
hal config security authn oauth2 enable
hal config security authn oauth2 edit --pre-established-redirect-uri http://<IP>:8084/login
hal config security ui edit --override-base-url http://<IP>:9000
hal config security api edit --override-base-url http://<IP>:8084

# install dependencies
sudo apt update
sudo apt-get -y install redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

echo 'spinnaker.s3:
  versioning: false
' | sudo tee -a /home/spinnaker/.hal/default/profiles/front50-local.yml
sudo hal config version edit --version 1.28.1
sudo hal deploy apply

sudo systemctl restart apache2
sudo systemctl restart gate
sudo systemctl restart orca
sudo systemctl restart igor
sudo systemctl restart front50
sudo systemctl restart echo
sudo systemctl restart clouddriver
sudo systemctl restart rosco
