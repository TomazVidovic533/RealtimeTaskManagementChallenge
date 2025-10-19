# Task Management Frontend

Modern React application for real-time task management with SignalR integration.

## Tech Stack

- **React 19** - Latest React with concurrent features
- **TypeScript** - Type-safe development
- **Vite** - Lightning-fast build tool
- **Mantine** - Modern component library (planned)
- **SignalR Client** - Real-time communication (planned)
- **React Query** - Data fetching and caching (planned)

## Project Structure

```
frontend/
├── src/
│   ├── components/      # Reusable components
│   ├── pages/           # Page components
│   ├── hooks/           # Custom React hooks
│   ├── services/        # API and SignalR services
│   ├── store/           # State management
│   └── types/           # TypeScript types
├── public/              # Static assets
└── package.json
```

## Quick Start

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

### Available Scripts

```bash
# Development server (http://localhost:5173)
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

## Development

### Environment Variables

Create a `.env` file in the frontend directory:

```env
VITE_API_URL=http://localhost:5000
VITE_SIGNALR_HUB_URL=http://localhost:5000/hubs/tasks
```

### Key Features (Planned)

- Real-time task updates via SignalR
- Drag-and-drop task management
- Team collaboration features
- Dark mode support
- Responsive design
- Optimistic UI updates
- Offline support

## API Integration

The frontend connects to the backend API at `http://localhost:5000` by default. Make sure the backend is running before starting the frontend development server.
