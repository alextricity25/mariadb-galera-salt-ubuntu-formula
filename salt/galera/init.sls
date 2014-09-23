{% set admin_password = pillar['mysql_config']['admin_password'] %}


# Add MariaDB-Galera Repo
mariadb-repo:
  pkgrepo.managed:
    - comments:
      - '# MariaDB 5.5 Ubuntu repository list - managed by salt {{ grains['saltversion'] }}'
      - '# http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu'
    - name: deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu precise main
    - dist: precise
    - file: {{ pillar['mdb_repo']['file'] }} 
    - keyserver: {{ pillar['mdb_repo']['keyserver'] }}
    - keyid: '{{ pillar['mdb_repo']['keyid'] }}'
    - require_in:
      - pkg: mariadb-pkgs

apt_update: 
  cmd.run: 
    - name: apt-get update
    - require: 
      - pkgrepo: mariadb-repo 

#Pre-seed MariaDB install prompts
mariadb-debconf: 
  debconf.set:
    - name: mariadb-galera-server
    - data:
        'mysql-server/root_password': {'type':'string','value':{{ admin_password }}}
        'mysql-server/root_password_again': {'type':'string','value':{{ admin_password }}}

mariadb-pkgs:
  pkg.installed:
    - names:
      - mariadb-galera-server-5.5
      - galera
    - require:
      - pkgrepo: mariadb-repo
      - debconf: mariadb-debconf
      - cmd: apt_update

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

ensure_running:
  service: 
    - name: mysql
    - running
    - require: 
      - pkg: mariadb-pkgs


#Currently, Ubuntu and Debian's MariaDB servers use a special maintenance user to do routine maintenance. 
#Some tasks that fall outside of the maintenance category also are run as this user, including important 
#functions like stopping MySQL.
mysql_update_maint:
  cmd.run:
    - name: mysql -u root -p{{ admin_password }} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '{{ pillar['mysql_config']['maintenance_password'] }}';"
    - require:
      - pkg: mariadb-pkgs
      - service: ensure_running


## Move this to common salt state file? 
python-software-properties: 
  pkg: 
    - installed

## Move this to common salt state file? 
rsync:
  pkg:
    - installed

mysql_stop: 
  service: 
    - name: mysql 
    - dead


{% if grains['roles'][0] == 'db_bootstrap' %}
start_wsrep:
  cmd.run:
    - name: "service mysql start --wsrep-new-cluster"
    - require: 
      - pkg: mariadb-pkgs
      - service: mysql_stop
      - cmd: mysql_update_maint

{% endif %} 


{% if grains['roles'][0] != 'db_bootstrap' %} 
mysql:
  service.running:
    - reload: True
    - watch:
      {% for cfgfile, info in pillar['mdb_cfg_files'].iteritems() %}
      - file: {{ info['path'] }}
      {% endfor %}
    - require:
      - cmd: mysql_update_maint
      - pkg: rsync
      - pkg: mariadb-pkgs
{% endif %}
