# Project Structure & Features

## Directory Structure

```
TaskManagementAPI/
├── src/
│   ├── TaskManagement.API/
│   │   ├── Program.cs
│   │   ├── appsettings.json
│   │   └── Dockerfile
│   │
│   ├── TaskManagement.Shared/
│   │   ├── Domain/
│   │   │   ├── Common/
│   │   │   │   ├── Entity.cs
│   │   │   │   ├── AggregateRoot.cs
│   │   │   │   ├── DomainEvent.cs
│   │   │   │   ├── ValueObject.cs
│   │   │   │   └── Result.cs
│   │   │   ├── Interfaces/
│   │   │   │   ├── IRepository.cs
│   │   │   │   ├── IUnitOfWork.cs
│   │   │   │   ├── IEventPublisher.cs
│   │   │   │   └── ISpecification.cs
│   │   │   └── Exceptions/
│   │   │       ├── DomainException.cs
│   │   │       └── BusinessRuleException.cs
│   │   ├── Infrastructure/
│   │   │   ├── Persistence/
│   │   │   │   ├── AppDbContext.cs
│   │   │   │   ├── UnitOfWork.cs
│   │   │   │   └── Configurations/
│   │   │   ├── Caching/
│   │   │   │   ├── CacheService.cs
│   │   │   │   ├── CacheKeyFactory.cs
│   │   │   │   └── DistributedCacheExtensions.cs
│   │   │   ├── Messaging/
│   │   │   │   ├── Kafka/
│   │   │   │   ├── RabbitMQ/
│   │   │   │   └── InMemory/
│   │   │   ├── Logging/
│   │   │   │   ├── LoggingConfiguration.cs
│   │   │   │   └── CorrelationIdMiddleware.cs
│   │   │   └── SignalR/
│   │   │       ├── SignalROptions.cs
│   │   │       └── SignalRExtensions.cs
│   │   ├── Authentication/
│   │   │   ├── JwtTokenService.cs
│   │   │   └── IdentityContext.cs
│   │   └── Common/
│   │       ├── Extensions/
│   │       ├── Middleware/
│   │       ├── Constants/
│   │       └── Utilities/
│   │
│   └── Features/
│       ├── Tasks/
│       │   ├── Domain/
│       │   │   ├── Entities/
│       │   │   ├── ValueObjects/
│       │   │   ├── Events/
│       │   │   ├── Interfaces/
│       │   │   └── Specifications/
│       │   ├── Application/
│       │   │   ├── Commands/
│       │   │   ├── Queries/
│       │   │   ├── DTOs/
│       │   │   ├── Mappers/
│       │   │   ├── Services/
│       │   │   └── EventHandlers/
│       │   ├── Infrastructure/
│       │   │   ├── Persistence/
│       │   │   ├── Services/
│       │   │   └── Cache/
│       │   ├── Api/
│       │   ├── Events/
│       │   ├── Notifications/
│       │   ├── DependencyInjection.cs
│       │   └── Tests/
│       │
│       ├── Users/
│       │   ├── Domain/
│       │   ├── Application/
│       │   ├── Infrastructure/
│       │   ├── Api/
│       │   ├── Events/
│       │   ├── Notifications/
│       │   ├── DependencyInjection.cs
│       │   └── Tests/
│       │
│       ├── Teams/
│       │   ├── Domain/
│       │   ├── Application/
│       │   ├── Infrastructure/
│       │   ├── Api/
│       │   ├── Events/
│       │   ├── Notifications/
│       │   ├── DependencyInjection.cs
│       │   └── Tests/
│       │
│       ├── Comments/
│       │   ├── Domain/
│       │   ├── Application/
│       │   ├── Infrastructure/
│       │   ├── Api/
│       │   ├── Events/
│       │   ├── Notifications/
│       │   ├── DependencyInjection.cs
│       │   └── Tests/
│       │
│       └── Notifications/
│           ├── Domain/
│           ├── Application/
│           ├── Infrastructure/
│           ├── Api/
│           ├── DependencyInjection.cs
│           └── Tests/
│
└── tests/
    ├── TaskManagement.Integration.Tests/
    └── Features/
        ├── Tasks.Tests/
        ├── Users.Tests/
        ├── Teams.Tests/
        ├── Comments.Tests/
        └── Notifications.Tests/
```

---

## Features to Implement

### 1. **Tasks** 📋
- Create, read, update, delete tasks
- Assign tasks to users/teams
- Set priority and due dates
- Track task status (Todo, InProgress, Completed)
- Task filtering and sorting
- Full-text search on tasks
- Bulk operations

### 2. **Users** 👤
- User registration and login
- JWT authentication
- User profiles and preferences
- Role-based access control (Admin, Manager, User)
- Team membership
- Password hashing and validation

### 3. **Teams** 👥
- Create and manage teams
- Add/remove team members
- Team-based permissions
- Team invitations
- Team statistics and overview

### 4. **Comments** 💬
- Add comments to tasks
- Edit and delete comments
- Comment threads/replies
- User mentions in comments
- Comment notifications
- Comment history

### 5. **Notifications** 🔔
- Real-time notifications via SignalR
- Task assignment notifications
- Comment mention notifications
- Deadline reminders
- Status change notifications
- Notification preferences
- Notification history and archive
- In-app notifications

---

## Technology Stack

- **.NET 9** - Latest framework
- **ASP.NET Core Web API** - REST endpoints
- **Entity Framework Core** - ORM with PostgreSQL
- **SignalR** - Real-time WebSocket communication
- **PostgreSQL** - Primary database
- **Redis** - Caching & session storage
- **Kafka** - High-volume event streaming
- **RabbitMQ** - Reliable event delivery
- **MediatR** - CQRS pattern
- **FluentValidation** - Input validation
- **AutoMapper** - Object mapping
- **Serilog** - Structured logging
- **xUnit** - Testing framework
- **Moq** - Mocking
- **TestContainers** - Integration testing
- **Docker** - Containerization

---

## Architecture Pattern

- **Vertical Slice Features** - Each feature is self-contained
- **Clean Architecture** - Domain → Application → Infrastructure → API
- **Domain-Driven Design** - Focus on business logic
- **Event-Driven** - Features communicate via events
- **CQRS** - Separate read and write operations
- **Repository Pattern** - Data access abstraction
- **Dependency Injection** - Loose coupling
