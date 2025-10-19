# Task Management API

.NET 9 Web API with Clean Architecture showcasing real-time task management capabilities.

## Tech Stack

- **.NET 9** - Modern web framework
- **EF Core** - Entity Framework for data access
- **PostgreSQL** - Primary database
- **Redis** - Caching and session management
- **Kafka** - Event streaming
- **RabbitMQ** - Message queuing
- **SignalR** - Real-time communication
- **MediatR** - CQRS pattern implementation
- **FluentValidation** - Request validation

## Architecture

Clean Architecture with feature-based organization:

```
backend/
├── src/
│   ├── TaskManagement.API/       # Web API entry point
│   ├── TaskManagement.Shared/    # Shared libraries
│   └── Features/                 # Feature modules
└── tests/                        # Unit and integration tests
```

## Quick Start

### Prerequisites

- .NET 9 SDK
- PostgreSQL, Redis, Kafka, RabbitMQ (or use Docker Compose from infrastructure/)

### Run Locally

```bash
# Restore packages
dotnet restore

# Run API
dotnet run --project src/TaskManagement.API

# Run tests
dotnet test
```

### Endpoints

- **API**: http://localhost:5000
- **Swagger**: http://localhost:5000/swagger
- **Health Check**: http://localhost:5000/health

## Development

### Build

```bash
dotnet build
```

### Watch mode

```bash
dotnet watch run --project src/TaskManagement.API
```

### Run tests

```bash
dotnet test --logger "console;verbosity=detailed"
```

## Key Features

- Real-time task updates via SignalR
- Event-driven architecture with Kafka
- Message queuing with RabbitMQ
- Redis caching for performance
- Clean Architecture principles
- CQRS pattern with MediatR
- Comprehensive validation
- Health checks and monitoring