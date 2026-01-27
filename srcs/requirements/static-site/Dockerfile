FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    git \
    nginx \
    python3 \
    python3-markdown \
    python3-pygments \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/Liammmmmmmm/42-miniRT.wiki.git wiki
COPY tools/convert.py /app/convert.py
RUN chmod +x /app/convert.py
RUN python3 /app/convert.py
RUN echo 'server {\n\
    listen 8000;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
    try_files $uri $uri/ =404;\n\
    }\n\
    }' > /etc/nginx/sites-available/default

EXPOSE 8000

CMD ["nginx", "-g", "daemon off;"]
