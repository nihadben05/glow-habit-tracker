# Habit Tracker Backend

Node.js/Express backend for Habit Tracker app with MySQL database.

## Setup

### Prerequisites
- Node.js (v16+)
- MySQL (WAMP)

### Installation

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Ensure `.env` is configured with your MySQL details:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=habit_tracker
   PORT=3001
   JWT_SECRET=change_this_in_production
   ```

4. Start the server:
   ```bash
   npm start
   ```
   Or for development with auto-reload:
   ```bash
   npm run dev
   ```

The server will start on `http://localhost:3001`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Habits
- `GET /api/habits` - Get all habits
- `POST /api/habits` - Create habit
- `PUT /api/habits/:id` - Update habit
- `DELETE /api/habits/:id` - Delete habit
- `GET /api/habits/logs/:date` - Get logs for date
- `POST /api/habits/logs/toggle` - Toggle habit completion

### Planner
- `GET /api/planner/:date` - Get tasks for date
- `POST /api/planner` - Create task
- `PUT /api/planner/:id` - Update task
- `DELETE /api/planner/:id` - Delete task

## Database Schema

Tables created automatically on startup:
- `users` - User accounts
- `habits` - Habit definitions
- `habit_logs` - Daily habit completion logs
- `planner_tasks` - Planner tasks

## Next Steps

1. Start the backend server
2. Update Flutter app to use this API instead of local SQLite
3. Configure API endpoint in Flutter app
