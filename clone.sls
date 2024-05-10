ssh_precursor:
  qvm.template_installed:
    - name: debian-12-minimal

qvm-ssh-id:
  qvm.clone:
    - name: template-ssh-agent
    - source: debian-12-minimal
