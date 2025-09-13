# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **MVP Store Payment Service** - a dedicated payment processing microservice built with Symfony 7.3 and PHP 8.2+. It's part of a larger microservices architecture that includes:

- `mvp-store-backend/` - Main backend API
- `mvp-store-payment-service/` - This payment processing service

## Development Commands

### Container Management
```bash
make init                   # Initialize service (first run)
make up                     # Start all containers
make down                   # Stop containers
make exec_bash              # Access PHP container shell
make test                   # Run PHPUnit tests
make fixer                  # Run PHP CS Fixer for code formatting
```

### Network Setup
```bash
make network-create         # Create shared Docker network (if not exists)
make network-remove         # Remove shared Docker network
```

### Testing
```bash
# Run all tests
make test

# Run tests inside container manually
docker exec -it store_payment_php-fpm php bin/phpunit

# Run specific test file
docker exec -it store_payment_php-fpm php bin/phpunit tests/SomeTest.php
```

### Database Operations (inside container)
```bash
# Access container
make exec_bash

# Then run Symfony/Doctrine commands:
php bin/console doctrine:migrations:diff       # Generate migration from entity changes
php bin/console doctrine:migrations:migrate    # Apply pending migrations
php bin/console doctrine:schema:validate       # Validate schema consistency
```

## Service Architecture

### Container Structure
- **Nginx** (`store_payment_nginx`): Web server on port 8182
- **PHP-FPM** (`store_payment_php-fpm`): PHP application server
- **PostgreSQL** (`store_payment_database`): Database on port 5433

### Database Configuration
- **Database**: `store_payment`
- **User**: `payment_user`
- **Password**: `secret`
- **Port**: 5433 (external), 5432 (internal)

### API Endpoints
- **Health Check**: `GET /api/health`
- **Base URL**: http://localhost:8182
- **API Prefix**: `/api`

### Inter-Service Communication
- **Docker Network**: `mvp-store` (shared with other services)
- **Internal Service Name**: `store_payment_nginx`
- **External Access**: http://localhost:8182

## Development Workflow

### Local Development Setup
1. Ensure shared network exists: `make network-create`
2. Initialize service: `make init`
3. Access at: http://localhost:8182

### Adding New Features
1. Create controller in `src/Controller/`
2. Add routes using PHP attributes (`#[Route]`)
3. Generate migrations if entities change: `php bin/console doctrine:migrations:diff`
4. Run tests: `make test`
5. Format code: `make fixer`

### Database Migrations
- All migrations are stored in `migrations/` directory
- Always generate migrations with Doctrine: `doctrine:migrations:diff`
- Never manually edit generated migrations unless absolutely necessary
- Apply migrations during deployment: `doctrine:migrations:migrate`

## Code Quality

### PHP CS Fixer
```bash
make fixer                  # Fix code style issues
```

The service uses PHP CS Fixer for consistent code formatting. Configuration is managed through the Makefile commands that set up the tool in `tools/php-cs-fixer/`.

## Architecture Principles

1. **Microservice Isolation**: Payment logic is completely separated from main backend
2. **Database Per Service**: Dedicated PostgreSQL instance for payment data
3. **API-First Design**: RESTful API with JSON responses
4. **Container-Based**: All services run in isolated Docker containers
5. **Shared Network**: Uses Docker networking for inter-service communication