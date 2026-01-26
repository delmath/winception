FROM alpine:3.19

RUN apk add --no-cache curl tar wget && \
    cd /tmp && \
    curl -L https://github.com/portainer/portainer/releases/download/2.11.1/portainer-2.11.1-linux-amd64.tar.gz -o portainer.tar.gz && \
    tar xzf portainer.tar.gz && \
    mv portainer /opt/portainer && \
    rm -rf /tmp/portainer.tar.gz

# Create a stub docker-compose to prevent Portainer from crashing
RUN echo '#!/bin/sh' > /usr/local/bin/docker-compose && \
    echo 'echo "docker-compose stub"' >> /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

RUN mkdir -p /data

COPY tools/init-portainer.sh /usr/local/bin/init-portainer.sh
RUN chmod +x /usr/local/bin/init-portainer.sh

COPY conf/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /opt/portainer

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
