# Essential .NET Commands

## Project Creation Commands

Run these when setting up new projects:

```bash
# Create a new solution file
dotnet new sln -n TaskManagementAPI

# Create a class library (for domain, application, feature code)
dotnet new classlib -n ProjectName -o src/path/

# Create a Web API project (for REST endpoints)
dotnet new webapi -n ProjectName -o src/path/

# Create a test project (xUnit is modern and flexible)
dotnet new xunit -n ProjectName.Tests -o tests/path/
```

## Project Management Commands

These connect projects together:

```bash
# Add a project to the solution
dotnet sln add src/Features/Tasks/Tasks.csproj

# Add a reference from one project to another
# Run this FROM the referencing project directory
dotnet add reference ../path/ProjectName.csproj

# Remove a project from the solution
dotnet sln remove src/Features/Tasks/Tasks.csproj
```

## Build & Run Commands

Essential for development:

```bash
# Compile everything and check for errors
dotnet build

# Clean build (removes previous build artifacts)
dotnet clean && dotnet build

# Run the API server
dotnet run --project src/TaskManagement.API/

# Run tests
dotnet test

# Run tests with coverage
dotnet test /p:CollectCoverage=true

# Publish for production
dotnet publish -c Release
```

## Database Commands (Entity Framework Core)

These manage database schema and migrations:

```bash
# Create a new migration (after changing entities)
# Run from src/TaskManagement.API/ directory
dotnet ef migrations add MigrationName --project ../TaskManagement.Shared/

# Remove the last migration
dotnet ef migrations remove

# Update database to latest migration
dotnet ef database update

# List all migrations
dotnet ef migrations list
```

## NuGet Package Commands

Managing dependencies:

```bash
# Add a package to current project
dotnet add package PackageName

# Add a specific version
dotnet add package PackageName --version 1.0.0

# Remove a package
dotnet remove package PackageName

# Update all packages
dotnet package update
```

## Useful Development Shortcuts

```bash
# Format code (install dotnet-format first)
dotnet format

# Check for outdated packages
dotnet outdated

# Clean up global usings
dotnet format --verify-no-changes
```

## Typical Workflow

```bash
# 1. Make changes to domain/application code
# 2. Compile to check for errors
dotnet build

# 3. If database entities changed, create migration
dotnet ef migrations add AddNewFeature

# 4. Update database
dotnet ef database update

# 5. Run tests
dotnet test

# 6. Run the app
dotnet run --project src/TaskManagement.API/
```

---

Install `dotnet-format`, `dotnet-outdated`, and `dotnet-ef` as global tools:
```bash
dotnet tool install -g dotnet-format
dotnet tool install -g dotnet-outdated
dotnet tool install -g dotnet-ef
```
