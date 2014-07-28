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


A little about MariaDB-Galera
===========

A MariaDB-Galera cluster requires at least three nodes, and there is no distiction between each node. However, because a special flag is needed when first starting the cluster, this formula assigns "roles" for each node in the cluster. Even though I might refer to these nodes as a "slave" or "base", in actuality, MariaDB-Glaera is Multi-Master.

Galera is a Write-Set Replication provider for MariaDB. The configurations are set in /etc/mysql/conf.d/cluster.cnf. Once the formula has been ran properly, you should have a cluster that synchronously replicates data between nodes. To find out more about Galera, please visit galeacluster.com/products

Running the states
============

Once salt-master and salt-minion have been installed, accept the minion's salt-key and follow these instructions on the salt-master: 

1. Assign mariadb_base role to one of the nodes in the MariaDB-Galera cluster: 
	* salt \<node\> grains.setval roles ['mariadb_base']
2. Assign mariadb_slave role to the remaining nodes in the MariaD-Galera cluster. Do the following for each "slave": 
	* salt \<node\> grains.setval roles ['mariadb_slave']
3. Change the ip address in /srv/pillar/galera/init.sls to match those of your cluster. If you need more than three, simple add another key:value pair in the appropriate spot. 

4. Run galera state on the node with the mariadb_base role
	* salt \<base_node\> state.sls galera

5. Run galera state on remaning nodes. 
	* salt \<slave_node\> state.sls galera 


