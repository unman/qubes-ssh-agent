include:
  - template-debian-11

qvm-clone-id:
  qvm.clone:
    - require:
      - sls: template-debian-11
    - name: template-ssh-agent
    - source: debian-11
