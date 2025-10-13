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
docker exec -it mvp-store-payment php bin/phpunit

# Run specific test file
docker exec -it mvp-store-payment php bin/phpunit tests/SomeTest.php
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
- **Payment Container** (`mvp-store-payment`): Nginx + PHP-FPM on port 8192
- **PostgreSQL** (`mvp-store-payment-postgres-local`): Database on port 5442

### Database Configuration
- **Database**: `store_payment`
- **User**: `mvp_user`
- **Password**: `mvp_secret`
- **Port**: 5442 (external), 5432 (internal)

### API Endpoints
- **Health Check**: `GET /api/health`
- **Base URL**: http://localhost:8192
- **API Prefix**: `/api`

### Inter-Service Communication
- **Docker Network**: `mvp_store_network` (shared with other services)
- **Internal Service Name**: `mvp-store-payment` (accessible at `http://mvp-store-payment:8080`)
- **External Access**: http://localhost:8192
- **Backend calls this service at**: `http://mvp-store-payment:8080`

## Development Workflow

### Local Development Setup
1. Ensure shared network exists: `make network-create`
2. Initialize service: `make init`
3. Access at: http://localhost:8192

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