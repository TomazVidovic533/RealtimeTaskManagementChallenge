.PHONY: help status build start stop down logs clean backend-build backend-run backend-test frontend-install frontend-dev frontend-build k3d-create k3d-delete k3d-status k3d-logs helm-install helm-upgrade helm-uninstall helm-status

# Colors
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

DOCKER_COMPOSE := docker-compose -f infrastructure/docker/docker-compose.yml

help:
	@echo "$(CYAN)=== Real-Time Task Management ===$(RESET)"
	@echo ""
	@echo "$(YELLOW)Backend:$(RESET)"
	@echo "  make backend-build    - Build backend"
	@echo "  make backend-run      - Run backend API"
	@echo "  make backend-test     - Run tests"
	@echo ""
	@echo "$(YELLOW)Frontend:$(RESET)"
	@echo "  make frontend-install - Install dependencies"
	@echo "  make frontend-dev     - Run dev server"
	@echo "  make frontend-build   - Build for production"
	@echo ""
	@echo "$(YELLOW)Docker:$(RESET)"
	@echo "  make build            - Build Docker images"
	@echo "  make start            - Start all services"
	@echo "  make stop             - Stop services"
	@echo "  make down             - Stop and remove"
	@echo "  make logs             - View logs"
	@echo "  make clean            - Clean everything"
	@echo ""
	@echo "$(YELLOW)Other:$(RESET)"
	@echo "  make status           - Check service status"
	@echo ""
	@echo "$(YELLOW)Kubernetes (k3d):$(RESET)"
	@echo "  make k3d-create       - Create k3d cluster with registry"
	@echo "  make k3d-delete       - Delete k3d cluster"
	@echo "  make k3d-status       - Show cluster status"
	@echo ""
	@echo "$(YELLOW)Helm:$(RESET)"
	@echo "  make helm-install     - Build, push and install chart"
	@echo "  make helm-upgrade     - Rebuild, push and upgrade"
	@echo "  make helm-uninstall   - Uninstall Helm release"
	@echo "  make helm-status      - Show release status"

# Backend commands
backend-build:
	@cd backend && dotnet build

backend-run:
	@cd backend && dotnet run --project src/TaskManagement.API

backend-test:
	@cd backend && dotnet test

# Frontend commands
frontend-install:
	@cd frontend && npm install

frontend-dev:
	@cd frontend && npm run dev

frontend-build:
	@cd frontend && npm run build

# Docker commands
status:
	@uv run infrastructure/scripts/status.py

build:
	@$(DOCKER_COMPOSE) build

start:
	@uv run infrastructure/scripts/docker/start.py

stop:
	@$(DOCKER_COMPOSE) stop

down:
	@$(DOCKER_COMPOSE) down

logs:
	@$(DOCKER_COMPOSE) logs -f

clean:
	@$(DOCKER_COMPOSE) down -v

# Kubernetes
k3d-create:
	@uv run infrastructure/scripts/k8s/create.py

k3d-delete:
	@k3d cluster delete rtmc

k3d-status:
	@kubectl get all

k3d-logs:
	@kubectl logs -f -l app.kubernetes.io/component=api

# Helm
helm-install:
	@uv run infrastructure/scripts/helm/install.py

helm-upgrade:
	@$(DOCKER_COMPOSE) build api
	@docker tag rtmc-api:latest localhost:35000/rtmc/api:latest
	@docker push localhost:35000/rtmc/api:latest
	@helm upgrade rtmc ./infrastructure/helm/rtmc

helm-uninstall:
	@helm uninstall rtmc

helm-status:
	@helm status rtmc
