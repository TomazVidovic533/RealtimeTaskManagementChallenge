# Real-Time Task Management Challenge

A production-grade task management API demonstrating distributed systems architecture with real-time collaboration capabilities.

## Overview

This project showcases a multi-user task management system where changes propagate instantly across all connected clients. Built with modern distributed architecture patterns, it demonstrates proficiency in event-driven design, real-time communication, and scalable system implementation.

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
| Frontend | React | User interface |
| Infrastructure | Docker | Containerization |

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

### Quick Start with Make

```bash
make help       # Display all available commands
make start      # Start all services
make logs       # View service logs
make stop       # Stop all services
make clean      # Remove containers and volumes
```

### Manual Setup

1. **Start Infrastructure**
   ```bash
   docker-compose up -d
   ```

2. **Apply Database Migrations**
   ```bash
   cd src/TaskManagement.API
   dotnet ef database update
   ```

3. **Run API**
   ```bash
   dotnet run --project src/TaskManagement.API/
   ```

4. **Start Frontend** (separate terminal)
   ```bash
   cd react-app
   npm install
   npm start
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

## Available Commands

### Docker Compose

```bash
make start      # Start all services
make stop       # Stop all services
make logs       # View service logs
make clean      # Remove containers and volumes
```

### Kubernetes/Helm

```bash
make k3d-create      # Create k3d cluster
make helm-install    # Deploy with Helm
make helm-status     # Check deployment
make helm-uninstall  # Remove deployment
make k3d-delete      # Delete cluster
```

## Project Structure

```
src/
├── TaskManagement.API/          # API entry point
├── TaskManagement.Shared/       # Shared infrastructure
└── Features/                    # Vertical slice features
    ├── Tasks/                   # Task management
    ├── Users/                   # User authentication
    ├── Teams/                   # Team collaboration
    ├── Comments/                # Task discussions
    └── Notifications/           # Real-time notifications
```

## Features

- **Task Management**: Create, update, assign, and track tasks
- **Real-time Updates**: Instant propagation of changes to all clients
- **Team Collaboration**: Multi-user workspaces with role-based access
- **Event Sourcing**: Complete audit trail of all domain events
- **Distributed Architecture**: Horizontally scalable design
- **Clean Code**: Domain-Driven Design principles throughout

## Development

### Running Tests

```bash
dotnet test
```

### Database Migrations

```bash
cd src/TaskManagement.API
dotnet ef migrations add MigrationName
dotnet ef database update
```

### Monitoring Services

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f api
docker-compose logs -f postgres

# Check service health
docker-compose ps
```

## Project Goals

This project demonstrates:

- **Architecture Skills**: Clean architecture, DDD, CQRS patterns
- **Distributed Systems**: Event-driven design with Kafka and RabbitMQ
- **Real-time Systems**: WebSocket implementation with SignalR
- **Scalability**: Horizontal scaling with Redis backplane
- **Modern .NET**: Latest framework features and best practices
- **Full-Stack Integration**: Backend and frontend working seamlessly