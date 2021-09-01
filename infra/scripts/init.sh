#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y --update ppa:ansible/ansible
sudo apt install -y ansible
sudo apt install -y git

git clone https://github.com/Wyfy0107/ansible-test.git /home/ubuntu/app
sudo ansible-playbook -i /home/ubuntu/app/ansible/inventory /home/ubuntu/app/ansible/playbook.yaml
