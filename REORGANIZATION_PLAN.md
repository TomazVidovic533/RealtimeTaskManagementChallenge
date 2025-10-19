# Project Reorganization Plan

## Overview

Clean separation of backend, frontend, and infrastructure for a portfolio-ready project structure.

---

## Current Structure

```
01_realtime_task_management/
├── src/                    # Backend .NET code
├── tests/                  # Backend tests
├── frontend-webapp/        # React app
├── helm/                   # Helm charts
├── scripts/                # Build scripts
├── docker-compose.yml
├── Makefile
├── TaskManagementAPI.sln
└── docs...
```

---

## Target Structure

```
01_realtime_task_management/
│
├── backend/                # .NET Web API
│   ├── src/
│   ├── tests/
│   ├── TaskManagementAPI.sln
│   ├── global.json
│   └── README.md
│
├── frontend/               # React App
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── README.md
│
├── infrastructure/         # DevOps & Deployment
│   ├── docker/
│   │   └── docker-compose.yml
│   ├── helm/
│   └── scripts/
│
├── docs/                   # Documentation
│   ├── USE_CASES.md
│   ├── Specifications.md
│   └── Commands.md
│
├── Makefile               # Quick commands
└── README.md
```

---

## Migration Steps

### Step 1: Backup

```bash
git add .
git commit -m "chore: backup before reorganization"
git branch backup-reorganization
```

### Step 2: Create Directories

```bash
mkdir -p backend
mkdir -p frontend
mkdir -p infrastructure/docker
mkdir -p infrastructure/helm
mkdir -p infrastructure/scripts
mkdir -p docs
```

### Step 3: Move Backend

```bash
git mv src backend/
git mv tests backend/
git mv TaskManagementAPI.sln backend/
git mv global.json backend/
```

### Step 4: Move Frontend

```bash
# Move all files from frontend-webapp to frontend
git mv frontend-webapp/* frontend/ 2>/dev/null || mv frontend-webapp/* frontend/
git mv frontend-webapp/.gitignore frontend/ 2>/dev/null || mv frontend-webapp/.gitignore frontend/
rmdir frontend-webapp
```

### Step 5: Move Infrastructure

```bash
git mv docker-compose.yml infrastructure/docker/
git mv helm/* infrastructure/helm/ 2>/dev/null || true
rmdir helm 2>/dev/null || true
git mv scripts/* infrastructure/scripts/ 2>/dev/null || mv scripts/* infrastructure/scripts/
rmdir scripts 2>/dev/null || true
git mv .dockerignore infrastructure/docker/ 2>/dev/null || true
```

### Step 6: Move Documentation

```bash
git mv USE_CASES.md docs/
git mv Specifications.md docs/
git mv Commands.md docs/ 2>/dev/null || true
```

### Step 7: Update docker-compose.yml

Edit `infrastructure/docker/docker-compose.yml`:

```yaml
services:
  api:
    build:
      context: ../../backend
      dockerfile: src/TaskManagement.API/Dockerfile
    # ... rest of config

  frontend:
    build:
      context: ../../frontend
      dockerfile: Dockerfile
    # ... rest of config
```

### Step 8: Update Makefile

Replace content with updated paths:

```makefile
.PHONY: help status build start stop down logs clean

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
```

### Step 9: Create backend/README.md

```markdown
# Task Management API

.NET 9 Web API with Clean Architecture.

## Quick Start

```bash
# Restore packages
dotnet restore

# Run API
dotnet run --project src/TaskManagement.API

# Run tests
dotnet test
```

## Structure

- `src/TaskManagement.API/` - Web API
- `src/TaskManagement.Shared/` - Shared libraries
- `src/Features/` - Feature modules
- `tests/` - Tests

API: http://localhost:5000
Swagger: http://localhost:5000/swagger
```

### Step 10: Create frontend/README.md

```markdown
# Task Management Frontend

React 19 + Vite + Mantine

## Quick Start

```bash
# Install
npm install

# Dev server
npm run dev

# Build
npm run build
```

## Structure

- `src/` - Source code
- `public/` - Static assets

App: http://localhost:5173
```

### Step 11: Create infrastructure/README.md

```markdown
# Infrastructure

## Docker

```bash
docker-compose -f docker/docker-compose.yml up
```

## Kubernetes

```bash
# From root
make k3d-create
make helm-install
```

## Scripts

- `scripts/status.py` - Service status
- `scripts/docker/` - Docker helpers
- `scripts/k8s/` - Kubernetes helpers
- `scripts/helm/` - Helm helpers
```

### Step 12: Update Root README.md

```markdown
# Real-time Task Management System

Portfolio project showcasing .NET 9 + React 19 + SignalR + Kafka + RabbitMQ + Redis.

## Structure

```
├── backend/          # .NET 9 Web API
├── frontend/         # React 19 + Vite
├── infrastructure/   # Docker, K8s, Helm
└── docs/            # Documentation
```

## Quick Start

### Option 1: Docker (Recommended)

```bash
make start    # Start all services
make logs     # View logs
make stop     # Stop services
```

### Option 2: Manual

**Backend:**
```bash
cd backend
dotnet run --project src/TaskManagement.API
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

## Tech Stack

**Backend:** .NET 9, EF Core, PostgreSQL, SignalR, MediatR, FluentValidation

**Frontend:** React 19, Vite, TypeScript, Mantine, SignalR Client

**Infrastructure:** Docker, Kubernetes, Helm, Kafka, RabbitMQ, Redis

## Documentation

- [Use Cases](docs/USE_CASES.md)
- [Specifications](docs/Specifications.md)

## Commands

```bash
make help              # Show all commands

# Backend
make backend-build     # Build backend
make backend-run       # Run API
make backend-test      # Run tests

# Frontend
make frontend-install  # Install dependencies
make frontend-dev      # Dev server
make frontend-build    # Production build

# Docker
make build            # Build images
make start            # Start services
make logs             # View logs
make stop             # Stop services
```
```

---

## Testing Checklist

After reorganization:

- [ ] `cd backend && dotnet build` ✅
- [ ] `cd backend && dotnet run --project src/TaskManagement.API` ✅
- [ ] `cd frontend && npm install` ✅
- [ ] `cd frontend && npm run dev` ✅
- [ ] `make build` ✅
- [ ] `make start` ✅
- [ ] `make help` ✅

---

## Rollback

If needed:

```bash
git reset --hard backup-reorganization
```

---

## Benefits

✅ **Clear Separation** - Each part has its own directory
✅ **Easy Navigation** - Know exactly where everything is
✅ **Portfolio Ready** - Professional structure
✅ **Scalable** - Easy to add more services
✅ **Clean** - No mixed concerns

---

**Ready to execute?** Run each step in order and test as you go.
