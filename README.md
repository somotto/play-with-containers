# Movie Streaming Platform - Microservices Architecture

## Project Overview

This project implements a multi-container microservices architecture using Docker and Docker Compose. It demonstrates containerization concepts, service isolation, inter-service communication, and persistent data management.

## Architecture

The system consists of six Docker containers:

- **api-gateway-app**: Entry point for all external requests (Port 3000)
- **inventory-app**: RESTful CRUD API for movie catalog (Port 8080)
- **billing-app**: Asynchronous payment processing consumer (Port 8080)
- **inventory-db**: PostgreSQL database for inventory service (Port 5432)
- **billing-db**: PostgreSQL database for billing service (Port 5432)
- **rabbit-queue**: RabbitMQ message broker for async communication

### Technology Stack

- **Backend**: Python 3.12 (Alpine Linux)
- **Framework**: Flask, SQLAlchemy
- **Databases**: PostgreSQL 14 (Alpine)
- **Message Queue**: RabbitMQ 3 (Alpine)
- **Containerization**: Docker & Docker Compose
- **Web Server**: Waitress

### Service Communication Flow

```
External Client → api-gateway-app (Port 3000) → inventory-app → inventory-db
                         ↓
                   rabbit-queue → billing-app → billing-db
```

All services communicate through a single Docker network (`app-network`). Only the API Gateway is exposed externally.

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Linux**: Ubuntu 20.04+ or similar distribution
- **Git**: For cloning the repository

### Installing Docker on Linux

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
docker --version
docker compose version

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Optional: Add your user to docker group (requires logout/login)
sudo usermod -aG docker $USER
```

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd crud-master
```

### 2. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your preferred credentials (optional)
nano .env
```

### 3. Build and Start Services

```bash
# Build images and start all containers
sudo docker compose up --build -d

# Or without sudo if you're in the docker group
docker compose up --build -d
```

### 4. Verify Deployment

```bash
# Check all containers are running
sudo docker compose ps

# View logs
sudo docker compose logs -f
```

### 5. Test the API

**Using curl:**
```bash
curl http://localhost:3000/api/movies
```

**Using Postman:**
- Import `postman_collection.json` into Postman
- See `POSTMAN_GUIDE.md` for detailed instructions

**Using Make:**
```bash
make test
```

## Documentation Files

- **README.md** - Complete project documentation (this file)
- **POSTMAN_GUIDE.md** - Detailed Postman testing guide
- **API_QUICK_REFERENCE.md** - Quick reference for all API endpoints
- **postman_collection.json** - Ready-to-import Postman collection
- **.env.example** - Example environment configuration

## Configuration

### Environment Variables

The project uses environment variables for configuration. Copy the example file and customize as needed:

```bash
cp .env.example .env
```

Default configuration (`.env`):

```bash
# PostgreSQL Configuration
POSTGRES_PASSWORD=yourpassword

# Inventory Database
INVENTORY_DB_USER=user01
INVENTORY_DB_PASSWORD=password
INVENTORY_DB_NAME=inventory_db

# Billing Database
BILLING_DB_USER=user01
BILLING_DB_PASSWORD=password
BILLING_DB_NAME=billing_db

# RabbitMQ Configuration
RABBITMQ_USER=rabbit
RABBITMQ_PASSWORD=password
RABBITMQ_QUEUE=billing_queue
RABBITMQ_PORT=5672

# Service Ports
INVENTORY_APP_PORT=8080
APIGATEWAY_PORT=3000
BILLING_APP_PORT=8080
```

**Important**: The `.env` file is ignored by Git for security. Never commit credentials to version control.

## Setup and Installation

### 1. Clone the Repository

### 2. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your preferred credentials (optional)
nano .env
```

### 3. Build and Start Services

```bash
# Build images and start all containers
sudo docker compose up --build -d

# Or without sudo if you're in the docker group
docker compose up --build -d
```

This command will:
- Build Docker images for all three application services
- Pull PostgreSQL and RabbitMQ images
- Create Docker networks and volumes
- Start all containers in the correct order
- Wait for health checks to pass

### 4. Verify Deployment

```bash
# Check all containers are running
sudo docker compose ps

# Expected output: All services should show "Up" status
# NAME                IMAGE                COMMAND                  SERVICE           STATUS
# api-gateway-app     api-gateway-app      "python server.py"       api-gateway-app   Up
# billing-app         billing-app          "python server.py"       billing-app       Up
# inventory-app       inventory-app        "python server.py"       inventory-app     Up
# billing-db          postgres:14-alpine   "docker-entrypoint.s…"   billing-db        Up (healthy)
# inventory-db        postgres:14-alpine   "docker-entrypoint.s…"   inventory-db      Up (healthy)
# rabbit-queue        rabbitmq:3-...       "docker-entrypoint.s…"   rabbit-queue      Up (healthy)
```

### 5. View Logs

```bash
# View all service logs
sudo docker compose logs -f

# View specific service logs
sudo docker compose logs -f api-gateway-app
sudo docker compose logs -f inventory-app
sudo docker compose logs -f billing-app
```

## Usage

### API Endpoints

All external requests must go through the API Gateway at `http://localhost:3000`. Direct access to other services is not exposed.

#### Inventory API

**Get all movies**
```bash
curl http://localhost:3000/api/movies
```

**Get movies by title (filter)**
```bash
curl "http://localhost:3000/api/movies?title=Matrix"
```

**Get single movie by ID**
```bash
curl http://localhost:3000/api/movies/1
```

**Create a new movie**
```bash
curl -X POST http://localhost:3000/api/movies \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Matrix",
    "description": "A computer hacker learns about the true nature of reality"
  }'
```

**Update a movie**
```bash
curl -X PUT http://localhost:3000/api/movies/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Matrix Reloaded",
    "description": "Updated description"
  }'
```

**Delete a specific movie**
```bash
curl -X DELETE http://localhost:3000/api/movies/1
```

**Delete all movies**
```bash
curl -X DELETE http://localhost:3000/api/movies
```

#### Billing API

**Create an order (async via RabbitMQ)**
```bash
curl -X POST http://localhost:3000/api/billing/ \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "number_of_items": 2,
    "total_amount": 29.99
  }'
```

The billing request is queued in RabbitMQ and processed asynchronously by the billing-app service.

## Testing

### Testing with Postman

Postman is a popular API testing tool with a graphical interface. Here's how to test the API using Postman:

#### Option 1: Import the Postman Collection

1. **Download and Install Postman**
   - Visit [postman.com/downloads](https://www.postman.com/downloads/)
   - Install Postman for your operating system

2. **Import the Collection**
   - Open Postman
   - Click "Import" button (top left)
   - Select the `postman_collection.json` file from the project root
   - The collection will appear in your Collections sidebar

3. **Run Requests**
   - Expand "Movie Streaming Platform API" collection
   - Click on any request to open it
   - Click "Send" button to execute the request
   - View the response in the bottom panel

#### Option 2: Manual Setup in Postman

**1. Create a New Collection**
- Click "New" → "Collection"
- Name it "Movie Streaming Platform"

**2. Add Inventory Requests**

**GET All Movies**
```
Method: GET
URL: http://localhost:3000/api/movies
```

**GET Movie by ID**
```
Method: GET
URL: http://localhost:3000/api/movies/1
```

**GET Movies by Title (Filter)**
```
Method: GET
URL: http://localhost:3000/api/movies?title=Matrix
```

**POST Create Movie**
```
Method: POST
URL: http://localhost:3000/api/movies
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "title": "The Matrix",
  "description": "A computer hacker learns about the true nature of reality"
}
```

**PUT Update Movie**
```
Method: PUT
URL: http://localhost:3000/api/movies/1
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "title": "The Matrix Reloaded",
  "description": "Updated description"
}
```

**DELETE Movie by ID**
```
Method: DELETE
URL: http://localhost:3000/api/movies/1
```

**DELETE All Movies**
```
Method: DELETE
URL: http://localhost:3000/api/movies
```

**3. Add Billing Requests**

**POST Create Order**
```
Method: POST
URL: http://localhost:3000/api/billing/
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "user_id": 1,
  "number_of_items": 2,
  "total_amount": 29.99
}
```

#### Postman Testing Workflow

1. **Start with GET All Movies** - Should return empty array initially
2. **Create 2-3 Movies** - Use POST requests with different movie data
3. **GET All Movies Again** - Verify movies were created
4. **Filter Movies** - Test the title query parameter
5. **Update a Movie** - Change title or description
6. **Create Billing Orders** - Send several orders
7. **Verify in Database** - Use terminal to check orders table

#### Postman Tips

- **Save Responses**: Click "Save Response" to keep examples
- **Use Variables**: Create environment variables for `base_url`
- **Tests Tab**: Add JavaScript tests to validate responses
- **Collection Runner**: Run all requests sequentially
- **Pre-request Scripts**: Generate dynamic data

#### Example Postman Test Scripts

Add these in the "Tests" tab of your requests:

**For GET All Movies:**
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has movies array", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('movies');
    pm.expect(jsonData.movies).to.be.an('array');
});
```

**For POST Create Movie:**
```javascript
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("Movie created successfully", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.message).to.include("inserted successfully");
});
```

**For POST Billing Order:**
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Order sent to queue", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.message).to.include("sent");
});
```

### Complete Workflow Test (Command Line)

```bash
# 1. Create movies in inventory
curl -X POST http://localhost:3000/api/movies \
  -H "Content-Type: application/json" \
  -d '{"title": "The Matrix", "description": "A hacker discovers reality is a simulation"}'

curl -X POST http://localhost:3000/api/movies \
  -H "Content-Type: application/json" \
  -d '{"title": "Inception", "description": "Dream heist thriller"}'

# 2. List all movies
curl http://localhost:3000/api/movies

# 3. Search by title
curl "http://localhost:3000/api/movies?title=Matrix"

# 4. Create billing orders
curl -X POST http://localhost:3000/api/billing/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "number_of_items": 2, "total_amount": 29.99}'

curl -X POST http://localhost:3000/api/billing/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2, "number_of_items": 1, "total_amount": 14.99}'

# 5. Verify orders in database (wait 2 seconds for async processing)
sleep 2
sudo docker compose exec billing-db psql -U user01 -d billing_db -c "SELECT * FROM orders;"
```

### Test Message Queue Resilience

This test demonstrates that RabbitMQ queues messages even when the billing service is down:

```bash
# 1. Stop billing service
sudo docker compose stop billing-app

# 2. Send billing requests (they'll queue in RabbitMQ)
curl -X POST http://localhost:3000/api/billing/ \
  -H "Content-Type: application/json" \
  -d '{"user_id": 5, "number_of_items": 10, "total_amount": 199.99}'

# 3. Restart billing service
sudo docker compose start billing-app

# 4. Check that queued orders were processed
sleep 3
sudo docker compose exec billing-db psql -U user01 -d billing_db -c "SELECT * FROM orders;"
```

### Test Container Auto-Restart

Containers are configured with `restart: always` policy:

```bash
# Stop a container
sudo docker stop inventory-app

# Wait a few seconds and check - it should restart automatically
sleep 5
sudo docker compose ps
```

## Docker Resources

### Containers

| Container Name | Image | Purpose | Exposed Ports |
|---------------|-------|---------|---------------|
| api-gateway-app | api-gateway-app | API Gateway | 3000 (external) |
| inventory-app | inventory-app | Movie catalog service | 8080 (internal) |
| billing-app | billing-app | Payment processing | 8080 (internal) |
| inventory-db | postgres:14-alpine | Inventory database | 5432 (internal) |
| billing-db | postgres:14-alpine | Billing database | 5432 (internal) |
| rabbit-queue | rabbitmq:3-management-alpine | Message broker | 5672 (internal) |

### Volumes

| Volume Name | Purpose | Mounted To |
|------------|---------|------------|
| inventory-db | Persistent storage for inventory database | /var/lib/postgresql/data |
| billing-db | Persistent storage for billing database | /var/lib/postgresql/data |
| api-gateway-app | API Gateway logs | /var/log/api-gateway |

### Networks

| Network Name | Driver | Purpose |
|-------------|--------|---------|
| app-network | bridge | Internal communication between all services |

Only the API Gateway (port 3000) is accessible from outside the Docker network, ensuring security and proper service isolation.

## Database Access

### Inventory Database

```bash
# Connect to inventory database
sudo docker compose exec inventory-db psql -U user01 -d inventory_db

# Query movies table
sudo docker compose exec inventory-db psql -U user01 -d inventory_db -c "SELECT * FROM movies;"

# Describe movies table structure
sudo docker compose exec inventory-db psql -U user01 -d inventory_db -c "\d movies"
```

### Billing Database

```bash
# Connect to billing database
sudo docker compose exec billing-db psql -U user01 -d billing_db

# Query orders table
sudo docker compose exec billing-db psql -U user01 -d billing_db -c "SELECT * FROM orders;"

# Describe orders table structure
sudo docker compose exec billing-db psql -U user01 -d billing_db -c "\d orders"
```

## Docker Management Commands

### Start Services
```bash
sudo docker compose up -d              # Start in background
sudo docker compose up --build         # Rebuild and start
sudo docker compose up -d --build      # Rebuild and start in background
```

### Stop Services
```bash
sudo docker compose stop               # Stop services (keeps containers)
sudo docker compose down               # Stop and remove containers
sudo docker compose down -v            # Stop, remove containers and volumes (deletes data!)
```

### View Logs
```bash
sudo docker compose logs -f                      # All services (follow mode)
sudo docker compose logs -f api-gateway-app      # Specific service
sudo docker compose logs --tail=100 billing-app  # Last 100 lines
sudo docker compose logs --since=10m             # Last 10 minutes
```

### Restart Services
```bash
sudo docker compose restart                # Restart all services
sudo docker compose restart billing-app    # Restart specific service
```

### Check Status
```bash
sudo docker compose ps                     # List containers and status
sudo docker compose ps -a                  # Include stopped containers
sudo docker compose top                    # Display running processes
```

### Execute Commands in Containers
```bash
sudo docker compose exec api-gateway-app sh       # Open shell in container
sudo docker compose exec inventory-app python     # Run Python interpreter
sudo docker compose exec billing-app ps aux       # List processes
```

### View Resource Usage
```bash
sudo docker stats                          # Real-time resource usage
sudo docker compose images                 # List images used by services
sudo docker system df                      # Disk usage
```

### Clean Up
```bash
sudo docker compose down -v                # Remove everything including volumes
sudo docker system prune -a                # Remove unused containers, networks, images
sudo docker volume prune                   # Remove unused volumes
```

## Project Structure

```
crud-master/
├── .env                          # Environment variables (not in Git)
├── .env.example                  # Example environment configuration
├── .gitignore                    # Git ignore rules
├── .dockerignore                 # Docker ignore rules
├── docker-compose.yml            # Multi-container orchestration
├── Makefile                      # Convenience commands
├── README.md                     # Project documentation
├── Vagrantfile                   # Legacy VM configuration
├── config.yaml                   # Application configuration
├── scripts/                      # Setup and utility scripts
│   ├── postgresql-setup.sh
│   ├── rabbitmq-setup.sh
│   ├── py-setup.sh
│   ├── run-py-server.sh
│   └── setup.sh
└── srcs/                         # Source code for all services
    ├── api-gateway-app/
    │   ├── Dockerfile            # API Gateway container definition
    │   ├── requirements.txt      # Python dependencies
    │   ├── server.py             # Application entry point
    │   └── app/
    │       ├── __init__.py       # Flask app initialization
    │       ├── proxy.py          # Request routing logic
    │       └── queue_sender.py   # RabbitMQ publisher
    ├── inventory-app/
    │   ├── Dockerfile            # Inventory service container
    │   ├── requirements.txt      # Python dependencies
    │   ├── server.py             # Application entry point
    │   └── app/
    │       ├── __init__.py       # Flask app initialization
    │       ├── extensions.py     # Database extensions
    │       └── movies.py         # Movie CRUD endpoints
    └── billing-app/
        ├── Dockerfile            # Billing service container
        ├── requirements.txt      # Python dependencies
        ├── server.py             # Application entry point
        └── app/
            ├── consume_queue.py  # RabbitMQ consumer
            └── orders.py         # Order model and database logic
```

## Design Decisions and Best Practices

### Containerization Strategy

**Alpine Linux Base Images**: All services use Alpine-based images (Python 3.12-alpine, PostgreSQL 14-alpine, RabbitMQ 3-alpine) for:
- Minimal attack surface (security)
- Smaller image sizes (faster builds and deployments)
- Reduced resource consumption

**Custom Dockerfiles**: Each application service has its own Dockerfile following best practices:
- Multi-stage builds not needed for Python apps
- Minimal layers for optimal caching
- No unnecessary packages installed
- Non-root user execution (implicit in Python Alpine)

**Image Naming**: Docker images match service names (inventory-app, billing-app, api-gateway-app) for clarity and consistency.

### Network Architecture

**Single Network Design**: All services communicate through one Docker bridge network (`app-network`):
- Simplifies service discovery
- Reduces network complexity
- Maintains security through port exposure control

**External Access Control**: Only the API Gateway exposes port 3000 externally:
- Single entry point for all client requests
- Internal services (inventory-app, billing-app, databases) are isolated
- Follows API Gateway pattern for microservices

### Data Persistence

**Named Volumes**: Three Docker volumes ensure data persistence:
- `inventory-db`: Inventory database data survives container restarts
- `billing-db`: Billing database data survives container restarts
- `api-gateway-app`: API Gateway logs for debugging and monitoring

**Database Per Service**: Each microservice has its own database:
- Independent scaling and optimization
- Fault isolation (one service failure doesn't affect others)
- Technology flexibility (can use different DB versions/types)
- Follows microservices best practices

### Reliability and Resilience

**Automatic Restart**: All containers use `restart: always` policy:
- Automatic recovery from crashes
- Survives host reboots
- Ensures high availability

**Health Checks**: Database and message queue services have health checks:
- Application services wait for dependencies to be ready
- Prevents connection errors during startup
- Ensures proper initialization order

**Asynchronous Billing**: RabbitMQ message queue provides:
- Resilience: Orders aren't lost if billing service is down
- Decoupling: API Gateway doesn't wait for billing completion
- Scalability: Multiple billing workers can process the queue
- Reliability: Messages persist until successfully processed

### Security

**Environment Variables**: Sensitive data (passwords, credentials) stored in `.env`:
- Not committed to version control (.gitignore)
- Easy to change per environment
- Follows 12-factor app methodology

**Network Isolation**: Services only expose necessary ports:
- Databases accessible only within Docker network
- RabbitMQ management UI not exposed externally
- Reduces attack surface

### Why Docker Instead of Vagrant/VirtualBox?

- **Performance**: Containers start in seconds vs minutes for VMs
- **Resource Efficiency**: Lower CPU and memory overhead
- **Portability**: Consistent behavior across all platforms
- **Modern Standard**: Industry-standard for microservices
- **No Kernel Issues**: Avoids Secure Boot and kernel module problems
- **Easier CI/CD**: Better integration with deployment pipelines

## Troubleshooting

### Services Won't Start

```bash
# Check logs for errors
sudo docker compose logs

# Rebuild from scratch
sudo docker compose down -v
sudo docker compose up --build

# Check Docker daemon status
sudo systemctl status docker
```

### Database Connection Errors

```bash
# Wait for databases to be ready (healthchecks handle this automatically)
sudo docker compose ps

# Check database logs
sudo docker compose logs inventory-db
sudo docker compose logs billing-db

# Verify database is accessible
sudo docker compose exec inventory-db psql -U user01 -d inventory_db -c "SELECT 1;"
```

### RabbitMQ Connection Errors

```bash
# Check RabbitMQ status
sudo docker compose logs rabbit-queue

# Restart RabbitMQ
sudo docker compose restart rabbit-queue

# Verify RabbitMQ is healthy
sudo docker compose ps rabbit-queue
```

### Port Already in Use

```bash
# Check what's using port 3000
sudo lsof -i :3000
sudo netstat -tulpn | grep 3000

# Change port in .env file
nano .env
# Change: APIGATEWAY_PORT=3001

# Restart services
sudo docker compose down
sudo docker compose up -d
```

### Permission Denied Errors

```bash
# If you get "permission denied" errors, use sudo
sudo docker compose up -d

# Or add your user to docker group (requires logout/login)
sudo usermod -aG docker $USER
newgrp docker  # Or logout and login again
```

### Container Keeps Restarting

```bash
# Check container logs for errors
sudo docker compose logs -f <service-name>

# Check container exit code
sudo docker compose ps -a

# Inspect container
sudo docker inspect <container-name>
```

### Out of Disk Space

```bash
# Check Docker disk usage
sudo docker system df

# Clean up unused resources
sudo docker system prune -a
sudo docker volume prune

# Remove specific volumes (WARNING: deletes data!)
sudo docker volume rm crud-master_inventory-db
```

### Environment Variables Not Loading

```bash
# Verify .env file exists
ls -la .env

# Check .env file content
cat .env

# Restart services to reload environment
sudo docker compose down
sudo docker compose up -d
```

## Learning Objectives Achieved

This project demonstrates:

✅ **Multi-container microservices architecture** using Docker and Docker Compose
✅ **Isolated services** with PostgreSQL databases, RabbitMQ messaging, and API Gateway
✅ **Docker networks** for inter-service communication with security isolation
✅ **Docker volumes** for persistent data storage
✅ **Optimized Dockerfiles** using Alpine Linux for minimal image sizes
✅ **Container orchestration** with proper dependency management and health checks
✅ **Automatic restart policies** for high availability
✅ **Environment-based configuration** following 12-factor app principles
✅ **Comprehensive documentation** covering setup, usage, and troubleshooting

## Key Concepts Demonstrated

- **Containers**: Lightweight, isolated units packaging code and dependencies
- **Docker**: Platform for building, shipping, and running containerized applications
- **Dockerfile**: Instructions for building custom Docker images
- **Docker Images**: Read-only templates for creating containers
- **Docker Networks**: Enable communication between containers
- **Docker Volumes**: Persistent storage for container data
- **Docker Compose**: Tool for defining and running multi-container applications
- **Microservices**: Architectural pattern with independent, loosely-coupled services
- **API Gateway**: Single entry point routing requests to backend services
- **Message Queue**: Asynchronous communication pattern for decoupled services

## Development

### Local Development Without Docker

Each service can run locally with Python virtual environments:

```bash
# Example: Inventory Service
cd srcs/inventory-app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set environment variables
export APP_PORT=8080
export INVENTORY_DB_HOST=localhost
export INVENTORY_DB_USER=user01
export INVENTORY_DB_PASSWORD=password
export INVENTORY_DB_NAME=inventory_db

# Run server
python server.py
```

Note: You'll need to install and configure PostgreSQL and RabbitMQ locally.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is for educational purposes as part of a containerization learning module.

## Acknowledgments

- Based on the crud-master project architecture
- Built with Docker and Docker Compose best practices
- Demonstrates microservices patterns and containerization concepts
