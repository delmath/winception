#!/bin/bash
set -e

mkdir -p /run/php
chown -R www-data:www-data /run/php

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "First installation detected"

	echo "Downloading WordPress..."
	wget -q https://wordpress.org/latest.tar.gz
	tar -xzf latest.tar.gz
	mv wordpress/* /var/www/html/
	rm -rf latest.tar.gz wordpress
	chown -R www-data:www-data /var/www/html

	echo "Installing WP-CLI..."
	wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp

	echo "Creating wp-config.php..."
	wp config create --allow-root \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost=mariadb \
		--path='/var/www/html'

	echo "Installing WordPress..."
	wp core install --allow-root \
		--url="$DOMAIN_NAME" \
		--title="Inception Project" \
		--admin_user="$MYSQL_ADMIN_USER" \
		--admin_password="$MYSQL_ADMIN_PASSWORD" \
		--admin_email="admin@example.com" \
		--skip-email \
		--path='/var/www/html'

	echo "Creating user..."
	wp user create --allow-root \
		"$MYSQL_USER" user@example.com \
		--role=author \
		--user_pass="$MYSQL_PASSWORD" \
		--path='/var/www/html'

	echo "Configuring Redis..."
	sed -i "/\/\* That's all, stop editing!/i \
			define('WP_REDIS_HOST', 'redis');\n\
			define('WP_REDIS_PORT', '6379');\n\
			define('WP_REDIS_TIMEOUT', 1);\n\
			define('WP_REDIS_READ_TIMEOUT', 1);\n\
			define('WP_REDIS_DATABASE', 0);\n\
			define('WP_CACHE', true);\n\
			" /var/www/html/wp-config.php

	echo "Installing Redis plugin..."
	wget -q https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip -O /tmp/redis-cache.zip
	unzip -q /tmp/redis-cache.zip -d /var/www/html/wp-content/plugins/
	rm /tmp/redis-cache.zip
	chown -R www-data:www-data /var/www/html/wp-content/plugins/redis-cache

	echo "Activating Redis plugin..."
	wp plugin activate redis-cache --allow-root --path='/var/www/html'

	if [ -f /var/www/html/wp-content/plugins/redis-cache/includes/object-cache.php ]; then
		cp /var/www/html/wp-content/plugins/redis-cache/includes/object-cache.php \
		   /var/www/html/wp-content/object-cache.php
		chown www-data:www-data /var/www/html/wp-content/object-cache.php
		echo "Redis drop-in installed"
	fi

	rm -f /usr/local/bin/wp
	echo "WordPress installation complete"
else
	echo "WordPress already installed"
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
