include:
  - qubes-ssh-agent.clone

qvm-present-id:
  qvm.present:
    - name: sys-ssh-agent
    - template: template-ssh-agent
    - label: gray

qvm-prefs-id:
  qvm.prefs:
    - name: sys-ssh-agent
    - netvm: none
    - memory: 300
    - maxmem: 800
    - vcpus: 2
    - provides-network: False

qvm-features-id:
  qvm.features:
    - name: sys-ssh-agent
    - ipv6: ''
    - disable:
      - service.cups
      - service.cups-browsed
      - service.tinyproxy

update_file:
  file.prepend:
    - name: /etc/qubes/policy.d/30-user.policy
    - text: |
        qubes.SshAgent  +work  @anyvm  @anyvm ask default_target=sys-ssh-agent
        qubes.SshAgent  *      @anyvm  @anyvm deny
