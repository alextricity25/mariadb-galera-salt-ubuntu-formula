interfaces: 
  private: eth0
  public: eth0
mine_functions: 
  network.ip_addrs: [eth0]
  network.interfaces: []
mine_interval: 1
mdb_cfg_files:
  ubuntu_cluster: 
    path: /etc/mysql/conf.d/cluster.cnf
    source: salt://galera/config/cluster.cnf
  ubuntu_maintenance: 
    path: /etc/mysql/debian.cnf
    source: salt://galera/config/debian.cnf
mdb_config:
  provider: /usr/lib64/galera/libgalera_smm.so
mdb_repo:
    baseurl: http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu
    keyserver: hkp://keyserver.ubuntu.com:80
    keyid: '0xcbcb082a1bb943db'
    file: /etc/apt/sources.list

  

  
