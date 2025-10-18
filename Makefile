.PHONY: help build rebuild start stop down logs ps clean k3d-create k3d-delete k3d-deploy k3d-status k3d-logs k3d-clean helm-install helm-upgrade helm-uninstall helm-status helm-template

CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
RESET := \033[0m

help:
	@echo "$(CYAN)=== Real-Time Task Management Challenge ===$(RESET)"
	@echo ""
	@echo "$(YELLOW)Docker Compose Commands:$(RESET)"
	@echo "  make build     - Build Docker images"
	@echo "  make rebuild   - Clean rebuild (no cache)"
	@echo "  make start     - Start all services"
	@echo "  make stop      - Stop all services"
	@echo "  make down      - Stop and remove containers"
	@echo "  make logs      - View service logs"
	@echo "  make ps        - List running containers"
	@echo "  make clean     - Remove containers and volumes"
	@echo ""
	@echo "$(YELLOW)k3d/Kubernetes Commands:$(RESET)"
	@echo "  make k3d-create  - Create k3d cluster"
	@echo "  make k3d-deploy  - Deploy to k3d cluster"
	@echo "  make k3d-status  - Show cluster status"
	@echo "  make k3d-logs    - View API logs"
	@echo "  make k3d-delete  - Delete k3d cluster"
	@echo "  make k3d-clean   - Full cleanup (cluster + manifests)"
	@echo ""
	@echo "$(YELLOW)Helm Commands:$(RESET)"
	@echo "  make helm-install    - Install Helm chart"
	@echo "  make helm-upgrade    - Upgrade Helm release"
	@echo "  make helm-uninstall  - Uninstall Helm release"
	@echo "  make helm-status     - Show Helm release status"
	@echo "  make helm-template   - Render templates (dry-run)"
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

k3d-create:
	@echo "$(YELLOW)Creating k3d cluster 'rtmc' with local registry...$(RESET)"
	k3d cluster create rtmc \
		--registry-create rtmc-registry:0.0.0.0:35000 \
		--port "8080:8080@loadbalancer" \
		--port "5432:5432@loadbalancer" \
		--port "6379:6379@loadbalancer" \
		--port "9092:9092@loadbalancer" \
		--port "5672:5672@loadbalancer" \
		--port "15672:15672@loadbalancer"
	@echo "$(GREEN)k3d cluster created!$(RESET)"
	@echo "$(BLUE)Cluster: rtmc$(RESET)"
	@echo "$(BLUE)Registry: localhost:35000$(RESET)"

k3d-delete:
	@echo "$(YELLOW)Deleting k3d cluster 'rtmc'...$(RESET)"
	k3d cluster delete rtmc
	@echo "$(GREEN)Cluster deleted!$(RESET)"

k3d-deploy:
	@echo "$(YELLOW)Converting docker-compose to Kubernetes manifests...$(RESET)"
	@mkdir -p k8s
	kompose convert -f docker-compose.yml -o k8s/
	@echo "$(YELLOW)Deploying to k3d...$(RESET)"
	kubectl apply -f k8s/
	@echo "$(GREEN)Deployed to k3d!$(RESET)"
	@echo ""
	@echo "$(CYAN)Access points:$(RESET)"
	@echo "  $(BLUE)API:         http://localhost:8080$(RESET)"
	@echo "  $(BLUE)PostgreSQL:  localhost:5432$(RESET)"
	@echo "  $(BLUE)Redis:       localhost:6379$(RESET)"
	@echo "  $(BLUE)RabbitMQ UI: http://localhost:15672$(RESET)"

k3d-status:
	@echo "$(CYAN)k3d Cluster Status:$(RESET)"
	@kubectl get all
	@echo ""
	@echo "$(CYAN)Persistent Volume Claims:$(RESET)"
	@kubectl get pvc

k3d-logs:
	@echo "$(YELLOW)Following API logs (Ctrl+C to exit)...$(RESET)"
	kubectl logs -f -l io.kompose.service=api

k3d-clean:
	@echo "$(YELLOW)Cleaning up k8s manifests and cluster...$(RESET)"
	kubectl delete -f k8s/ 2>/dev/null || true
	rm -rf k8s/
	k3d cluster delete rtmc 2>/dev/null || true
	@echo "$(GREEN)k3d cleanup complete!$(RESET)"

helm-install:
	@echo "$(YELLOW)Building API image...$(RESET)"
	docker-compose build api
	@echo "$(YELLOW)Tagging and pushing to local registry...$(RESET)"
	docker tag rtmc-api:latest localhost:35000/rtmc/api:latest
	docker push localhost:35000/rtmc/api:latest
	@echo "$(YELLOW)Installing Helm chart...$(RESET)"
	helm install rtmc ./helm/rtmc
	@echo "$(GREEN)Helm chart installed!$(RESET)"
	@echo ""
	@echo "$(YELLOW)Waiting for pods to be ready...$(RESET)"
	@sleep 15
	@kubectl get pods
	@echo ""
	@echo "$(CYAN)Access API:$(RESET)"
	@echo "  $(BLUE)curl http://localhost:8080/weatherforecast$(RESET)"

helm-upgrade:
	@echo "$(YELLOW)Rebuilding API image...$(RESET)"
	docker-compose build api
	@echo "$(YELLOW)Pushing to local registry...$(RESET)"
	docker tag rtmc-api:latest localhost:35000/rtmc/api:latest
	docker push localhost:35000/rtmc/api:latest
	@echo "$(YELLOW)Upgrading Helm chart...$(RESET)"
	helm upgrade rtmc ./helm/rtmc
	@echo "$(GREEN)Helm chart upgraded!$(RESET)"

helm-uninstall:
	@echo "$(YELLOW)Uninstalling Helm chart...$(RESET)"
	helm uninstall rtmc
	@echo "$(GREEN)Helm chart uninstalled!$(RESET)"

helm-status:
	@echo "$(CYAN)Helm Release Status:$(RESET)"
	@helm status rtmc
	@echo ""
	@echo "$(CYAN)Kubernetes Resources:$(RESET)"
	@kubectl get all -l app.kubernetes.io/instance=rtmc

helm-template:
	@echo "$(CYAN)Rendering Helm templates...$(RESET)"
	@helm template rtmc ./helm/rtmc
