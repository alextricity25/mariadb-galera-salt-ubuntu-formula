base: 
  'roles:haproxy':
    - match: grain
    - haproxy
  'roles:db_bootstrap': 
    - match: grain
    - mysql
    - galera
  'roles:db': 
    - match: grain
    - mysql
    - galera
