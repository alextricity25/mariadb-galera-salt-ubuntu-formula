common:
  salt.state:
    - tgt: '*'
    - sls:
      - common


haproxy: 
  salt.state:
    - tgt: 'roles:haproxy'
    - tgt_type: grain
    - sls: 
      - haproxy
    - require:
      - salt: common

bootstrap:
  salt.state:
    - tgt: 'roles:db_bootstrap'
    - tgt_type: grain
    - sls:
      - xtrabackup
      - galera
    - require:
      - salt: haproxy

non-bootstrap:
  salt.state:
    - tgt: 'roles:db'
    - tgt_type: grain
    - sls: 
      - xtrabackup
      - galera
    - require:
      - salt: bootstrap
