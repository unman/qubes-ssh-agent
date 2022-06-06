#!/bin/bash
echo "Set up a new ssh-agent y/n?" 
read -n 1 response ;
if [ "$response" == "y" ]; then
  read -p "What one word name do you want to use?" name ;
  if [ "$name" == "" ]; then
    echo ""
    echo "No name entered. Nothing to do."
    exit
  else
cat << EOF > /home/user/.local/share/systemd/user/ssh-$name.service:
[Unit]
Description=SSH agent for $name
Before=default.target

[Service]
Type=forking
Environment=SSH_AUTH_SOCK=%t/ssh-$name.socket
ExecStart=/usr/bin/ssh-agent -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

  fi
else
  clear
  echo "Nothing to do."
  exit
fi

