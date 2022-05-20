#!/bin/bash
sudo apt install tree -y
for file in `ls ./scripts` 
do 
chmod +x "$PWD/scripts/$file"
done
export PATH=$PATH:$PWD/scripts

# echo "export PATH=$PATH:$PWD/scripts" >> "$HOME/.bashrc"
