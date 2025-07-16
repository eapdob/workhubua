PROJECT_NAME=workhubua

docker_up:
	docker compose up --build --force-recreate -d

docker_up_dev:
	docker compose up --build --force-recreate

docker_down:
	docker compose down --remove-orphans

docker_logs:
	docker compose logs -f

docker_fix_permissions:
	sudo chown -R $$(id -u):$$(id -g) docker/volumes

docker_certs:
	mkdir -p docker/volumes/nginx/certificates && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout docker/volumes/nginx/certificates/workhub.ua.key \
	-out docker/volumes/nginx/certificates/workhub.ua.crt \
	-subj "/C=UA/ST=Kharkivska/L=Kharkiv/O=WorkHub/CN=workhub.ua" && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout docker/volumes/nginx/certificates/workhub.in.ua.key \
	-out docker/volumes/nginx/certificates/workhub.in.ua.crt \
	-subj "/C=UA/ST=Kharkivska/L=Kharkiv/O=WorkHub/CN=workhub.in.ua"

docker_clean_logs:
	sudo rm -rf docker/volumes/nginx/log/*