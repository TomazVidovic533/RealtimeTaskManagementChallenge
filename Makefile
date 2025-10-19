.PHONY: help status backend-build backend-run backend-test frontend-install frontend-dev frontend-build docker-build docker-start docker-stop docker-logs docker-clean k3d-build k3d-start k3d-stop k3d-logs k3d-clean

# Colors
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

DOCKER_COMPOSE := docker-compose -f infrastructure/docker/docker-compose.yml --env-file .env

help:
	@echo "$(CYAN)=== Real-Time Task Management ===$(RESET)"
	@echo ""
	@echo "$(YELLOW)Development (Local):$(RESET)"
	@echo "  make backend-build    - Build backend"
	@echo "  make backend-run      - Run backend API locally"
	@echo "  make backend-test     - Run tests"
	@echo "  make frontend-install - Install frontend dependencies"
	@echo "  make frontend-dev     - Run frontend dev server"
	@echo ""
	@echo "$(YELLOW)Docker:$(RESET)"
	@echo "  make docker-build     - Build all Docker images (backend + frontend)"
	@echo "  make docker-start     - Start all services with Docker Compose"
	@echo "  make docker-stop      - Stop Docker services"
	@echo "  make docker-logs      - View Docker logs"
	@echo "  make docker-clean     - Remove all containers and volumes"
	@echo ""
	@echo "$(YELLOW)Kubernetes (k3d):$(RESET)"
	@echo "  make k3d-build        - Build and push images to k3d cluster"
	@echo "  make k3d-start        - Create cluster and deploy all services"
	@echo "  make k3d-stop         - Stop and remove k3d cluster"
	@echo "  make k3d-logs         - View API logs in k3d"
	@echo "  make k3d-clean        - Full k3d cleanup"
	@echo ""
	@echo "$(YELLOW)Other:$(RESET)"
	@echo "  make status           - Check service status"

# Backend commands
backend-build:
	@echo "$(YELLOW)Building backend...$(RESET)"
	@cd backend && dotnet build
	@echo "$(GREEN)Backend built successfully!$(RESET)"

backend-run:
	@echo "$(YELLOW)Running backend API...$(RESET)"
	@cd backend && dotnet run --project src/TaskManagement.API

backend-test:
	@echo "$(YELLOW)Running backend tests...$(RESET)"
	@cd backend && dotnet test

# Frontend commands
frontend-install:
	@echo "$(YELLOW)Installing frontend dependencies...$(RESET)"
	@cd frontend && npm install
	@echo "$(GREEN)Frontend dependencies installed!$(RESET)"

frontend-dev:
	@echo "$(YELLOW)Starting frontend dev server...$(RESET)"
	@cd frontend && npm run dev

frontend-build:
	@echo "$(YELLOW)Building frontend for production...$(RESET)"
	@cd frontend && npm run build
	@echo "$(GREEN)Frontend built successfully!$(RESET)"

# Docker commands
docker-build:
	@echo "$(YELLOW)Building Docker images...$(RESET)"
	@$(DOCKER_COMPOSE) build
	@echo "$(GREEN)Docker images built successfully!$(RESET)"

docker-start:
	@echo "$(YELLOW)Starting all services with Docker Compose...$(RESET)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(YELLOW)Waiting for services to be healthy...$(RESET)"
	@sleep 5
	@echo "$(GREEN)All services started!$(RESET)"
	@echo ""
	@echo "$(CYAN)Access points:$(RESET)"
	@echo "  $(YELLOW)Frontend:$(RESET)       http://localhost:3001"
	@echo "  $(YELLOW)API:$(RESET)            http://localhost:8080"
	@echo "  $(YELLOW)Swagger:$(RESET)        http://localhost:8080/swagger"
	@echo "  $(YELLOW)RabbitMQ:$(RESET)       http://localhost:15672 (admin / password123)"
	@echo "  $(YELLOW)Grafana:$(RESET)        http://localhost:3000 (admin / admin123)"
	@echo "  $(YELLOW)Elasticsearch:$(RESET)  http://localhost:9200 (elastic / elastic123)"
	@echo "  $(YELLOW)PostgreSQL:$(RESET)     localhost:5432 (admin / password123)"
	@echo "  $(YELLOW)Redis:$(RESET)          localhost:6379"
	@echo "  $(YELLOW)Kafka:$(RESET)          localhost:9092"

docker-stop:
	@echo "$(YELLOW)Stopping Docker services...$(RESET)"
	@$(DOCKER_COMPOSE) stop
	@echo "$(GREEN)Docker services stopped!$(RESET)"

docker-logs:
	@$(DOCKER_COMPOSE) logs -f

docker-clean:
	@echo "$(YELLOW)Cleaning up Docker containers and volumes...$(RESET)"
	@$(DOCKER_COMPOSE) down -v
	@echo "$(GREEN)Docker cleanup complete!$(RESET)"

# Kubernetes (k3d) commands
k3d-build:
	@echo "$(YELLOW)Building images for k3d...$(RESET)"
	@$(DOCKER_COMPOSE) build api frontend
	@echo "$(YELLOW)Tagging and pushing to local registry...$(RESET)"
	@docker tag rtmc-api:latest localhost:35000/rtmc/api:latest
	@docker tag rtmc-frontend:latest localhost:35000/rtmc/frontend:latest
	@docker push localhost:35000/rtmc/api:latest
	@docker push localhost:35000/rtmc/frontend:latest
	@echo "$(GREEN)Images ready for k3d!$(RESET)"

k3d-start:
	@echo "$(YELLOW)Starting k3d cluster...$(RESET)"
	@uv run infrastructure/scripts/k8s/create.py
	@echo "$(YELLOW)Deploying services to k3d...$(RESET)"
	@uv run infrastructure/scripts/helm/install.py
	@echo "$(GREEN)k3d cluster started and services deployed!$(RESET)"
	@echo ""
	@echo "$(CYAN)Access points:$(RESET)"
	@echo "  $(YELLOW)Frontend:$(RESET)    http://localhost:30081"
	@echo "  $(YELLOW)API:$(RESET)         http://localhost:30080"
	@echo "  $(YELLOW)Swagger:$(RESET)     http://localhost:30080/swagger"
	@echo ""
	@echo "$(CYAN)Useful commands:$(RESET)"
	@echo "  kubectl get all       - View all resources"
	@echo "  make k3d-logs         - View API logs"

k3d-stop:
	@echo "$(YELLOW)Stopping k3d cluster...$(RESET)"
	@k3d cluster delete rtmc
	@echo "$(GREEN)k3d cluster stopped!$(RESET)"

k3d-logs:
	@kubectl logs -f -l app.kubernetes.io/component=api

k3d-clean:
	@echo "$(YELLOW)Cleaning up k3d...$(RESET)"
	@k3d cluster delete rtmc 2>/dev/null || true
	@echo "$(GREEN)k3d cleanup complete!$(RESET)"

# Status command
status:
	@uv run infrastructure/scripts/status.py