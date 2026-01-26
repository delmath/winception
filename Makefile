SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml
DATA_DIR = /home/madelvin/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DIR = $(DATA_DIR)/wordpress
DOCKER_COMPOSE = docker-compose -f $(COMPOSE_FILE)

all: build up

$(DATA_DIR):
	mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)

build: $(DATA_DIR)
	$(DOCKER_COMPOSE) build

up: $(DATA_DIR)
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) stop

down:
	$(DOCKER_COMPOSE) down -v

clean: down
	@if [ -d "$(DATA_DIR)" ]; then \
		sudo chown -R $(USER):$(USER) $(DATA_DIR) 2>/dev/null || true; \
	fi
	rm -rf $(DATA_DIR)

fclean: down
	@if [ -d "$(DATA_DIR)" ]; then \
		sudo chown -R $(USER):$(USER) $(DATA_DIR) 2>/dev/null || true; \
	fi
	rm -rf $(DATA_DIR)
	docker rmi -f $$(docker images -q -f "dangling=true") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_nginx") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_wordpress") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_mariadb") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_redis") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_adminer") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_ftp") 2>/dev/null || true
	docker rmi -f $$(docker images -q -f "reference=srcs_static-site") 2>/dev/null || true

re: fclean all

.PHONY: build up stop down clean fclean re all
