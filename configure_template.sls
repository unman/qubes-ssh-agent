# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% if salt['pillar.get']('update_proxy:caching') %}
{% set proxy = 'cacher' %}
{% endif %}

{% if grains['nodename'] != 'dom0' %}
{% if grains['os_family']|lower == 'debian' %}
{% if grains['nodename']|lower != 'host' %}
{% if proxy  == 'cacher' %}
{% for repo in salt['file.find']('/etc/apt/sources.list.d/', name='*list') %}
{{ repo }}_baseurl:
  file.replace:
    - name: {{ repo }}
    - pattern: 'https://'
    - repl: 'http://HTTPS///'
    - flags: [ 'IGNORECASE', 'MULTILINE' ]
    - backup: False

{% endfor %}

/etc/apt/sources.list:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: 'https:'
    - repl: 'http://HTTPS/'
    - flags: [ 'IGNORECASE', 'MULTILINE' ]
    - backup: False

{% endif %}

install_agent:
  pkg.installed:
    - refresh: True
    - pkgs:
      - openssh-client
      - socat

/skel/.local/share/systemd/user/ssh-work.service:
  file.managed:
    - source: salt://qubes-ssh-agent/agent_unit
    - user: user
    - group: user
    - makedirs: True

loginctl enable-linger user:
  cmd.run

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


{% endif %}
{% endif %}

{% endif %}








