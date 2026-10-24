import express from 'express';
import { v4 as uuidv4 } from 'uuid';
import { query } from '../utils/database.js';
import { hashPassword, verifyPassword, generateToken, authMiddleware } from '../utils/auth.js';

const router = express.Router();

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // Check if user already exists
    const existing = await query('SELECT id FROM users WHERE email = ?', [email.toLowerCase()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const userId = uuidv4();
    const hashedPassword = await hashPassword(password);

    await query(
      'INSERT INTO users (id, email, password, name) VALUES (?, ?, ?, ?)',
      [userId, email.toLowerCase(), hashedPassword, name]
    );

    const token = generateToken(userId, email);
    res.json({ token, userId, name, email });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const users = await query('SELECT * FROM users WHERE email = ?', [email.toLowerCase()]);
    if (users.length === 0) {
      return res.status(400).json({ error: 'User not found' });
    }

    const user = users[0];
    const validPassword = await verifyPassword(password, user.password);
    if (!validPassword) {
      return res.status(400).json({ error: 'Incorrect password' });
    }

    const token = generateToken(user.id, user.email);
    res.json({
      token,
      userId: user.id,
      name: user.name,
      email: user.email,
      title: user.title,
      bio: user.bio,
      notifications: user.notifications,
      darkMode: user.dark_mode,
      weeklyReport: user.weekly_report,
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get current user
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const users = await query('SELECT * FROM users WHERE id = ?', [req.userId]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    res.json({ userId: user.id, name: user.name, email: user.email });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
