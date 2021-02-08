# qubes-ssh-agent
This is an alternative approach to the existing [qubes split-ssh](https://github.com/henn/qubes-app-split-ssh).  
It is ideal for use cases where you have a number of key pairs, which are used by different qubes.

The keypairs are stored on the offline ssh-agent server, and requests are passed from clients to the server via qrexec.  
Clients may access the same ssh-agent, or access different agents.  
Access is controlled via dom0 policy files, as usual.  
The client does not know the identity of the ssh-agent server, nor are keys kept in memory in the client.

All configuration of keys, and unlocking of keys, where they are password protected, is done in the ssh-agent server, using standard ssh-agent controls.


## Setting up multiple agents on the server.
This is straightforward.  
For each ssh-agent, adapt this template, changing `work` to whatever group name is needed.
```
[Unit]
Description=SSH agent for work
Before=default.target

[Service]
Type=forking
Environment=SSH_AUTH_SOCK=%t/ssh-work.socket
ExecStart=/usr/bin/ssh-agent -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
```
Save the file as `$HOME/.local/share/systemd/user/ssh-work.service`.  
Enable the service:
`systemctl --user enable ssh-work`

On rebooting the ssh-agent server, a 'work' ssh-agent will be created.
It can be accessed at `/run/user/1000/ssh-work.socket`.

The agent can be controlled by setting the environment:
`export SSH_AUTH_SOCK="/run/user/1000/ssh-work.socket"`  
Then use standard tools, `ssh-add`

Keys can be selectively added to different agents.

A qubes-rpc agent is added that directs incoming qrexec calls to the right ssh-agent.

## On the client:
`socat` is used to take over the normal ssh-agent socket, and make a qrexec call to the ssh-agent server.
Use of a `@dispvm` target hides the name of the actual ssh-agent server qube.  
This is put in place in `~/.bashrc`

## Policies in dom0:
Standard policy rules are used to direct the qrexec call to the ssh-agent qube.
These rules also ensure that client qubes can only access authorized ssh-agents.

