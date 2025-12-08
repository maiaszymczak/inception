#!/bin/bash

# create db
if [ ! -f "/var/lib/mysql/$MYSQL_DATABASE" ]; then 
    echo CREATING MARIADB
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    /etc/init.d/mariadb start
    mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mariadb -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWD}';"
    mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
    /etc/init.d/mariadb stop
fi
exec mariadbd --datadir=/var/lib/mysql
