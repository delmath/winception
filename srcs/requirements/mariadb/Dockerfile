FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server procps && \
    rm -rf /var/lib/apt/lists/*

COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
