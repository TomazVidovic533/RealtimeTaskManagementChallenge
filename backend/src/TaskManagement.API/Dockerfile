FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src

COPY ["src/TaskManagement.API/TaskManagement.API.csproj", "src/TaskManagement.API/"]
COPY ["src/TaskManagement.Shared/TaskManagement.Shared.csproj", "src/TaskManagement.Shared/"]
COPY ["src/Features/Tasks/Tasks.csproj", "src/Features/Tasks/"]
COPY ["src/Features/Users/Users.csproj", "src/Features/Users/"]
COPY ["src/Features/Teams/Teams.csproj", "src/Features/Teams/"]
COPY ["src/Features/Comments/Comments.csproj", "src/Features/Comments/"]
COPY ["src/Features/Notifications/Notifications.csproj", "src/Features/Notifications/"]

RUN dotnet restore "src/TaskManagement.API/TaskManagement.API.csproj"

COPY src/ ./src/

RUN dotnet build "src/TaskManagement.API/TaskManagement.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "src/TaskManagement.API/TaskManagement.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
WORKDIR /app

COPY --from=publish /app/publish .

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["dotnet", "TaskManagement.API.dll"]
