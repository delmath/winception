FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	wget \
	php7.4-fpm \
	php7.4-mysql \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget -O adminer.php https://www.adminer.org/latest.php && \
	chown -R www-data:www-data /var/www/html

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9001/g' /etc/php/7.4/fpm/pool.d/www.conf

EXPOSE 9001

CMD ["php-fpm7.4", "-F"]
