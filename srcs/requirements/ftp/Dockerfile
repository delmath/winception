FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd openssl && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY conf/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 21 21000-21010

CMD ["/entrypoint.sh"]
