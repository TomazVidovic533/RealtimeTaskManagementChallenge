# Real-time Task Management System

Portfolio project showcasing .NET 9 + React 19 + SignalR + Kafka + RabbitMQ + Redis in a production-grade, real-time task management system.

## Overview

This project demonstrates a full-stack, event-driven task management system with real-time collaboration capabilities. It showcases data engineering and backend skills through distributed architecture, event streaming, and scalable system design.

## Architecture

The system combines multiple technologies to create a cohesive, scalable solution:

- **Real-time Communication**: WebSocket-based updates via SignalR
- **Event-Driven Architecture**: Kafka for event streaming, RabbitMQ for message routing
- **Distributed Caching**: Redis for performance and SignalR backplane
- **Clean Architecture**: Domain-Driven Design with vertical slice features
- **CQRS Pattern**: Separate command and query responsibilities

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | .NET 9 | Web API framework |
| Database | PostgreSQL 17 | Primary data store |
| Caching | Redis 7.4 | Distributed cache and SignalR backplane |
| Messaging | Kafka 3.8 | High-throughput event streaming |
| Queue | RabbitMQ 4.0 | Reliable message delivery |
| Real-time | SignalR | WebSocket communication |
| Search | Elasticsearch 8.17 | Full-text search and analytics |
| Monitoring | Grafana 11.5 | Metrics visualization and dashboards |
| Frontend | React 19 | User interface |
| Infrastructure | Docker, k3d | Containerization and orchestration |

## System Flow

```
User Action → API Endpoint → Domain Logic → Event Published
                                              ↓
                                          Kafka (Analytics)
                                              ↓
                                          RabbitMQ (Routing)
                                              ↓
                                          SignalR Hub
                                              ↓
                                     All Connected Clients
```

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Node.js 18+](https://nodejs.org/) (for React frontend)
- Make (optional, for simplified commands)

## Getting Started

### Option 1: Docker (Recommended)

```bash
make docker-build    # Build all Docker images
make docker-start    # Start all services (includes frontend)
```

Access points:
- Frontend: http://localhost:3001
- API: http://localhost:8080
- Swagger: http://localhost:8080/swagger

### Option 2: Kubernetes (k3d)

```bash
make k3d-build       # Build and push images
make k3d-start       # Create cluster and deploy services (includes frontend)
```

Access points:
- Frontend: http://localhost:30081
- API: http://localhost:30080
- Swagger: http://localhost:30080/swagger

### Option 3: Local Development

**Backend:**
```bash
make backend-build
make backend-run
```

**Frontend:**
```bash
make frontend-install
make frontend-dev
```

## Service Endpoints

| Service | URL | Credentials |
|---------|-----|-------------|
| API | http://localhost:8080 | - |
| API (HTTPS) | https://localhost:8081 | - |
| Swagger UI | http://localhost:8080/swagger | - |
| PostgreSQL | localhost:5432 | admin / password123 |
| Redis | localhost:6379 | - |
| Kafka | localhost:9092 | - |
| RabbitMQ AMQP | localhost:5672 | admin / password123 |
| RabbitMQ Management | http://localhost:15672 | admin / password123 |
| Elasticsearch | http://localhost:9200 | elastic / elastic123 |
| Grafana | http://localhost:3000 | admin / admin123 |

## Commands

```bash
make help              # Show all commands

# Local Development
make backend-build     # Build backend
make backend-run       # Run API locally
make backend-test      # Run tests
make frontend-install  # Install frontend dependencies
make frontend-dev      # Start frontend dev server

# Docker
make docker-build      # Build all Docker images
make docker-start      # Start all services
make docker-stop       # Stop services
make docker-logs       # View logs
make docker-clean      # Clean everything

# Kubernetes (k3d)
make k3d-build         # Build and push images
make k3d-start         # Create cluster and deploy
make k3d-stop          # Stop cluster
make k3d-logs          # View API logs
make k3d-clean         # Full cleanup
```

## Project Structure

```
01_realtime_task_management/
├── backend/              # .NET 9 Web API
│   ├── src/              # Source code
│   ├── tests/            # Unit & integration tests
│   └── README.md
├── frontend/             # React 19 + Vite
│   ├── src/              # Source code
│   └── README.md
├── infrastructure/       # DevOps & Deployment
│   ├── docker/           # Docker Compose
│   ├── helm/             # Kubernetes Helm charts
│   ├── scripts/          # Automation scripts
│   └── README.md
└── docs/                 # Documentation
    ├── USE_CASES.md
    ├── Specifications.md
    └── Commands.md
```

## Key Features

- **Task Management**: Create, update, assign, and track tasks
- **Real-time Updates**: Instant propagation of changes via SignalR
- **Team Collaboration**: Multi-user workspaces with role-based access
- **Event Sourcing**: Complete audit trail of all domain events
- **Distributed Architecture**: Horizontally scalable design
- **Clean Architecture**: Domain-Driven Design principles throughout

## Documentation

- [Use Cases](docs/USE_CASES.md) - System use cases and scenarios
- [Specifications](docs/Specifications.md) - Technical specifications
- [Backend README](backend/README.md) - Backend setup and architecture
- [Frontend README](frontend/README.md) - Frontend setup and development
- [Infrastructure README](infrastructure/README.md) - DevOps and deployment

## What This Project Demonstrates

- **Data Engineering**: Event streaming with Kafka, message queuing with RabbitMQ
- **Backend Architecture**: Clean Architecture, DDD, CQRS patterns
- **Distributed Systems**: Event-driven design, horizontal scaling with Redis
- **Real-time Systems**: WebSocket implementation with SignalR
- **Modern .NET**: Latest .NET 9 features and best practices
- **Full-Stack Development**: Seamless backend and frontend integration
- **DevOps**: Docker, Kubernetes, Helm deployment strategies