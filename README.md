# qubes-ssh-agent
This is an alternative approach to the existing [qubes split-ssh](https://github.com/henn/qubes-app-split-ssh).  
It is ideal for use cases where you have a number of key pairs, which are used by different qubes.

The ssh-agent server is based on a clone of the debian-12-minimal template, and is offline.
You may choose to additionally change security settings for file copy or clipboard access by editing the relevant policies.

The keypairs are stored on the offline ssh-agent server, and requests are passed from clients to the server via qrexec.  
Clients may access the same ssh-agent, or access different agents.  
Access is controlled via dom0 policy files, as usual.  
The client need not know the identity of the ssh-agent server, nor are keys kept in memory in the client.

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

Keys can be selectively allocated to different ssh-agents.

A qubes-rpc agent is added that directs incoming qrexec calls to the right ssh-agent.

## On the client:
`socat` is used to take over the normal ssh-agent socket, and make a qrexec call to the ssh-agent server.
Use of a `@dispvm` target hides the name of the actual ssh-agent server qube.  
This is put in place in `~/.bashrc`

## Policies in dom0:
Standard policy rules are used to direct the qrexec call to the ssh-agent qube.
These rules also ensure that client qubes can only access authorized ssh-agents.  
E.g - in `/etc/qubes/policy.d/50-config-splitssh.policy`
```
qubes.SshAgent work  work  @anyvm ask default_target sys-ssh-agent
qubes.SshAgent  *    @anyvm  @anyvm deny

```

These rules ensure that the work qube will be able to access the work ssh-Agent, and no other qube can.  
You can have multiple agents defined, and also more than one server:  

```
qubes.SshAgent work       work      @anyvm ask default_target sys-ssh-agent
qubes.SshAgent untrusted  untrusted @anyvm ask default_target sys-ssh-agent
qubes.SshAgent personal   personal  @anyvm ask default_target sys-ssh-agent
qubes.SshAgent work       qubes     @anyvm ask default_target sys-ssh-agent2
qubes.SshAgent  *         @anyvm    @anyvm deny

```


## Installation
### On the ssh-agent qube
1. Move your keypairs to the offline ssh-agent qube in `~/keys`.  
2. Create a user-agent as described above.
3. Copy the `qubes.SshAgent` file to `/etc/qubes-rpc`

### On the client
4. Edit the contents of `client` to match the name of the ssh-agent you are targeting. 
5. Add the contents of `client` to `~/.bashrc`

### In dom0
6. Copy `qubes.SshAgent-policy` to `/etc/qubes-rpc/policy/qubes.SshAgent`
7. Copy `qubes.SshAgent+work-policy` to `/etc/qubes-rpc/policy/qubes.SshAgent+work`
8. Change the name of that policy file to match the ssh-agent you are targeting.
9. Edit that policy file so that the target matches the name of the ssh-agent qube you want to use.

Notice that by default, the policy file uses *ask*.
This means that you will be prompted each time an application attempts to access the ssh-agent.
You may want to change this to *allow* at some cost to security.

For exceptionally valuable keys you may want to limit the time that they are available.
You can do this by using `ssh-add -t <secs> ...` when you add the key to the agent.
After <secs> seconds, the key will be removed from the agent.

