SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml
DATA_DIR = /home/madelvin/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DIR = $(DATA_DIR)/wordpress
DOCKER_COMPOSE = docker-compose -f $(COMPOSE_FILE)

.DEFAULT_GOAL := help

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

help:
	@echo "╔══════════════════════════════════════════════════════════╗"
	@echo "║      INCEPTION - WordPress with Docker + Bonus          ║"
	@echo "╚══════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📦 Main commands:"
	@echo ""
	@echo "  make all         - Build and start containers"
	@echo "  make build       - Build Docker images"
	@echo "  make up          - Start containers"
	@echo "  make stop        - Stop containers"
	@echo "  make down        - Stop and remove containers"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo ""
	@echo "  make clean       - ⚠️  DELETES your WordPress data!"
	@echo "  make fclean      - ⚠️  Full cleanup (data + images)"
	@echo "  make re          - ⚠️  Full rebuild (fclean + all)"
	@echo ""
	@echo "💾 Persistent data:"
	@echo ""
	@echo "  Your WordPress changes are saved in:"
	@echo "  → /home/madelvin/data/wordpress/"
	@echo "  → /home/madelvin/data/mariadb/"
	@echo ""
	@echo "🎁 Bonus services:"
	@echo ""
	@echo "  Redis Cache    - WordPress caching"
	@echo "  FTP Server     - Port 21 (ftpuser/ftppass)"
	@echo "  Adminer        - http://localhost:8080"
	@echo "  Static Site    - http://localhost:8000"
	@echo ""
	@echo "  ✅ 'make stop/up/down' → Data PRESERVED"
	@echo "  ❌ 'make clean/fclean' → Data DELETED"
	@echo ""
	@echo "📖 Documentation:"
	@echo ""
	@echo "  cat PERSISTENT_DATA.md  - Persistent data guide"
	@echo ""
	@echo "════════════════════════════════════════════════════════════"

.PHONY: all build up stop down clean fclean re help
