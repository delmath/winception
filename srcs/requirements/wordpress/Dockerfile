FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y php-fpm php-mysql php-cli php-redis wget vim procps mariadb-client unzip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT [ "/usr/local/bin/setup.sh" ]
