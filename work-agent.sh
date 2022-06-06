#!/usr/bin/bash
export SSH_AUTH_SOCK=/run/user/1000/ssh-work.socket
ssh-add keys/work/id_rsa
