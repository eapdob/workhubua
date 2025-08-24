PROJECT_NAME=workhubua

# main
.PHONY: docker_up docker_up_dev docker_down docker_restart docker_restart_dev docker_logs docker_logs_nginx docker_logs_php docker_logs_postgres docker_logs_redis

docker_up:
	docker compose up --build --force-recreate -d

docker_up_dev:
	docker compose up --build --force-recreate

docker_down:
	docker compose down --remove-orphans

docker_restart:
	docker_down docker_up

docker_restart_dev:
	docker_down docker_up_dev

docker_logs:
	docker compose logs -f

docker_logs_nginx:
	docker compose logs -f nginx

docker_logs_php:
	docker compose logs -f php-fpm

docker_logs_postgres:
	docker compose logs -f postgres

docker_logs_redis:
	docker compose logs -f redis

# permissions
.PHONY: docker_fix_permissions docker_create_dirs

docker_fix_permissions:
	sudo chown -R $(id -u):$(id -g) docker/volumes

docker_create_dirs:
	mkdir -p docker/volumes/postgres
	mkdir -p docker/volumes/redis
	mkdir -p docker/volumes/nginx/certificates
	mkdir -p docker/volumes/nginx/log

# ssl
.PHONY: docker_certs

docker_certs: docker_create_dirs
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout docker/volumes/nginx/certificates/workhub.ua.key \
	-out docker/volumes/nginx/certificates/workhub.ua.crt \
	-subj "/C=UA/ST=Kharkivska/L=Kharkiv/O=WorkHub/CN=workhub.ua" && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout docker/volumes/nginx/certificates/workhub.in.ua.key \
	-out docker/volumes/nginx/certificates/workhub.in.ua.crt \
	-subj "/C=UA/ST=Kharkivska/L=Kharkiv/O=WorkHub/CN=workhub.in.ua"

# clear
.PHONY: docker_clean_logs docker_clean_all docker_prune

docker_clean_logs:
	sudo rm -rf docker/volumes/nginx/log/*

docker_clean_all: docker_down
	docker system prune -f
	docker volume prune -f
	sudo rm -rf docker/volumes/postgres/*
	sudo rm -rf docker/volumes/redis/*

docker_prune:
	docker system prune -f
	docker volume prune -f

# managing
.PHONY: docker_shell_php docker_shell_nginx docker_composer

docker_shell_php:
	docker compose exec php-fpm bash

docker_shell_nginx:
	docker compose exec nginx sh

docker_composer:
	docker compose exec php-fpm composer $(ARGS)

# example: make docker_composer ARGS="install"
#         make docker_composer ARGS="require symfony/console"

# db
.PHONY: docker_db_shell docker_db_backup docker_db_restore

docker_db_shell:
	docker compose exec postgres psql -U $${POSTGRES_USER} -d $${POSTGRES_DB}

docker_db_backup:
	docker compose exec postgres pg_dump -U $${POSTGRES_USER} $${POSTGRES_DB} > backup_$$(date +%Y%m%d_%H%M%S).sql

docker_db_restore:
	docker compose exec -T postgres psql -U $${POSTGRES_USER} -d $${POSTGRES_DB} < $(FILE)

# example: make docker_db_restore FILE=backup_20240824_120000.sql

# status
.PHONY: docker_status docker_ps

docker_status:
	docker compose ps
	@echo "\n📊 Resource Usage:"
	docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

docker_ps:
	docker compose ps

# fast launch
.PHONY: setup setup_dev

setup: docker_create_dirs docker_certs docker_fix_permissions docker_up

setup_dev: docker_create_dirs docker_certs docker_fix_permissions docker_up_dev

# help
.PHONY: help

help:
	@echo "🐳 $(PROJECT_NAME) Docker Commands"
	@echo ""
	@echo "📦 main:"
	@echo " setup - Full setup for production"
	@echo " setup_dev - Full setup for development"
	@echo " docker_up - Start containers in the background"
	@echo " docker_up_dev - Start containers with logs"
	@echo " docker_down - Stop containers"
	@echo " docker_restart - Restart containers"
	@echo ""
	@echo "📋 logs:"
	@echo " docker_logs - All logs"
	@echo " docker_logs_* - Logs for a specific service"
	@echo ""
	@echo "🔐 ssl & permissions:"
	@echo " docker_certs - Create SSL certificates"
	@echo " docker_fix_permissions - Fix permissions"
	@echo ""
	@echo "🗄️ db:"
	@echo " docker_db_shell - Connect to PostgreSQL"
	@echo " docker_db_backup- Create a database backup"
	@echo " docker_db_restore FILE=file.sql - Restore the database"
	@echo ""
	@echo "🛠️ utilits:"
	@echo " docker_shell_* - Enter the container"
	@echo " docker_composer - Run Composer"
	@echo " docker_status - Show status and resources"
	@echo " docker_clean_* - Cleanup"

# default
.DEFAULT_GOAL := help