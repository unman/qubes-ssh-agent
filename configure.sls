# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

/home/user/.local/share/systemd/user/ssh-work.service:
  file.managed:
    - source: salt://qubes-ssh-agent/agent_unit
    - user: user
    - group: user
    - makedirs: True

loginctl enable-linger user:
  cmd.run

enable ssh-work:
  file.symlink:
    - name: /home/user/.config/systemd/user/default.target.wants/ssh-work.service
    - target: /home/user/.local/share/systemd/user/ssh-work.service
    - user: user
    - makedirs: True

create_qrexec:
  file.managed:
    - name: /rw/bind-dirs/etc/qubes-rpc/qubes.SshAgent
    - mode: 775
    - user: root
    - group: root
    - makedirs: True

/rw/bind-dirs/etc/qubes-rpc/qubes.SshAgent:
  file.append:
    - text: |
        #!/bin/sh
        exec socat STDIO UNIX-CLIENT:/run/user/1000/ssh-$1.socket

/rw/config/qubes-bind-dirs.d/50_user.conf:
  file.append:
    - text: binds+=( '/etc/qubes-rpc/qubes.SshAgent' )  
    - makedirs: True

/home/user/keys:
  file.directory:
    - user: user
    - group: user

/home/user/work-agent.sh:
  file.managed:
    - source: salt://qubes-ssh-agent/work-agent.sh
    - user: user
    - group: user
    - mode: 755
    - makedirs: True

/home/user/Configure-new-ssh-agent.sh:
  file.managed:
    - source: salt://qubes-ssh-agent/Configure-new-ssh-agent.sh
    - user: user
    - group: user
    - mode: 755
