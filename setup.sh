#!/bin/bash

if [ -f /etc/redhat-release ]
then
  sudo yum install tree -y
fi

if [ -f /etc/lsb-release ]
then
  sudo apt install tree -y
fi


for file in `ls ./scripts`
do
chmod +x "$PWD/scripts/$file"
done
export PATH=$PATH:$PWD/scripts

# echo "export PATH=$PATH:$PWD/scripts" >> "$HOME/.bashrc"
