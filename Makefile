.PHONY: help status backend-build backend-run backend-test frontend-install frontend-dev frontend-build docker-build docker-start docker-stop docker-logs docker-clean k3d-start k3d-update k3d-stop k3d-status k3d-logs k3d-logs-api k3d-logs-frontend k3d-logs-postgres k3d-logs-redis k3d-logs-kafka k3d-logs-rabbitmq k3d-logs-elasticsearch k3d-logs-grafana k3d-clean linkerd-dashboard linkerd-check linkerd-tap

# Colors
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

DOCKER_COMPOSE := docker-compose -f infrastructure/docker/docker-compose.yml --env-file .env
DOCKER_COMPOSE_DEV := docker-compose -f infrastructure/docker/docker-compose.dev.yml --env-file .env

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
	@echo "$(YELLOW)Docker (Production):$(RESET)"
	@echo "  make docker-build     - Build all Docker images (backend + frontend)"
	@echo "  make docker-start     - Start all services with Docker Compose"
	@echo "  make docker-stop      - Stop Docker services"
	@echo "  make docker-logs      - View Docker logs"
	@echo "  make docker-clean     - Remove all containers and volumes"
	@echo ""
	@echo "$(YELLOW)Docker (Development with Hot Reload):$(RESET)"
	@echo "  make docker-dev-build - Build dev images with hot reload"
	@echo "  make docker-dev-start - Start dev environment with hot reload"
	@echo "  make docker-dev-stop  - Stop dev environment"
	@echo "  make docker-dev-logs  - View all dev logs"
	@echo "  make docker-dev-logs-api      - View API logs only"
	@echo "  make docker-dev-logs-frontend - View frontend logs only"
	@echo "  make docker-dev-clean - Remove dev containers and volumes"
	@echo ""
	@echo "$(YELLOW)Kubernetes (k3d) with Linkerd Service Mesh:$(RESET)"
	@echo "  make k3d-start        - Create cluster with Linkerd + Ingress (all-in-one)"
	@echo "  make k3d-update       - Rebuild images and upgrade deployment"
	@echo "  make k3d-status       - View cluster status"
	@echo "  make k3d-logs         - View all pod logs"
	@echo "  make k3d-logs-<svc>   - View specific service logs"
	@echo "  make k3d-stop         - Stop and remove cluster"
	@echo "  make k3d-clean        - Full cleanup"
	@echo ""
	@echo "$(YELLOW)Monitoring (after k3d-start):$(RESET)"
	@echo "  make linkerd-dashboard - Open Linkerd dashboard (auto-opens browser)"
	@echo "  make linkerd-check     - Verify Linkerd health"
	@echo "  make linkerd-tap       - Live traffic monitoring"
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

# Docker Development Mode (with hot reload)
docker-dev-build:
	@echo "$(YELLOW)Building Docker dev images...$(RESET)"
	@$(DOCKER_COMPOSE_DEV) build
	@echo "$(GREEN)Docker dev images built successfully!$(RESET)"

docker-dev-start:
	@echo "$(YELLOW)Starting development environment with hot reload...$(RESET)"
	@$(DOCKER_COMPOSE_DEV) up -d
	@echo "$(YELLOW)Waiting for services to be healthy...$(RESET)"
	@sleep 5
	@echo "$(GREEN)Development environment started!$(RESET)"
	@echo ""
	@echo "$(CYAN)Access points:$(RESET)"
	@echo "  $(YELLOW)Frontend (Vite):$(RESET) http://localhost:3001 (Hot Reload Enabled)"
	@echo "  $(YELLOW)API (.NET):$(RESET)      http://localhost:8080 (Hot Reload Enabled)"
	@echo "  $(YELLOW)Swagger:$(RESET)         http://localhost:8080/swagger"
	@echo "  $(YELLOW)RabbitMQ:$(RESET)        http://localhost:15672 (admin / password123)"
	@echo "  $(YELLOW)Grafana:$(RESET)         http://localhost:3000 (admin / admin123)"
	@echo "  $(YELLOW)Elasticsearch:$(RESET)   http://localhost:9200 (elastic / elastic123)"
	@echo "  $(YELLOW)PostgreSQL:$(RESET)      localhost:5432 (admin / password123)"
	@echo "  $(YELLOW)Redis:$(RESET)           localhost:6379"
	@echo "  $(YELLOW)Kafka:$(RESET)           localhost:9092"
	@echo ""
	@echo "$(GREEN)Hot Reload:$(RESET)"
	@echo "  - Frontend: Edit files in ./frontend/src and changes will reload automatically"
	@echo "  - Backend: Edit files in ./backend/src and the API will rebuild automatically"

docker-dev-stop:
	@echo "$(YELLOW)Stopping development environment...$(RESET)"
	@$(DOCKER_COMPOSE_DEV) stop
	@echo "$(GREEN)Development environment stopped!$(RESET)"

docker-dev-logs:
	@$(DOCKER_COMPOSE_DEV) logs -f

docker-dev-logs-api:
	@echo "$(YELLOW)Showing API logs (hot reload enabled)...$(RESET)"
	@$(DOCKER_COMPOSE_DEV) logs -f api

docker-dev-logs-frontend:
	@echo "$(YELLOW)Showing Frontend logs (hot reload enabled)...$(RESET)"
	@$(DOCKER_COMPOSE_DEV) logs -f frontend

docker-dev-clean:
	@echo "$(YELLOW)Cleaning up development environment...$(RESET)"
	@$(DOCKER_COMPOSE_DEV) down -v
	@echo "$(GREEN)Development environment cleaned!$(RESET)"

# Kubernetes (k3d) commands
k3d-start:
	@echo "$(YELLOW)Starting k3d cluster with Linkerd service mesh...$(RESET)"
	@uv run infrastructure/scripts/k8s/create.py
	@echo "$(YELLOW)Installing Linkerd...$(RESET)"
	@uv run infrastructure/scripts/k8s/install_linkerd.py
	@echo "$(YELLOW)Deploying services...$(RESET)"
	@uv run infrastructure/scripts/helm/install.py
	@echo "$(GREEN)✓ k3d cluster ready with Linkerd + Traefik!$(RESET)"
	@echo ""
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║                         ACCESS POINTS                                ║$(RESET)"
	@echo "$(CYAN)╠══════════════════════════════════════════════════════════════════════╣$(RESET)"
	@echo "$(CYAN)║$(RESET) $(YELLOW)Service$(RESET)           │ $(YELLOW)URL$(RESET)                                  │ $(YELLOW)Credentials$(RESET)        $(CYAN)║$(RESET)"
	@echo "$(CYAN)╠══════════════════════════════════════════════════════════════════════╣$(RESET)"
	@echo "$(CYAN)║$(RESET) Frontend          │ http://localhost                     │ -                  $(CYAN)║$(RESET)"
	@echo "$(CYAN)║$(RESET) API               │ http://localhost/api/weatherforecast │ -                  $(CYAN)║$(RESET)"
	@echo "$(CYAN)║$(RESET) Swagger           │ http://localhost/api/swagger         │ -                  $(CYAN)║$(RESET)"
	@echo "$(CYAN)║$(RESET) Grafana           │ http://localhost/grafana             │ admin / admin123   $(CYAN)║$(RESET)"
	@echo "$(CYAN)║$(RESET) Linkerd Dashboard │ make linkerd-dashboard               │ Auto-opens browser $(CYAN)║$(RESET)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(CYAN)Useful commands:$(RESET)"
	@echo "  $(YELLOW)make k3d-status$(RESET)        - View cluster status"
	@echo "  $(YELLOW)make k3d-logs$(RESET)          - View all pod logs"
	@echo "  $(YELLOW)make linkerd-dashboard$(RESET) - Open monitoring dashboard"

k3d-update:
	@echo "$(YELLOW)Rebuilding images...$(RESET)"
	@$(DOCKER_COMPOSE) build api frontend
	@echo "$(YELLOW)Tagging and pushing to k3d registry...$(RESET)"
	@docker tag rtmc-api:latest localhost:35000/rtmc/api:latest
	@docker tag rtmc-frontend:latest localhost:35000/rtmc/frontend:latest
	@docker push localhost:35000/rtmc/api:latest
	@docker push localhost:35000/rtmc/frontend:latest
	@echo "$(YELLOW)Upgrading Helm deployment...$(RESET)"
	@helm upgrade rtmc infrastructure/helm/rtmc
	@echo "$(YELLOW)Restarting pods to pick up new images...$(RESET)"
	@kubectl rollout restart deployment/rtmc-api
	@kubectl rollout restart deployment/rtmc-frontend
	@kubectl rollout status deployment/rtmc-api
	@kubectl rollout status deployment/rtmc-frontend
	@echo "$(GREEN)Deployment updated successfully!$(RESET)"

k3d-stop:
	@echo "$(YELLOW)Stopping k3d cluster...$(RESET)"
	@k3d cluster delete rtmc
	@echo "$(GREEN)k3d cluster stopped!$(RESET)"

k3d-status:
	@echo "$(CYAN)=== k3d Cluster Status ===$(RESET)"
	@kubectl get pods -o wide
	@echo ""
	@echo "$(CYAN)=== Services ===$(RESET)"
	@kubectl get svc

k3d-logs:
	@echo "$(YELLOW)Showing logs for all pods...$(RESET)"
	@kubectl logs -l app.kubernetes.io/instance=rtmc --all-containers=true --tail=50

k3d-logs-api:
	@kubectl logs -f -l app.kubernetes.io/component=api

k3d-logs-frontend:
	@kubectl logs -f -l app.kubernetes.io/component=frontend

k3d-logs-postgres:
	@kubectl logs -f -l app.kubernetes.io/component=postgres

k3d-logs-redis:
	@kubectl logs -f -l app.kubernetes.io/component=redis

k3d-logs-kafka:
	@kubectl logs -f -l app.kubernetes.io/component=kafka

k3d-logs-rabbitmq:
	@kubectl logs -f -l app.kubernetes.io/component=rabbitmq

k3d-logs-elasticsearch:
	@kubectl logs -f -l app.kubernetes.io/component=elasticsearch

k3d-logs-grafana:
	@kubectl logs -f -l app.kubernetes.io/component=grafana

k3d-clean:
	@echo "$(YELLOW)Cleaning up k3d...$(RESET)"
	@k3d cluster delete rtmc 2>/dev/null || true
	@echo "$(GREEN)k3d cleanup complete!$(RESET)"

linkerd-dashboard:
	@uv run infrastructure/scripts/linkerd/dashboard.py

linkerd-check:
	@echo "$(YELLOW)Checking Linkerd health...$(RESET)"
	@~/.linkerd2/bin/linkerd check

linkerd-tap:
	@echo "$(YELLOW)Live traffic monitoring (Ctrl+C to stop)...$(RESET)"
	@~/.linkerd2/bin/linkerd viz tap deploy

status:
	@uv run infrastructure/scripts/status.py