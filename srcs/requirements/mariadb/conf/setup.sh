#!/bin/bash

set -e

if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "MariaDB is already initialized. Starting server..."
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
	exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
fi

echo "First initialization of MariaDB..."

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Installing system database..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

echo "MariaDB is temporarily starting up..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --bind-address=0.0.0.0 &
MYSQL_PID=$!

echo "Waiting for MariaDB to start..."
for i in {30..0}; do
	if mysqladmin ping --silent 2>/dev/null; then
		break
	fi
	echo "MariaDB is starting... $i"
	sleep 1
done

if [ "$i" = 0 ]; then
	echo "Error: MariaDB did not start"
	exit 1
fi

echo "MariaDB is ready for initialization..."

echo "Configuring MariaDB..."

mysql <<-EOSQL
	DELETE FROM mysql.user WHERE User='';
	DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
	DROP DATABASE IF EXISTS test;
	DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

	CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
	GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;

	FLUSH PRIVILEGES;
EOSQL

echo "MariaDB configured successfully."

echo "Temporary server shutdown..."
if ! mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown; then
	echo "Error stopping MariaDB, attempted to kill..."
	kill -TERM $MYSQL_PID
	wait $MYSQL_PID
fi

echo "Restarting MariaDB in production mode..."
sleep 2

exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
