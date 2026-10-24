# Backend Setup Guide

## Quick Start

1. **Open terminal in the `backend` folder:**
   ```powershell
   cd backend
   ```

2. **Install npm dependencies:**
   ```powershell
   npm install
   ```
   
   This installs:
   - express (web framework)
   - mysql2 (MySQL driver)
   - bcryptjs (password hashing)
   - jsonwebtoken (JWT auth)
   - uuid (ID generation)
   - cors (cross-origin support)
   - dotenv (environment variables)
   - nodemon (auto-reload in dev)

3. **Make sure WAMP MySQL is running:**
   - Open WAMP Control Panel
   - Ensure MySQL service is green/running
   - Default: localhost, port 3306, user: root, no password

4. **Start the server:**
   ```powershell
   npm start
   ```
   
   The server will:
   - Create the `habit_tracker` database if it doesn't exist
   - Create all required tables (users, habits, habit_logs, planner_tasks)
   - Start listening on `http://localhost:3001`

## Testing

Once running, test with:
```bash
curl http://localhost:3001/api/health
```

You should see: `{"status":"OK","timestamp":"..."}`

## What's Next

After confirming the backend is running:

1. Update the Flutter app to use `http://localhost:3001` as the API endpoint
2. Replace local SQLite calls with HTTP calls to the backend API
3. Store the JWT token from login for subsequent requests

## File Structure

```
backend/
├── server.js              # Main server
├── package.json           # Dependencies
├── .env                   # Configuration
├── utils/
│   ├── database.js        # MySQL connection & schema
│   └── auth.js            # JWT & password utilities
└── routes/
    ├── auth.js            # Login/Register endpoints
    ├── habits.js          # Habits CRUD
    └── planner.js         # Planner tasks CRUD
```

## Troubleshooting

- **Connection refused**: Make sure WAMP MySQL is running
- **database.js error**: Check .env file has correct MySQL credentials
- **Port 3001 in use**: Change PORT in .env or kill the process using port 3001
