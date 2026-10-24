# Glow: Habit Tracker

Glow is a habit tracking mobile app built with **Flutter**, with a **Node.js / Express** backend and a **MySQL** database. It follows the **MVVM + Repository** pattern, using `Provider` for state management.

The full project presentation is in [`docs/HabitTracker_Presentation.pdf`](docs/HabitTracker_Presentation.pdf) (editable version: [`docs/HabitTracker_Presentation.pptx`](docs/HabitTracker_Presentation.pptx)).

## Features

- Sign up and log in with JWT authentication
- Create, edit and delete habits with an emoji, a colour and a frequency (daily, weekdays, weekends, 3x per week)
- Mark habits as done each day and follow your streaks
- Daily planner for tasks with priorities
- Statistics screen
- Profile with settings
- Local reminder notifications for each habit

## Tech stack

| Part | Technology |
| --- | --- |
| Mobile app | Flutter, Dart, Provider |
| Local storage | SQLite (`sqflite`), `shared_preferences` |
| Notifications | `flutter_local_notifications` |
| Backend | Node.js, Express, `mysql2`, `bcryptjs`, `jsonwebtoken` |
| Database | MySQL |

## Project structure

```
lib/
├── db/         providers and local database
├── models/     Habit, HabitLog, PlannerTask, UserProfile
├── screens/    app screens
├── services/   API client and notifications
├── utils/      theme
└── widgets/    shared widgets
backend/        Express API (routes, auth, database)
docs/           project presentation
test/           unit tests
```

## Getting started

### 1. Backend

1. Start MySQL (XAMPP or WAMP).
2. In the `backend` folder, copy `.env.example` to `.env` and set your values, especially `JWT_SECRET`.
3. Install and run:

```bash
cd backend
npm install
npm start
```

The API runs on `http://localhost:3001`. Check it at `http://localhost:3001/api/health`. The database and tables are created automatically on first start.

### 2. Flutter app

```bash
flutter pub get
flutter run
```

The app reaches the backend through `lib/services/api_service.dart`:

- Android emulator: `http://10.0.2.2:3001/api` (already set)
- Real phone: change `baseUrl` to your computer's local IP address, for example `http://192.168.1.20:3001/api`. The phone and the computer must be on the same Wi-Fi.

### 3. Tests

```bash
flutter test
```

## Supported platforms

Android and iOS. The app uses `sqflite`, which does not run on web or desktop.

## Security notes

- Never commit your `.env` file. Only `.env.example` belongs in the repository.
- Use a long random value for `JWT_SECRET`.
- The app talks to the backend over plain HTTP, which is fine for development. Use HTTPS before publishing the app.
