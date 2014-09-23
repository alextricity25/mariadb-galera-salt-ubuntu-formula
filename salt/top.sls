base:
    '*':
        - common
    'roles:haproxy':
        - match: grain
        - haproxy
    'roles:db_bootstrap':
        - match: grain
        - galera
        - xtrabackup
    'roles:db':
        - match: grain
        - galera
        - xtrabackup
