const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Middleware para parsear JSON y servir archivos estáticos
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Configuración de la conexión a PostgreSQL usando variables de entorno
const pool = new Pool({
  user: process.env.DB_USER || 'admin',
  host: process.env.DB_HOST,
  database: process.env.DB_NAME || 'postgres',
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

// Inicializar la tabla si no existe
const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        content VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log("Tabla 'messages' lista.");
  } catch (err) {
    console.error("Error inicializando la base de datos:", err);
  }
};
initDB();

// Ruta para obtener los mensajes y el entorno actual
app.get('/api/info', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM messages ORDER BY created_at DESC LIMIT 10');
    res.json({
      environment: process.env.APP_ENV || 'local',
      messages: result.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Ruta para guardar un nuevo mensaje
app.post('/api/messages', async (req, res) => {
  try {
    const { content } = req.body;
    if (!content) return res.status(400).json({ error: 'El contenido es requerido' });
    
    await pool.query('INSERT INTO messages (content) VALUES ($1)', [content]);
    res.status(201).json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`App corriendo en el puerto ${port} en modo ${process.env.APP_ENV}`);
});