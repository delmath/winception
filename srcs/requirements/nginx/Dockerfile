FROM debian:bookworm

ARG DOMAIN_NAME
ENV DOMAIN_NAME=${DOMAIN_NAME}

RUN apt-get update && apt-get install -y nginx openssl procps && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN echo "[req]\n\
default_bits = 2048\n\
prompt = no\n\
default_md = sha256\n\
distinguished_name = dn\n\
req_extensions = v3_req\n\
\n\
[dn]\n\
C = FR\n\
ST = ARA\n\
L = Lyon\n\
O = 42\n\
OU = Inception\n\
CN = ${DOMAIN_NAME}\n\
\n\
[v3_req]\n\
subjectAltName = @alt_names\n\
\n\
[alt_names]\n\
DNS.1 = ${DOMAIN_NAME}\n\
DNS.2 = www.${DOMAIN_NAME}\n\
DNS.3 = adminer.${DOMAIN_NAME}\n\
DNS.4 = static.${DOMAIN_NAME}\n\
DNS.5 = portainer.${DOMAIN_NAME}" > /tmp/openssl.cnf

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -config /tmp/openssl.cnf \
    -extensions v3_req && rm /tmp/openssl.cnf

COPY conf/default.conf /etc/nginx/conf.d/default.conf.template

RUN sed "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
    rm /etc/nginx/conf.d/default.conf.template

RUN rm -f /etc/nginx/sites-enabled/default

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
