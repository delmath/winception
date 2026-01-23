FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	python3 \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY conf/server.py /app/
COPY conf/static /app/static

EXPOSE 8000

CMD ["python3", "server.py"]
