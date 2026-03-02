.PHONY: help build up down restart logs clean test status

help:
	@echo "Movie Streaming Platform - Docker Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build      - Build all Docker images"
	@echo "  up         - Start all services"
	@echo "  down       - Stop all services"
	@echo "  restart    - Restart all services"
	@echo "  logs       - View logs from all services"
	@echo "  status     - Show status of all containers"
	@echo "  clean      - Stop and remove all containers, networks, and volumes"
	@echo "  test       - Run basic API tests"
	@echo ""

build:
	@echo "Building Docker images..."
	docker compose build

up:
	@echo "Starting all services..."
	docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 5
	@echo ""
	@echo "Services are running!"
	@echo "API Gateway: http://localhost:3000"
	@echo "RabbitMQ Management: http://localhost:15672 (user: rabbit, pass: password)"
	@echo ""
	@make status

down:
	@echo "Stopping all services..."
	docker compose down

restart:
	@echo "Restarting all services..."
	docker compose restart

logs:
	docker compose logs -f

status:
	@echo "Container Status:"
	@docker compose ps

clean:
	@echo "Cleaning up all containers, networks, and volumes..."
	docker compose down -v
	@echo "Cleanup complete!"

test:
	@echo "Running basic API tests..."
	@echo ""
	@echo "1. Creating a movie..."
	@curl -s -X POST http://localhost:3000/api/movies \
		-H "Content-Type: application/json" \
		-d '{"title": "The Matrix", "description": "A hacker discovers reality is a simulation"}' | jq .
	@echo ""
	@echo "2. Getting all movies..."
	@curl -s http://localhost:3000/api/movies | jq .
	@echo ""
	@echo "3. Sending a billing order..."
	@curl -s -X POST http://localhost:3000/api/billing/ \
		-H "Content-Type: application/json" \
		-d '{"user_id": "1", "number_of_items": "2", "total_amount": "50"}' | jq .
	@echo ""
	@echo "Tests complete!"
