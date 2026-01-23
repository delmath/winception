#!/bin/bash

mkdir -p /run/php
chown -R www-data:www-data /run/php

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "First installation detected..."

	if [ -f /usr/local/share/wordpress_template.tar.gz ]; then
		echo "WordPress template files detected!"
		echo "   Extracting your configured site..."
		tar -xzf /usr/local/share/wordpress_template.tar.gz -C /var/www/html/
		chown -R www-data:www-data /var/www/html
		echo "WordPress files restored from template!"
	else
		echo "No template found, downloading WordPress..."
		wget https://wordpress.org/latest.tar.gz
		tar -xzf latest.tar.gz
		mv wordpress/* /var/www/html/
		rm -rf latest.tar.gz wordpress
		chown -R www-data:www-data /var/www/html
	fi

	echo "Waiting for MariaDB database..."
	while ! mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" &> /dev/null; do
		sleep 2
	done
	echo "MariaDB is available."

	if [ ! -f /var/www/html/wp-config.php ]; then
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

		TABLE_COUNT=$(mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} -e "SHOW TABLES;" 2>/dev/null | wc -l)

		if [ "$TABLE_COUNT" -gt 1 ]; then
			echo "Database already configured (template imported)"
			echo "Your site is restored with all your pages and settings!"
		else
			echo "Empty database, installing default WordPress..."
			wp core install --allow-root \
				--url=${DOMAIN_NAME} \
				--title="Inception Project" \
				--admin_user=${MYSQL_ADMIN_USER} \
				--admin_password=${MYSQL_ADMIN_PASSWORD} \
				--admin_email="manager@${DOMAIN_NAME}" \
				--skip-email \
				--path='/var/www/html'

			wp user create --allow-root \
				${MYSQL_USER} user@${DOMAIN_NAME} \
				--role=author \
				--user_pass=${MYSQL_PASSWORD} \
				--path='/var/www/html'
		fi

		rm -f /var/www/html/wp-cli.phar
	else
		echo "wp-config.php already exists (restored from template)"
		echo "Your site is ready!"
	fi

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

	echo "WordPress configured and ready to use."
fi

exec /usr/sbin/php-fpm7.4 -F
