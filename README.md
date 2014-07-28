salt-mariadb
============

MariaDB Galera cluster using Salt


Ubuntu-Install
============

The Ubuntu installation is slightly different then that of CentOS and Fedora. 
* Need to specify keyserver
* We will only be working with a couple of configuration files.
* The configuration files are /etc/mysql/conf.d/cluster.cnf and /etc/mysql/debian.cnf

The installtion is based of DigitalOcean's tutorial on installing MariaDB/Galera on Ubuntu 12.04. 
https://www.digitalocean.com/community/tutorials/how-to-configure-a-galera-cluster-with-mariadb-on-ubuntu-12-04-servers
