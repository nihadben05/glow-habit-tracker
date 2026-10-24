import express from 'express';
import { v4 as uuidv4 } from 'uuid';
import { query } from '../utils/database.js';
import { authMiddleware } from '../utils/auth.js';

const router = express.Router();

router.get('/:date', authMiddleware, async (req, res) => {
  try {
    const { date } = req.params;
    const tasks = await query('SELECT * FROM planner_tasks WHERE user_id = ? AND date = ? ORDER BY priority DESC', [req.userId, date]);
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', authMiddleware, async (req, res) => {
  try {
    const { title, description, date, priority, subtitle, time, colorValue } = req.body;

    if (!title || !date) {
      return res.status(400).json({ error: 'Title and date are required' });
    }

    const taskId = uuidv4();
    await query(
      'INSERT INTO planner_tasks (id, user_id, title, subtitle, time, color_value, description, date, priority) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [taskId, req.userId, title, subtitle || description, time || '12:00', colorValue || 4280391411, description, date, priority || 0]
    );

    res.json({
      id: taskId,
      user_id: req.userId,
      title,
      subtitle: subtitle || description,
      time: time || '12:00',
      color_value: colorValue || 4280391411,
      description,
      date,
      priority: priority || 0,
      completed: 0
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, subtitle, time, colorValue, description, completed, priority } = req.body;

    await query(
      'UPDATE planner_tasks SET title = ?, subtitle = ?, time = ?, color_value = ?, description = ?, completed = ?, priority = ? WHERE id = ? AND user_id = ?',
      [title, subtitle, time, colorValue, description, completed, priority, id, req.userId]
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    await query('DELETE FROM planner_tasks WHERE id = ? AND user_id = ?', [id, req.userId]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
