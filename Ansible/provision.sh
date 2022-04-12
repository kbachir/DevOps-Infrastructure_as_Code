!#/bin/bash
sudo apt update -y
sudo apt-get install tree -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
sudo apt install python3-pip

pip3 install awscli
pip3 install boto boto3 -y
sudo apt-get upgrade -y
