mdb_cluster:
  name: test_cluster
  nodes:
    mygalera01: 162.209.79.215
    mygalera02: 166.78.60.13
    mygalera03: 166.78.60.17

mdb_cfg_files:
 
  ubuntu_cluster: 
    path: /etc/mysql/conf.d/cluster.cnf
    source: salt://galera/config/cluster.cnf
  ubuntu_maintenance: 
    path: /etc/mysql/debian.cnf
    source: salt://galera/config/debian.cnf
  

{% if grains['osfinger'] == 'Ubuntu-12.04' %}
  {% set os = 'ubuntu' %}
{% elif grains['osfinger'] == 'Ubuntu-14.04' %}
  {% set os = 'ubuntu' %}
{% else %}
  {% set os = 'os_undefined' %}
{% endif %}

{% if grains['cpuarch'] == 'x86_64' %}
  {% set arch = 'amd64' %}
{% else %}
  {% set arch = 'x86' %}
{% endif %}

mdb_config:
{% if arch == 'amd64' %}
  provider: /usr/lib64/galera/libgalera_smm.so
{% else %}
  provider: /usr/lib/galera/libgalera_smm.so
{% endif %}

mdb_repo:
    baseurl: http://mirror.jmu.edu/pub/mariadb/repo/5.5/{{ os }}
    keyserver: hkp://keyserver.ubuntu.com:80
    keyid: '0xcbcb082a1bb943db'
    file: /etc/apt/sources.list

  
