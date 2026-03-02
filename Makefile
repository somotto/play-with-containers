.PHONY: help build up down restart logs clean test status db-inventory db-billing

# Use sudo if not in docker group
DOCKER_CMD := $(shell groups | grep -q docker && echo "docker" || echo "sudo docker")
COMPOSE_CMD := $(DOCKER_CMD) compose

help:
	@echo "Movie Streaming Platform - Docker Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build        - Build all Docker images"
	@echo "  up           - Start all services"
	@echo "  down         - Stop all services"
	@echo "  restart      - Restart all services"
	@echo "  logs         - View logs from all services"
	@echo "  status       - Show status of all containers"
	@echo "  clean        - Stop and remove all containers, networks, and volumes"
	@echo "  test         - Run basic API tests"
	@echo "  db-inventory - Connect to inventory database"
	@echo "  db-billing   - Connect to billing database"
	@echo ""

build:
	@echo "Building Docker images..."
	$(COMPOSE_CMD) build

up:
	@echo "Starting all services..."
	$(COMPOSE_CMD) up -d --build
	@echo "Waiting for services to be ready..."
	@sleep 5
	@echo ""
	@echo "Services are running!"
	@echo "API Gateway: http://localhost:3000"
	@echo ""
	@make status

down:
	@echo "Stopping all services..."
	$(COMPOSE_CMD) down

restart:
	@echo "Restarting all services..."
	$(COMPOSE_CMD) restart

logs:
	$(COMPOSE_CMD) logs -f

status:
	@echo "Container Status:"
	@$(COMPOSE_CMD) ps

clean:
	@echo "WARNING: This will delete all data in volumes!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	@echo "Cleaning up all containers, networks, and volumes..."
	$(COMPOSE_CMD) down -v
	@echo "Cleanup complete!"

test:
	@echo "Running basic API tests..."
	@echo ""
	@echo "1. Creating a movie..."
	@curl -s -X POST http://localhost:3000/api/movies \
		-H "Content-Type: application/json" \
		-d '{"title": "The Matrix", "description": "A hacker discovers reality is a simulation"}'
	@echo ""
	@echo ""
	@echo "2. Getting all movies..."
	@curl -s http://localhost:3000/api/movies
	@echo ""
	@echo ""
	@echo "3. Sending a billing order..."
	@curl -s -X POST http://localhost:3000/api/billing/ \
		-H "Content-Type: application/json" \
		-d '{"user_id": 1, "number_of_items": 2, "total_amount": 29.99}'
	@echo ""
	@echo ""
	@echo "4. Checking billing database (waiting 2 seconds for async processing)..."
	@sleep 2
	@$(COMPOSE_CMD) exec billing-db psql -U user01 -d billing_db -c "SELECT * FROM orders;"
	@echo ""
	@echo "Tests complete!"

db-inventory:
	@echo "Connecting to inventory database..."
	$(COMPOSE_CMD) exec inventory-db psql -U user01 -d inventory_db

db-billing:
	@echo "Connecting to billing database..."
	$(COMPOSE_CMD) exec billing-db psql -U user01 -d billing_db
