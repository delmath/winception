FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -L https://github.com/portainer/portainer/releases/download/2.20.3/portainer-2.20.3-linux-amd64.tar.gz -o portainer.tar.gz && \
    tar xzf portainer.tar.gz && \
    mv portainer /opt/portainer && \
    rm -rf /tmp/portainer.tar.gz

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
