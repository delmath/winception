#!/bin/bash

mkdir -p /run/php
chown -R www-data:www-data /run/php

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "First installation detected..."
	echo "Downloading WordPress..."
	wget https://wordpress.org/latest.tar.gz
	tar -xzf latest.tar.gz
	mv wordpress/* /var/www/html/
	rm -rf latest.tar.gz wordpress
	chown -R www-data:www-data /var/www/html

	echo "Waiting for MariaDB database..."
	while ! mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" &> /dev/null; do
		sleep 2
	done
	echo "MariaDB is available."

	echo "Creating wp-config.php..."
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp

	wp config create --allow-root \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${MYSQL_PASSWORD} \
		--dbhost=mariadb \
		--path='/var/www/html'

	echo "Installing WordPress..."
	wp core install --allow-root \
		--url=${DOMAIN_NAME} \
		--title="Inception Project" \
		--admin_user=${MYSQL_ADMIN_USER} \
		--admin_password=${MYSQL_ADMIN_PASSWORD} \
		--admin_email="admin@example.com" \
		--skip-email \
		--path='/var/www/html'

	wp user create --allow-root \
		${MYSQL_USER} user@example.com \
		--role=author \
		--user_pass=${MYSQL_PASSWORD} \
		--path='/var/www/html'

	echo "Configuring Redis cache..."
	if ! grep -q "WP_REDIS_HOST" /var/www/html/wp-config.php; then
		sed -i "/\/\* That's all, stop editing!/i \
/* Redis Cache Configuration */\n\
define('WP_REDIS_HOST', 'redis');\n\
define('WP_REDIS_PORT', '6379');\n\
define('WP_REDIS_TIMEOUT', 1);\n\
define('WP_REDIS_READ_TIMEOUT', 1);\n\
define('WP_REDIS_DATABASE', 0);\n\
define('WP_CACHE', true);\n\
" /var/www/html/wp-config.php
		echo "Redis cache configuration added to wp-config.php"
	else
		echo "Redis cache already configured"
	fi

	if [ ! -d /var/www/html/wp-content/plugins/redis-cache ]; then
		echo "Installing Redis Object Cache plugin..."
		wget https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip -O /tmp/redis-cache.zip
		unzip -q /tmp/redis-cache.zip -d /var/www/html/wp-content/plugins/
		rm /tmp/redis-cache.zip
		chown -R www-data:www-data /var/www/html/wp-content/plugins/redis-cache
		echo "Redis Object Cache plugin installed"
	else
		echo "Redis Object Cache plugin already installed"
	fi

	echo "Activating Redis Object Cache plugin..."
	wp plugin activate redis-cache --allow-root --path='/var/www/html'

	echo "Installing Redis drop-in (object-cache.php)..."
	if [ -f /var/www/html/wp-content/plugins/redis-cache/includes/object-cache.php ]; then
		cp /var/www/html/wp-content/plugins/redis-cache/includes/object-cache.php /var/www/html/wp-content/object-cache.php
		chown www-data:www-data /var/www/html/wp-content/object-cache.php
		echo "Redis drop-in installed successfully"
	else
		echo "Warning: Redis drop-in not found in plugin directory"
	fi

	echo "Cleaning up WP-CLI..."
	rm -f /usr/local/bin/wp

	echo "WordPress configured and ready to use."
fi

exec /usr/sbin/php-fpm7.4 -F
