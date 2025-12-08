COMPOSE_FILE=srcs/docker-compose.yml
VOLUMES_DIR=~/data/wordpress ~/data/mariadb 

all:
	mkdir -p $(VOLUMES_DIR)
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

restart: down all

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	sudo rm -rf $(VOLUMES_DIR)

prune: down clean
	docker system prune -af --volumes

fclean: clean prune

re: fclean all

debug: rebuild logs

.PHONY: all up down restart logs clean prune re fclean