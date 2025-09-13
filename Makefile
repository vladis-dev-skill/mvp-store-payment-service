down: docker-down
up: docker-up
init: docker-down-clear docker-pull docker-build docker-up run-app
exec_bash: docker-exec-bash
test: payment-test

payment-test:
	docker exec -it store_payment_php-fpm php bin/phpunit

docker-up:
	docker-compose -p mvp-store-payment-service -f docker/docker-compose.yml up -d

docker-down:
	docker-compose -p mvp-store-payment-service -f docker/docker-compose.yml down --remove-orphans

docker-down-clear:
	docker-compose -p mvp-store-payment-service -f docker/docker-compose.yml down -v --remove-orphans

docker-pull:
	docker-compose -p mvp-store-payment-service -f docker/docker-compose.yml pull

docker-build:
	docker-compose -p mvp-store-payment-service -f docker/docker-compose.yml build

docker-exec-bash:
	docker exec -it store_payment_php-fpm bash

#Run app

run-app: composer-install payment-migrate #payment-fixture #payment-phpcs

composer-install:
	docker exec -it store_payment_php-fpm composer install

payment-migrate:
	docker exec -it store_payment_php-fpm php bin/console doctrine:migrations:migrate --no-interaction

payment-fixture:
	docker exec -it store_payment_php-fpm php bin/console doctrine:fixtures:load --no-interaction

payment-phpcs: payment-phpcs-mkdir payment-phpcs-composer
payment-phpcs-mkdir:
	docker exec -it store_payment_php-fpm mkdir -p --parents tools/php-cs-fixer
payment-phpcs-composer:
	docker exec -it store_payment_php-fpm composer require --no-interaction --working-dir=tools/php-cs-fixer friendsofphp/php-cs-fixer

fixer:
	docker exec -it store_payment_php-fpm tools/php-cs-fixer/vendor/bin/php-cs-fixer fix src

# Network management
network-create:
	docker network create mvp-store || true

network-remove:
	docker network rm mvp-store || true