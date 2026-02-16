FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php-fpm php-mysql php-cli php-redis wget vim procps mariadb-client unzip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
