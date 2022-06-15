#!/bin/bash

if [ -f /etc/redhat-release ]
then
  sudo yum install tree -y
  sudo yum install newt -y

fi

if [ -f /etc/lsb-release ]
then
  sudo apt install tree -y
  sudo apt install whiptail -y
fi


for file in `ls ./scripts`
do
sudo  chmod +x "$PWD/scripts/$file"
done
export PATH=$PATH:$PWD/scripts

# echo "export PATH=$PATH:$PWD/scripts" >> "$HOME/.bashrc"
