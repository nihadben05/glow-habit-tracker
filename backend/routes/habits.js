import express from 'express';
import { v4 as uuidv4 } from 'uuid';
import { query } from '../utils/database.js';
import { authMiddleware } from '../utils/auth.js';

const router = express.Router();

router.get('/', authMiddleware, async (req, res) => {
  try {
    const habits = await query('SELECT * FROM habits WHERE user_id = ? ORDER BY created_at ASC', [req.userId]);
    res.json(habits);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', authMiddleware, async (req, res) => {
  try {
    const { name, emoji, colorValue, freq, reminderTime } = req.body;

    if (!name || !emoji || !freq) {
      return res.status(400).json({ error: 'Name, emoji, and freq are required' });
    }

    const habitId = uuidv4();
    await query(
      'INSERT INTO habits (id, user_id, name, emoji, color_value, freq, reminder_time) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [habitId, req.userId, name, emoji, colorValue, freq, reminderTime]
    );

    const habits = await query('SELECT * FROM habits WHERE id = ?', [habitId]);
    res.json(habits[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, emoji, colorValue, freq, reminderTime } = req.body;

    await query(
      'UPDATE habits SET name = ?, emoji = ?, color_value = ?, freq = ?, reminder_time = ? WHERE id = ? AND user_id = ?',
      [name, emoji, colorValue, freq, reminderTime, id, req.userId]
    );

    const habits = await query('SELECT * FROM habits WHERE id = ?', [id]);
    res.json(habits[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    await query('DELETE FROM habits WHERE id = ? AND user_id = ?', [id, req.userId]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/logs/:date', authMiddleware, async (req, res) => {
  try {
    const { date } = req.params;
    const logs = await query(
      'SELECT * FROM habit_logs WHERE user_id = ? AND date = ?',
      [req.userId, date]
    );
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/logs/toggle', authMiddleware, async (req, res) => {
  try {
    const { habitId, date, completed } = req.body;

    const logId = uuidv4();
    await query(
      'INSERT INTO habit_logs (id, habit_id, user_id, date, completed) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE completed = ?, updated_at = NOW()',
      [logId, habitId, req.userId, date, completed, completed]
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
