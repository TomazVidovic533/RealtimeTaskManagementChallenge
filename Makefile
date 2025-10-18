.PHONY: help status build rebuild start stop down logs ps clean k3d-create k3d-delete k3d-status k3d-logs k3d-clean helm-install helm-upgrade helm-uninstall helm-status

CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
RESET := \033[0m

help:
	@echo "$(CYAN)=== Real-Time Task Management Challenge ===$(RESET)"
	@echo ""
	@echo "$(YELLOW)Status & Validation:$(RESET)"
	@echo "  make status           - Auto-detect and validate services"
	@echo ""
	@echo "$(YELLOW)Docker Compose:$(RESET)"
	@echo "  make build            - Build Docker images"
	@echo "  make start            - Start all services"
	@echo "  make stop             - Stop all services"
	@echo "  make down             - Stop and remove containers"
	@echo "  make logs             - View service logs"
	@echo "  make clean            - Remove containers and volumes"
	@echo ""
	@echo "$(YELLOW)Kubernetes (k3d):$(RESET)"
	@echo "  make k3d-create       - Create k3d cluster with registry"
	@echo "  make k3d-delete       - Delete k3d cluster"
	@echo "  make k3d-status       - Show cluster status"
	@echo "  make k3d-logs         - View API logs"
	@echo "  make k3d-clean        - Full cleanup"
	@echo ""
	@echo "$(YELLOW)Helm:$(RESET)"
	@echo "  make helm-install     - Build, push and install chart"
	@echo "  make helm-upgrade     - Rebuild, push and upgrade"
	@echo "  make helm-uninstall   - Uninstall Helm release"
	@echo "  make helm-status      - Show release status"

status:
	@uv run scripts/status.py

build:
	@docker-compose build

start:
	@uv run scripts/docker/start.py

stop:
	@echo "$(YELLOW)Stopping all services...$(RESET)"
	@docker-compose stop
	@echo "$(GREEN)All services stopped!$(RESET)"

down:
	@echo "$(YELLOW)Stopping and removing containers...$(RESET)"
	@docker-compose down
	@echo "$(GREEN)Containers removed!$(RESET)"

logs:
	@docker-compose logs -f

clean:
	@echo "$(YELLOW)Cleaning up containers and volumes...$(RESET)"
	@docker-compose down -v
	@echo "$(GREEN)Cleanup complete!$(RESET)"

k3d-create:
	@uv run scripts/k8s/create.py

k3d-delete:
	@echo "$(YELLOW)Deleting k3d cluster 'rtmc'...$(RESET)"
	@k3d cluster delete rtmc
	@echo "$(GREEN)Cluster deleted!$(RESET)"

k3d-status:
	@kubectl get all

k3d-logs:
	@kubectl logs -f -l app.kubernetes.io/component=api

k3d-clean:
	@echo "$(YELLOW)Cleaning up k3d...$(RESET)"
	@k3d cluster delete rtmc 2>/dev/null || true
	@echo "$(GREEN)k3d cleanup complete!$(RESET)"

helm-install:
	@uv run scripts/helm/install.py

helm-upgrade:
	@echo "$(YELLOW)Rebuilding API image...$(RESET)"
	@docker-compose build api
	@echo "$(YELLOW)Pushing to local registry...$(RESET)"
	@docker tag rtmc-api:latest localhost:35000/rtmc/api:latest
	@docker push localhost:35000/rtmc/api:latest
	@echo "$(YELLOW)Upgrading Helm chart...$(RESET)"
	@helm upgrade rtmc ./helm/rtmc
	@echo "$(GREEN)Helm chart upgraded!$(RESET)"

helm-uninstall:
	@echo "$(YELLOW)Uninstalling Helm chart...$(RESET)"
	@helm uninstall rtmc
	@echo "$(GREEN)Helm chart uninstalled!$(RESET)"

helm-status:
	@echo "$(CYAN)Helm Release Status:$(RESET)"
	@helm status rtmc
	@echo ""
	@echo "$(CYAN)Kubernetes Resources:$(RESET)"
	@kubectl get all -l app.kubernetes.io/instance=rtmc
