ssh_precursor:
  - qvm.template_installed:
    - name: template-debian-11-minimal

qvm-clone-id:
  qvm.clone:
    - name: template-ssh-agent
    - source: debian-11
