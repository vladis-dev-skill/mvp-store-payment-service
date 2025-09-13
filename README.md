# MVP Store Payment Service

Payment microservice for the MVP Store architecture built with Symfony 7.3.

## Quick Setup

```bash
# Create shared network for microservices (if not exists)
make network-create

# Initialize and start payment service
make init

# Access payment service at http://localhost:8182
```

## Commands

```bash
make up          # Start containers
make down        # Stop containers  
make exec_bash   # Access PHP container
make test        # Run tests
```

## Services

- **Payment API**: http://localhost:8182
- **Database**: localhost:5433 (PostgreSQL)

## Database Config

- Database: `store_payment`
- User: `payment_user` 
- Password: `secret`

## Microservice Communication

- **Network**: Uses shared `mvp-store` Docker network
- **Service Name**: `store_payment_nginx` for inter-service communication
- **Port**: Internal communication via network, external via 8182