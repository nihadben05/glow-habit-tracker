import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

let pool;

export async function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });
  }
  return pool;
}

export async function initDatabase() {
  try {
    // First, create the database if it doesn't exist
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD || '',
    });

    await connection.execute(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME}`);
    await connection.end();

    // Now create tables
    const pool = await getPool();
    const connection2 = await pool.getConnection();

    // Users table
    await connection2.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(36) PRIMARY KEY,
        email VARCHAR(191) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(100) NOT NULL,
        title VARCHAR(100),
        bio TEXT,
        notifications INT DEFAULT 1,
        dark_mode INT DEFAULT 0,
        weekly_report INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    // Habits table
    await connection2.execute(`
      CREATE TABLE IF NOT EXISTS habits (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        name VARCHAR(100) NOT NULL,
        emoji VARCHAR(10),
        color_value INT,
        freq VARCHAR(50),
        reminder_time VARCHAR(10),
        streak INT DEFAULT 0,
        best_streak INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_habit_user (user_id)
      )
    `);

    // Habit logs table
    await connection2.execute(`
      CREATE TABLE IF NOT EXISTS habit_logs (
        id VARCHAR(36) PRIMARY KEY,
        habit_id VARCHAR(36) NOT NULL,
        user_id VARCHAR(36) NOT NULL,
        date DATE NOT NULL,
        completed INT DEFAULT 0,
        note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_habit_user (user_id),
        INDEX idx_habit_date (date)
      )
    `);

    // Planner tasks table
    await connection2.execute(`
      CREATE TABLE IF NOT EXISTS planner_tasks (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        title VARCHAR(255) NOT NULL,
        subtitle TEXT,
        time VARCHAR(10) DEFAULT '12:00',
        color_value BIGINT DEFAULT 4280391411,
        description TEXT,
        date DATE NOT NULL,
        completed INT DEFAULT 0,
        priority INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX (user_id),
        INDEX (date)
      )
    `);

    // Ensure planner_tasks columns exist when upgrading from older schema
    const [columns] = await connection2.execute(
      'SHOW COLUMNS FROM planner_tasks'
    );
    const existingColumns = columns
        .map((row) => row.Field.toString().toLowerCase());

    if (!existingColumns.includes('subtitle')) {
      await connection2.execute(`ALTER TABLE planner_tasks ADD COLUMN subtitle TEXT`);
    }
    if (!existingColumns.includes('time')) {
      await connection2.execute(`ALTER TABLE planner_tasks ADD COLUMN time VARCHAR(10) DEFAULT '12:00'`);
    }
    if (!existingColumns.includes('color_value')) {
      await connection2.execute(`ALTER TABLE planner_tasks ADD COLUMN color_value BIGINT DEFAULT 4280391411`);
    }

    connection2.release();
    console.log('✓ Database tables created/verified');
  } catch (err) {
    console.error('Database initialization error:', err);
    throw err;
  }
}

export async function query(sql, values) {
  const pool = await getPool();
  const [rows] = await pool.execute(sql, values);
  return rows;
}
