# MVP Store Payment Service Commands

init: network-create docker-build up run-app
	@echo "Payment service initialized successfully!"
	@echo "Service available at: http://localhost:8192 (direct) or http://localhost:8090/api/payment (via gateway)"

up:
	docker-compose -f docker/docker-compose.yml up -d

up-local:
	docker-compose -f docker/docker-compose.yml --profile local-dev up -d

down:
	docker-compose -f docker/docker-compose.yml down --remove-orphans

restart: down up

exec_bash:
	docker exec -it mvp-store-payment sh

test:
	@echo "Running payment tests..."
	docker exec -it mvp-store-payment php bin/phpunit

docker-build:
	docker-compose -f docker/docker-compose.yml build --no-cache
	#docker-compose -f docker/docker-compose.yml build

clean: down
	docker-compose -f docker/docker-compose.yml down -v --remove-orphans
	docker image rm mvp-store-payment-service_payment

# Application management
run-app: composer-install payment-migrate
	@echo "Application setup completed"

composer-install:
	docker exec -it mvp-store-payment composer install --optimize-autoloader

payment-migrate:
	docker exec -it mvp-store-payment php bin/console doctrine:migrations:migrate --no-interaction

payment-fixture:
	docker exec -it mvp-store-payment php bin/console doctrine:fixtures:load --no-interaction

fixer:
	@echo "Fixing code style..."
	docker exec -it mvp-store-payment tools/php-cs-fixer/vendor/bin/php-cs-fixer fix src

# Network management
network-create:
	@echo "Creating shared network..."
	@docker network create mvp_store_network || echo "Network already exists"
