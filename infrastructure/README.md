# Infrastructure

DevOps and deployment configuration for the Real-time Task Management System.

## Structure

```
infrastructure/
├── docker/               # Docker configuration
│   ├── docker-compose.yml
│   └── .dockerignore
├── helm/                # Kubernetes Helm charts
│   └── rtmc/
└── scripts/             # Automation scripts
    ├── status.py        # Service status checker
    ├── docker/          # Docker helpers
    ├── helm/            # Helm helpers
    └── k8s/             # Kubernetes helpers
```

## Docker Compose

### Quick Start

From the project root:

```bash
make start    # Start all services
make logs     # View logs
make stop     # Stop services
```

Or directly:

```bash
cd infrastructure/docker
docker-compose up -d
```

### Services

- **postgres** - PostgreSQL database (port 5432)
- **redis** - Redis cache (port 6379)
- **kafka** - Kafka message broker (port 9092)
- **rabbitmq** - RabbitMQ (port 5672, management: 15672)
- **api** - .NET API (ports 8080, 8081)

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=taskmanagement
API_HTTP_PORT=5000
API_HTTPS_PORT=5001
```

## Kubernetes (k3d)

### Create Cluster

```bash
# From project root
make k3d-create
```

### Deploy with Helm

```bash
# Install
make helm-install

# Upgrade
make helm-upgrade

# Status
make helm-status

# Uninstall
make helm-uninstall
```

### Manual kubectl

```bash
# Get all resources
kubectl get all

# View API logs
kubectl logs -f -l app.kubernetes.io/component=api

# Port forward
kubectl port-forward svc/rtmc-api 5000:80
```

## Scripts

### Status Checker

Check the status of all services:

```bash
# From project root
make status

# Or directly
uv run infrastructure/scripts/status.py
```

### Docker Scripts

Located in `scripts/docker/`:
- `start.py` - Start services with health checks

### Helm Scripts

Located in `scripts/helm/`:
- `install.py` - Build, push, and install Helm chart

### Kubernetes Scripts

Located in `scripts/k8s/`:
- `create.py` - Create k3d cluster with registry
- `validate_k8s.py` - Validate Kubernetes resources

## Tech Stack

- **Docker** - Containerization
- **Docker Compose** - Local development
- **k3d** - Lightweight Kubernetes
- **Helm** - Kubernetes package manager
- **Python** - Automation scripts