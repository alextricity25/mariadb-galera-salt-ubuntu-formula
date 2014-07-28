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


Running the states
============

Once salt-master and salt-minion have been installed, accept the minions salt-key and follow these instructions on the salt-master: 

1. Assign mariadb_base role to one of the nodes in the MariaDB-Galera cluster: 
	* salt <node> grains.setval roles ['mariadb_base']
2. Assign mariadb_slave role to the remaining nodes in the MariaD-Galera cluster. Do the following for each "slave": 
	* salt <node> grains.setval roles ['mariadb_slave']
3. Change the ip address in /srv/pillar/galera/init.sls to match those of your cluster. If you need more than three, simple add another key:value pair in the appropriate spot. 

4. Run galera state on the node with the mariadb_base role
	* salt <base_node> state.sls galera

5. Run galera state on remaning nodes. 
	* salt <slave_node> state.sls galera 


