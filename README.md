# FitnessHelper

A comprehensive fitness tracking solution with a Spring Boot backend and a SwiftUI iOS app.

## Project Structure
- `backend/`: Java Spring Boot server.
- `FitnessHelper-iOS/`: iOS application built with SwiftUI.

## Backend
The backend server provides a REST API for tracking workouts and diet entries.

### Prerequisites
- Java 17 or higher
- Maven (optional, `mvnw` wrapper included)
- Docker and Docker Compose

### Running the Database
Before starting the backend, start the PostgreSQL database using Docker Compose:
```bash
docker-compose up -d
```

### Running the backend
```bash
./mvnw spring-boot:run
```
The server will start on `http://localhost:8080`.

## iOS App
The iOS app allows you to log workouts and diet entries directly from your iPhone.

### Prerequisites
- macOS with Xcode 15+
- iOS 17.0+ (Simulator or Physical Device)

### Setup
1. Open the `FitnessHelper-iOS/FitnessHelper-iOS.xcodeproj` file in Xcode.
2. Ensure the backend is running at `http://localhost:8080`.
3. If running on a physical device, update the `baseURL` in `NetworkManager.swift` to your machine's local IP address.
4. Select a Simulator or Physical Device in the Xcode scheme selector.
5. Build and run the app (Cmd + R).

## Features
- Track workouts and sets.
- Track diet entries (calories, macros).
- Sync data between iOS and Backend via REST API.
- PostgreSQL database with Docker Compose for persistent storage.

### Verifying the Database
You can verify the data in the PostgreSQL database using the following command:
```bash
docker exec -it fitness-db psql -U fitnessuser -d fitnessdb -c "SELECT * FROM workouts;"
```
And for diet entries:
```bash
docker exec -it fitness-db psql -U fitnessuser -d fitnessdb -c "SELECT * FROM diet_entries;"
```

### Docker Port Mapping
In Docker Desktop, you should see the `fitness-db` container. The port mapping is `5433:5432`. 
- **5432** is the internal port inside the container.
- **5433** is the external port on your machine (host).
The backend connects to `localhost:5433`.
