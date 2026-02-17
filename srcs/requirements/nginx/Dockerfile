FROM debian:bookworm

ARG DOMAIN_NAME
ENV DOMAIN_NAME=${DOMAIN_NAME}

RUN apt-get update && apt-get install -y nginx openssl procps && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN cat > /tmp/openssl.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C = FR
ST = ARA
L = Lyon
O = 42
OU = Inception
CN = ${DOMAIN_NAME}

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN_NAME}
DNS.2 = www.${DOMAIN_NAME}
DNS.3 = adminer.${DOMAIN_NAME}
DNS.4 = static.${DOMAIN_NAME}
DNS.5 = portainer.${DOMAIN_NAME}
EOF

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
