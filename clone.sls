clone_precursor:
  qvm.template_installed:
    - name: debian-11

qvm-clone-id:
  qvm.clone:
    - require:
    - source: debian-11
