{% set admin_password = pillar['mysql_config']['admin_password'] %}

mariadb-repo:
  pkgrepo.managed:
    - comments:
      {% if grains['os'] != 'Ubuntu' %}
      - '# MariaDB 5.5 CentOS repository list - managed by salt {{ grains['saltversion'] }}'
      - '# http://mariadb.org/mariadb/repositories/'
      {% elif grains['os'] == 'Ubuntu' %}
      - '# MariaDB 5.5 Ubuntu repository list - managed by salt {{ grains['saltversion'] }}'
      - '# http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu'
      {% endif %}

    {% if grains['os'] != 'Ubuntu' %}
    - name: MariaDB
    - humanname: MariaDB
    - baseurl: {{ pillar['mdb_repo']['baseurl'] }}
    - gpgkey: https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    - gpgcheck: 1
    {% elif grains['os'] == 'Ubuntu' %}
    - name: deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu precise main
    - dist: precise
    - file: {{ pillar['mdb_repo']['file'] }} 
    - keyserver: {{ pillar['mdb_repo']['keyserver'] }}
    - keyid: '{{ pillar['mdb_repo']['keyid'] }}'
    - require_in:
      - pkg: mariadb-pkgs
    {% endif %}

{% if grains['os'] == 'Ubuntu' %} 
apt_update: 
  cmd.run: 
    - name: apt-get update
    - require: 
      - pkgrepo: mariadb-repo 
{% endif %} 

{% if grains['os'] == 'Ubuntu' %}
mariadb-debconf: 
  debconf.set:
    - name: mariadb-galera-server
    - data:
        'mysql-server/root_password': {'type':'string','value':{{ admin_password }}}
        'mysql-server/root_password_again': {'type':'string','value':{{ admin_password }}}
{% endif %} 

mariadb-pkgs:
  pkg.installed:
    - names:
      {% if grains['os'] == 'Ubuntu' %}
      - mariadb-galera-server-5.5
      {% endif %} 
      {% if grains['os'] != 'Ubuntu' %}
      - MariaDB-Galera-server
      - MariaDB-client
      {% endif %}
      - galera
    - require:
      - pkgrepo: mariadb-repo
      {% if grains['os'] == 'Ubuntu' %} 
      - debconf: mariadb-debconf
      - cmd: apt_update
      {% endif %}

{% for cfgfile, info in pillar['mdb_cfg_files'].iteritems() %}
{{ info['path'] }}:
  file.managed:
    - source: {{ info['source'] }}
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: mariadb-pkgs
{% endfor %}

{% if grains['os'] == 'Ubuntu' %}
mysql_update_maint:
  cmd.run:
    - name: mysql -u root -p{{ admin_password }} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '{{ pillar['mysql_config']['maintenance_password'] }}';"
    - require:
      - pkg: mariadb-pkgs
{% endif %}

iptables:
  pkg:
    - installed


{% if grains['os'] != 'Ubuntu' %}
{% for port, info in pillar['mdb_ports'].iteritems() %}
port_{{ port }}:
  cmd.run:
    - name: iptables -I INPUT -p {{ info['protocol'] }} -m state --state NEW --dport {{ port }} -j ACCEPT
    - unless: "iptables -L | grep {{ info['name'] }} | grep ACCEPT"
    - require:
      - pkg: iptables
{% endfor %}
{% endif %}


{% if grains['os'] != 'Ubuntu' %}
policycoreutils-python:
  pkg:
    - installed
{% endif %}

{% if grains['os'] == 'Ubuntu' %} 
python-software-properties: 
  pkg: 
    - installed
{% endif %}

{% if grains['os'] != 'Ubuntu' %}
permissive:
  selinux.mode:
    - require:
      - pkg: policycoreutils-python
{% endif %}

rsync:
  pkg:
    - installed

#{% if grains['os'] == 'Ubuntu' %} 
#mysql_first_start:
#  service: 
#    - name: mysql
#    - running
#    - require: 
#      - pkg: mariadb-pkgs
#{% endif %}

#{% if grains['os'] == 'Ubuntu' %}
#mysql_update_maint:
#  cmd.run:
#    - name: mysql -u root -p{{ admin_password }} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '{{ pillar['mysql_config']['maintenance_password'] }}';"
#    - require:
#      - pkg: mariadb-pkgs
#{% endif %} 

{% if grains['os'] == 'Ubuntu' %}
mysql_stop: 
  service: 
    - name: mysql 
    - dead
{% endif %} 


{% if grains['roles'][0] == 'mariadb_base' %}
start_wsrep:
  cmd.run:
    - name: "service mysql start --wsrep-new-cluster"
    - require: 
      - pkg: mariadb-pkgs
      - service.dead: mysql
      - cmd: mysql_update_maint

{% endif %} 


{% if grains['roles'][0] != 'mariadb_base' %} 
mysql:
  service.running:
    - reload: True
    - watch:
      {% for cfgfile, info in pillar['mdb_cfg_files'].iteritems() %}
      - file: {{ info['path'] }}
      {% endfor %}
    - require:
      {% if grains['os'] != 'Ubuntu' %}
      {% for port in pillar['mdb_ports'] %}
      - cmd: port_{{ port }}
      {% endfor %}
      {% elif grains['os'] == 'Ubuntu' %}
      - cmd: mysql_update_maint
      {% if grains['roles'] == 'mariadb_base' %}
      - cmd: start_wsrep
      {% endif %} 
      {% endif %}
      - pkg: rsync
      - pkg: mariadb-pkgs
{% endif %}
