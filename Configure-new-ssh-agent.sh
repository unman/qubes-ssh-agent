#!/usr/bin/bash
echo "Set up a new ssh-agent y/n?" 
read -n1 -s response ;
if [ "$response" == "y" ]; then
  read -p "What one word name do you want to use?" name ;
  if [ "$name" == "" ]; then
    echo "No name entered. Nothing to do."
    exit
  else
    if [ -f /home/user/.local/share/systemd/user/ssh-$name.service ] ; then
      echo "That agent already exists"
      exit
    else
      sed s/work/$name/  /home/user/.local/share/systemd/user/ssh-work.service > /home/user/.local/share/systemd/user/ssh-$name.service
      ln -s /home/user/.local/share/systemd/user/ssh-$name.service /home/user/.config/systemd/user/default.target.wants/ssh-$name.service
      head -n2 /home/user/work-agent.sh |sed s/work/$name/ > $name-agent.sh
      chmod +x /home/user/$name-agent.sh
      systemctl --user start ssh-$name.service
    fi
  fi
else
  clear
  echo "Nothing to do."
  exit
fi
