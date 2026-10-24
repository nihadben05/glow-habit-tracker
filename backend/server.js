import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import authRoutes from './routes/auth.js';
import habitRoutes from './routes/habits.js';
import plannerRoutes from './routes/planner.js';
import { initDatabase } from './utils/database.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

(async () => {
  try {
    await initDatabase();
    console.log('✓ Database initialized');
  } catch (err) {
    console.error('✗ Database initialization failed:', err);
    process.exit(1);
  }
})();

app.use('/api/auth', authRoutes);
app.use('/api/habits', habitRoutes);
app.use('/api/planner', plannerRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`✓ Server running on http://localhost:${PORT}`);
});
