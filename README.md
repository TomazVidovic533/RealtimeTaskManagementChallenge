# Real-Time Task Management API

## What Is This?

A task management system where multiple users can work on tasks together in real-time. When one user creates or updates a task, everyone sees the changes instantlyno page refresh needed.

## Why Build This?

To demonstrate how to combine multiple modern technologies into a single cohesive system:

- **Real-time communication** using WebSockets (SignalR)
- **Event-driven architecture** with Kafka and RabbitMQ
- **Distributed caching** with Redis
- **Clean code** with .NET and Domain-Driven Design
- **React frontend** connected to .NET backend

## Tech Stack

- **.NET 9** - Backend framework
- **PostgreSQL** - Database
- **Redis** - Caching and real-time backplane
- **SignalR** - WebSocket for instant updates
- **Kafka** - Event streaming
- **RabbitMQ** - Message queues
- **React** - Frontend UI
- **Docker** - Containerization

## How It Works (Theory)

1. User creates a task ’ API receives request
2. Domain logic processes it ’ Creates a domain event
3. Event published ’ Goes to Kafka (for analytics) and RabbitMQ (for routing)
4. SignalR broadcasts ’ All connected browsers get the update instantly
5. React updates UI ’ User sees changes in real-time

## Running It

```bash
# Start all services (PostgreSQL, Redis, Kafka, RabbitMQ)
docker-compose up -d

# Run database migrations
dotnet ef database update

# Start the API
dotnet run --project src/TaskManagement.API/

# Start React frontend (separate terminal)
cd react-app && npm start
```

## Goal

Show that you understand:
- How to architect a large system
- How to make things work in real-time
- How to handle events at scale
- How to keep code clean and maintainable
- How different technologies work together

This is a **portfolio project** demonstrating senior-level .NET and distributed systems knowledge.
