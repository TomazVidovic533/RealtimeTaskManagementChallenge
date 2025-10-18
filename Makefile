.PHONY: help build rebuild start stop down logs ps clean

CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
RESET := \033[0m

help:
	@echo "$(CYAN)=== Real-Time Task Management Challenge ===$(RESET)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(RESET)"
	@echo "  make build     - Build Docker images"
	@echo "  make rebuild   - Clean rebuild (no cache)"
	@echo "  make start     - Start all services"
	@echo "  make stop      - Stop all services"
	@echo "  make down      - Stop and remove containers"
	@echo "  make logs      - View service logs"
	@echo "  make ps        - List running containers"
	@echo "  make clean     - Remove containers and volumes"
	@echo ""
	@echo "$(YELLOW)Service Access:$(RESET)"
	@echo "  $(BLUE)API:            http://localhost:8080$(RESET)"
	@echo "  $(BLUE)API (HTTPS):    https://localhost:8081$(RESET)"
	@echo "  $(BLUE)PostgreSQL:     localhost:5432$(RESET)"
	@echo "  $(BLUE)Redis:          localhost:6379$(RESET)"
	@echo "  $(BLUE)Kafka:          localhost:9092$(RESET)"
	@echo "  $(BLUE)RabbitMQ:       localhost:5672$(RESET)"
	@echo "  $(BLUE)RabbitMQ UI:    http://localhost:15672$(RESET) (admin/password123)"

build:
	@echo "$(YELLOW)Building Docker images...$(RESET)"
	docker-compose build
	@echo "$(GREEN)Build complete!$(RESET)"

rebuild:
	@echo "$(YELLOW)Rebuilding from scratch...$(RESET)"
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "$(GREEN)Rebuild complete!$(RESET)"
	@echo "$(BLUE)API running at http://localhost:8080$(RESET)"
	@echo "$(BLUE)RabbitMQ UI at http://localhost:15672$(RESET)"

start:
	@echo "$(YELLOW)Starting all services...$(RESET)"
	docker-compose up -d
	@echo "$(YELLOW)Waiting for services to be healthy...$(RESET)"
	@sleep 5
	@echo "$(GREEN)All services started!$(RESET)"
	@echo ""
	@echo "$(CYAN)Access points:$(RESET)"
	@echo "  $(BLUE)API:         http://localhost:8080$(RESET)"
	@echo "  $(BLUE)Swagger:     http://localhost:8080/swagger$(RESET)"
	@echo "  $(BLUE)RabbitMQ:    http://localhost:15672$(RESET)"
	@echo "  $(BLUE)PostgreSQL:  localhost:5432$(RESET)"

stop:
	@echo "$(YELLOW)Stopping all services...$(RESET)"
	docker-compose stop
	@echo "$(GREEN)All services stopped!$(RESET)"

down:
	@echo "$(YELLOW)Stopping and removing containers...$(RESET)"
	docker-compose down
	@echo "$(GREEN)Containers removed!$(RESET)"

logs:
	@echo "$(YELLOW)Following service logs (Ctrl+C to exit)...$(RESET)"
	docker-compose logs -f

ps:
	@echo "$(CYAN)Container status:$(RESET)"
	@docker-compose ps

clean:
	@echo "$(YELLOW)Cleaning up containers and volumes...$(RESET)"
	docker-compose down -v
	@echo "$(GREEN)Cleanup complete!$(RESET)"
