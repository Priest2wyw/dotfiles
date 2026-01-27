SHELL := bash
.DEFAULT_GOAL := help

COMPOSE ?= docker compose
COMPOSE_FILE ?= docker-compose.yml

.PHONY: help up down restart ps logs pull verify save-images load-images

help:
	@echo "Targets:"
	@echo "  make up           Start services in background"
	@echo "  make down         Stop services"
	@echo "  make restart      Restart services"
	@echo "  make ps           Show container status"
	@echo "  make logs         Follow logs"
	@echo "  make pull         Pull images"
	@echo "  make verify       Verify config/ports"
	@echo "  make save-images  docker save images to tar"
	@echo "  make load-images  docker load images from images/"

up:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

restart:
	$(COMPOSE) -f $(COMPOSE_FILE) restart

ps:
	$(COMPOSE) -f $(COMPOSE_FILE) ps

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f --tail=200

pull:
	$(COMPOSE) -f $(COMPOSE_FILE) pull

verify:
	./scripts/verify.sh

save-images:
	./scripts/save-images.sh

load-images:
	./scripts/load-images.sh

