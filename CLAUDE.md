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
│   ├── Controller/         # API endpoints
│   ├── Entity/             # Doctrine entities
│   ├── Repository/         # Database repositories
│   ├── Service/            # Business logic (payment processing)
│   └── Kernel.php          # Application kernel
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

### API Endpoints (Example Structure)

```php
// POST /api/payment/process
// Process a new payment
{
  "orderId": "string",
  "amount": "number",
  "currency": "string",
  "paymentMethod": {
    "type": "card|wallet",
    "token": "string"
  }
}

// GET /api/payment/status/{transactionId}
// Check payment status

// POST /api/payment/refund
// Process refund
{
  "transactionId": "string",
  "amount": "number",
  "reason": "string"
}

// GET /api/health
// Health check endpoint
```

## Development Workflow

### Starting Development
```bash
# Option 1: Full system (with API Gateway)
cd ../mvp-store-infrastructure && make init
cd ../mvp-store-payment-service && make up

# Option 2: Local development (standalone)
cd mvp-store-payment-service && make up-local
```

### Adding New Payment Methods

1. **Create Payment Method Entity:**
   ```php
   // src/Entity/PaymentMethod.php
   #[ORM\Entity(repositoryClass: PaymentMethodRepository::class)]
   class PaymentMethod {
       #[ORM\Id]
       #[ORM\GeneratedValue]
       private ?int $id = null;

       #[ORM\Column(length: 50)]
       private ?string $type = null;

       // Additional fields...
   }
   ```

2. **Generate Migration:**
   ```bash
   make exec_bash
   php bin/console doctrine:migrations:diff
   php bin/console doctrine:migrations:migrate
   ```

3. **Create Service:**
   ```php
   // src/Service/PaymentProcessor.php
   class PaymentProcessor {
       public function processPayment(PaymentData $data): PaymentResult {
           // Implementation
       }
   }
   ```

4. **Create Controller:**
   ```php
   // src/Controller/PaymentController.php
   #[Route('/api/payment')]
   class PaymentController extends AbstractController {
       #[Route('/process', methods: ['POST'])]
       public function process(Request $request): JsonResponse {
           // Implementation
       }
   }
   ```

### Testing Payment Flows

```bash
# Run all payment tests
make test

# Inside container - specific test
make exec_bash
php bin/phpunit tests/Service/PaymentProcessorTest.php

# Test with curl
curl -X POST http://localhost:8192/api/payment/process \
  -H "Content-Type: application/json" \
  -d '{"orderId":"123","amount":99.99,"currency":"USD"}'
```

## Security Best Practices

### Sensitive Data Handling
1. **Never Log Payment Details**
   - No credit card numbers in logs
   - No CVV codes in database
   - Mask sensitive data in error messages

2. **Use Tokenization**
   - Store payment tokens, not raw card data
   - Integrate with payment gateway for tokenization
   - Use secure token generation

3. **Encryption**
   - Encrypt sensitive data at rest
   - Use TLS for all communication
   - Secure environment variables

### Payment Gateway Integration

```php
// Example pattern for payment gateway integration
class PaymentGatewayClient {
    public function __construct(
        private HttpClientInterface $client,
        private string $apiKey,
        private string $apiSecret
    ) {}

    public function processPayment(array $paymentData): array {
        // Sanitize and validate input
        $validatedData = $this->validatePaymentData($paymentData);

        // Call external payment gateway
        $response = $this->client->request('POST', 'gateway-url', [
            'json' => $validatedData,
            'auth_bearer' => $this->apiKey,
        ]);

        return $response->toArray();
    }
}
```

## Environment Configuration

### Required Environment Variables

```bash
# Database
DATABASE_URL="postgresql://mvp_user:mvp_secret@localhost:5442/store_payment"

# Payment Gateway (example)
PAYMENT_GATEWAY_URL="https://api.payment-provider.com"
PAYMENT_GATEWAY_API_KEY="your-api-key"
PAYMENT_GATEWAY_SECRET="your-secret"

# Redis (optional, for caching)
REDIS_URL="redis://:mvp_secret@mvp-store-redis:6379"

# App Environment
APP_ENV=dev
APP_SECRET=your-secret-key
```

## Inter-Service Communication

### Called by Backend Service

Backend calls this service for payment operations:

```php
// Backend service code
$response = $httpClient->request('POST',
    'http://mvp-store-payment:8080/api/payment/process',
    [
        'json' => [
            'orderId' => $orderId,
            'amount' => $amount,
            'currency' => 'USD',
        ],
        'timeout' => 15,
    ]
);
```

### Payment Service Response Format

```json
{
  "success": true,
  "transactionId": "txn_123456789",
  "status": "completed",
  "amount": 99.99,
  "currency": "USD",
  "timestamp": "2024-01-15T10:30:00Z",
  "message": "Payment processed successfully"
}
```

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "PAYMENT_DECLINED",
    "message": "Payment was declined by the issuer",
    "transactionId": "txn_123456789"
  }
}
```

## Troubleshooting

### Common Issues

**Container Won't Start:**
```bash
make down && make up    # Restart containers
docker ps -a           # Check container status
docker logs mvp-store-payment  # View logs
```

**Database Connection Issues:**
```bash
# Check PostgreSQL is running
docker ps | grep payment-postgres

# Test connection
docker exec -it mvp-store-payment-postgres-local psql -U mvp_user -d store_payment

# Verify connection from payment service
make exec_bash
php bin/console doctrine:schema:validate
```

**Payment Gateway Connection Failures:**
```bash
# Test from inside container
make exec_bash
curl -v https://payment-gateway-url/health

# Check environment variables
env | grep PAYMENT_GATEWAY
```

**Cache Issues:**
```bash
# Clear Symfony cache
make exec_bash
php bin/console cache:clear

# Clear Redis cache (if used)
docker exec -it mvp-store-redis redis-cli -a mvp_secret FLUSHDB
```

## Testing Strategy

### Unit Tests
```php
// tests/Service/PaymentProcessorTest.php
class PaymentProcessorTest extends TestCase {
    public function testSuccessfulPayment(): void {
        $processor = new PaymentProcessor(/* dependencies */);
        $result = $processor->processPayment($testData);

        $this->assertTrue($result->isSuccessful());
        $this->assertNotNull($result->getTransactionId());
    }

    public function testDeclinedPayment(): void {
        // Test declined payment scenario
    }
}
```

### Integration Tests
```php
// tests/Controller/PaymentControllerTest.php
class PaymentControllerTest extends WebTestCase {
    public function testPaymentEndpoint(): void {
        $client = static::createClient();
        $client->request('POST', '/api/payment/process', [
            'json' => ['orderId' => '123', 'amount' => 99.99]
        ]);

        $this->assertResponseIsSuccessful();
        $this->assertJson($client->getResponse()->getContent());
    }
}
```

## Monitoring & Logging

### Important Metrics to Track
- Payment success rate
- Average processing time
- Failed payment reasons
- Refund request frequency
- API response times

### Logging Best Practices
```php
// Use Symfony Logger
$this->logger->info('Payment processed', [
    'transaction_id' => $transactionId,
    'order_id' => $orderId,
    'amount' => $amount,
    // NEVER log: card numbers, CVV, full card details
]);

$this->logger->error('Payment failed', [
    'transaction_id' => $transactionId,
    'error_code' => $errorCode,
    'masked_card' => '****1234', // Only last 4 digits
]);
```

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