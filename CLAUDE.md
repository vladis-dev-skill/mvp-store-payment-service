# CLAUDE.md - Payment Service

This file provides service-specific guidance to Claude Code when working with the MVP Store Payment Service.

## Project Overview

**MVP Store Payment Service** is a dedicated payment processing microservice built with Symfony 7.3 (PHP 8.2+). It handles all payment-related operations including processing transactions, managing payment methods, and handling refunds.

**Role in Architecture**: Isolated payment processing service that provides secure payment operations for the e-commerce platform.

**Related Services**:
- Backend: `mvp-store-backend/` - Main API that calls this service
- Frontend: `mvp-store-frontend/` - UI that initiates payments
- Infrastructure: `mvp-store-infrastructure/` - API Gateway and shared services

For complete system architecture, see [Root CLAUDE.md](../CLAUDE.md).

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

## Architecture Principles

1. **Microservice Isolation**: Payment logic is completely separated from main backend
2. **Database Per Service**: Dedicated PostgreSQL instance for payment data
3. **API-First Design**: RESTful API with JSON responses
4. **Container-Based**: All services run in isolated Docker containers
5. **Shared Network**: Uses Docker networking for inter-service communication

## Key Directories

```
mvp-store-payment-service/
├── config/                    # Symfony configuration
│   ├── packages/             # Package-specific configs
│   ├── routes/               # Route definitions
│   └── services.yaml         # Service container config
├── docker/                   # Docker infrastructure
│   ├── docker-compose.yml   # Container orchestration
│   ├── Dockerfile           # Multi-stage build
│   ├── nginx/               # Web server config
│   ├── php-fpm/             # PHP-FPM config
│   └── supervisor/          # Process management
├── migrations/              # Database migrations
├── public/                  # Web root (index.php)
├── src/
├── tests/                  # PHPUnit tests
├── var/                    # Cache, logs (gitignored)
├── Makefile               # Development commands
└── composer.json          # PHP dependencies
```

## Payment Service Responsibilities

### Core Functionality
1. **Payment Processing**
   - Credit/debit card processing
   - Digital wallet integration
   - Payment method validation
   - Transaction authorization

2. **Transaction Management**
   - Transaction recording
   - Payment status tracking
   - Transaction history
   - Receipt generation

3. **Refund Handling**
   - Refund processing
   - Partial refunds
   - Refund status tracking

4. **Security**
   - PCI compliance considerations
   - Payment data encryption
   - Tokenization
   - Fraud detection hooks

## Claude Code Guidelines

When working on this service:
1. **Security First** - Never log sensitive payment data
2. **Validate Everything** - Strict input validation for all payment data
3. **Use Transactions** - Database transactions for payment operations
4. **Error Handling** - Comprehensive error handling with meaningful messages
5. **Testing** - Test all payment scenarios including edge cases
6. **Documentation** - Document all payment flows and integrations
7. **Idempotency** - Implement idempotency for payment operations
8. **Audit Trail** - Log all payment operations for audit purposes
9. **PCI Compliance** - Follow PCI DSS guidelines
10. **Timeout Handling** - Handle gateway timeouts gracefully