// server.js - Node.js Backend Server for X Clone
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'your-secret-key-change-this-in-production';

// Middleware
app.use(cors());
app.use(express.json());

// MySQL connection pool
const pool = mysql.createPool({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '',
  database: 'x_clone_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Utility function untuk hash password
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

// Middleware untuk verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// Initialize database tables
async function initializeDatabase() {
  try {
    const connection = await pool.getConnection();
    
    // Create users table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        name VARCHAR(100) NOT NULL,
        bio TEXT,
        location VARCHAR(100),
        website VARCHAR(200),
        profile_image VARCHAR(255),
        banner_image VARCHAR(255),
        is_verified BOOLEAN DEFAULT FALSE,
        follower_count INT DEFAULT 0,
        following_count INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    // Create posts table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        content TEXT NOT NULL,
        image_url VARCHAR(255),
        like_count INT DEFAULT 0,
        retweet_count INT DEFAULT 0,
        reply_count INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    // Create other tables...
    await connection.query(`
      CREATE TABLE IF NOT EXISTS likes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        post_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_like (user_id, post_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS follows (
        id INT AUTO_INCREMENT PRIMARY KEY,
        follower_id INT NOT NULL,
        following_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_follow (follower_id, following_id),
        FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    // Insert sample data if not exists
    const [userCheck] = await connection.query('SELECT COUNT(*) as count FROM users');
    if (userCheck[0].count === 0) {
      await insertSampleData(connection);
    }

    connection.release();
    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization error:', error);
  }
}

async function insertSampleData(connection) {
  try {
    // Insert sample users
    const users = [
      ['xoxo900', 'user@example.com', hashPassword('lightborn90@'), 'Mis X', 'Flutter Developer | UI/UX Enthusiast', 'Makassar, Indonesia', 'flutter.dev', 'images/me.jpg', 'images/profile_banner.jpg', true, 120, 245],
      ['starfess', 'starfess@example.com', hashPassword('password123'), 'Starfess || CEK PINNED UNTUK KIRIM MENFESS', 'Anonymous confession platform', 'Indonesia', 'starfess.com', 'images/profil1.jpg', 'images/default_banner.jpg', true, 50000, 10],
      ['IndoPopBase', 'indopopbase@example.com', hashPassword('password123'), 'Indonesian Pop Base', 'Your source for Indonesian pop culture news', 'Jakarta, Indonesia', 'indopopbase.com', 'images/profil2.jpg', 'images/default_banner.jpg', true, 125000, 500],
      ['tanyakanrl', 'tanyarl@example.com', hashPassword('password123'), 'TanyarI💚', 'Ask me anything about life!', 'Bandung, Indonesia', 'tanyarl.id', 'images/profil3.jpg', 'images/default_banner.jpg', true, 75000, 1200],
      ['westenthu', 'west@example.com', hashPassword('password123'), 'Western Enthusiast', 'UTBK Tutor | English Teacher | Movie Lover', 'Surabaya, Indonesia', 'westernenthu.com', 'images/profil4.jpg', 'images/default_banner.jpg', false, 15000, 800],
      ['johndoe', 'john@example.com', hashPassword('password123'), 'John Doe', 'Software Engineer | Tech Enthusiast', 'San Francisco, CA', 'johndoe.dev', 'images/user1.jpg', 'images/default_banner.jpg', false, 2500, 1200],
      ['flutterdev', 'flutter@google.com', hashPassword('password123'), 'Flutter', 'Build apps for any screen 📱💻🌐', 'Mountain View, CA', 'flutter.dev', 'images/user2.jpg', 'images/default_banner.jpg', true, 500000, 50]
    ];

    for (const user of users) {
      await connection.query(
        'INSERT INTO users (username, email, password_hash, name, bio, location, website, profile_image, banner_image, is_verified, follower_count, following_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        user
      );
    }

    // Insert sample posts
    const posts = [
      [2, 'Kepo dong idol kalian pernah viral karena apa guys?😭\nViral in a positive way ya yorobun. Buat seru-seruan aja, pengen kenal kehidupan fandom lain wkwk\n-star.', null, 9000, 745, 520],
      [3, 'Show your now playing 🎵', null, 930, 526, 751],
      [4, 'buat yang main semua app sosmed, bener gak gambar ini? 😅 yang cuma main X tidak usah menjawab. 💚', 'images/postingan1.jpg', 21000, 1000, 728],
      [5, 'Kalau Belly endingnya sama Conrad, saya Nazar\n- share 3 paket soal latihan UTBK PU/PM gratis di gdrive\n- membuka kelas privat toefl/ielts gratis 3 pertemuan untuk 3 org\n- Membagikan materi biologi SMA kelas XII gratis untuk angkt 2026\nyg mau silahkan ya wst', 'images/postingan2.jpg', 5000, 996, 584],
      [1, 'Excited to start learning Flutter! 🚀 #FlutterDev', null, 45, 12, 5],
      [1, 'Just published my first Flutter app on Play Store. Check it out! #Flutter #MobileApp', 'images/flutter_app.jpg', 87, 23, 14],
      [7, 'Introducing the latest features in Flutter 3.0! Check out our blog for more details.', null, 1253, 421, 89]
    ];

    for (const post of posts) {
      await connection.query(
        'INSERT INTO posts (user_id, content, image_url, like_count, retweet_count, reply_count) VALUES (?, ?, ?, ?, ?, ?)',
        post
      );
    }

    console.log('Sample data inserted successfully');
  } catch (error) {
    console.error('Error inserting sample data:', error);
  }
}

// AUTH ENDPOINTS

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password required' });
    }

    const passwordHash = hashPassword(password);
    const [users] = await pool.query(
      'SELECT * FROM users WHERE username = ? AND password_hash = ?',
      [username, passwordHash]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    const token = jwt.sign({ userId: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name,
        bio: user.bio,
        location: user.location,
        website: user.website,
        profile_image: user.profile_image,
        banner_image: user.banner_image,
        is_verified: user.is_verified,
        follower_count: user.follower_count,
        following_count: user.following_count,
        created_at: user.created_at,
        updated_at: user.updated_at
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password, name } = req.body;
    
    if (!username || !email || !password || !name) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Check if user already exists
    const [existingUsers] = await pool.query(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [username, email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({ error: 'Username or email already exists' });
    }

    const passwordHash = hashPassword(password);
    const [result] = await pool.query(
      'INSERT INTO users (username, email, password_hash, name) VALUES (?, ?, ?, ?)',
      [username, email, passwordHash, name]
    );

    const [newUsers] = await pool.query('SELECT * FROM users WHERE id = ?', [result.insertId]);
    const user = newUsers[0];

    const token = jwt.sign({ userId: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name,
        bio: user.bio,
        location: user.location,
        website: user.website,
        profile_image: user.profile_image,
        banner_image: user.banner_image,
        is_verified: user.is_verified,
        follower_count: user.follower_count,
        following_count: user.following_count,
        created_at: user.created_at,
        updated_at: user.updated_at
      },
      token
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST ENDPOINTS

// Get posts with user info
app.get('/api/posts', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const [posts] = await pool.query(`
      SELECT p.*, u.username, u.name, u.profile_image, u.is_verified 
      FROM posts p 
      JOIN users u ON p.user_id = u.id 
      ORDER BY p.created_at DESC 
      LIMIT ? OFFSET ?
    `, [limit, offset]);

    res.json({
      success: true,
      posts
    });
  } catch (error) {
    console.error('Get posts error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create post
app.post('/api/posts', authenticateToken, async (req, res) => {
  try {
    const { content, image_url } = req.body;
    const userId = req.user.userId;

    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }

    const [result] = await pool.query(
      'INSERT INTO posts (user_id, content, image_url) VALUES (?, ?, ?)',
      [userId, content, image_url || null]
    );

    const [posts] = await pool.query(`
      SELECT p.*, u.username, u.name, u.profile_image, u.is_verified 
      FROM posts p 
      JOIN users u ON p.user_id = u.id 
      WHERE p.id = ?
    `, [result.insertId]);

    res.status(201).json({
      success: true,
      post: posts[0]
    });
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Like/Unlike post
app.post('/api/posts/:postId/like', authenticateToken, async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const userId = req.user.userId;

    // Check if already liked
    const [existingLikes] = await pool.query(
      'SELECT id FROM likes WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );

    if (existingLikes.length > 0) {
      // Unlike
      await pool.query('DELETE FROM likes WHERE user_id = ? AND post_id = ?', [userId, postId]);
      await pool.query('UPDATE posts SET like_count = like_count - 1 WHERE id = ?', [postId]);
      
      res.json({ success: true, liked: false });
    } else {
      // Like
      await pool.query('INSERT INTO likes (user_id, post_id) VALUES (?, ?)', [userId, postId]);
      await pool.query('UPDATE posts SET like_count = like_count + 1 WHERE id = ?', [postId]);
      
      res.json({ success: true, liked: true });
    }
  } catch (error) {
    console.error('Like post error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// USER ENDPOINTS

// Get user by ID
app.get('/api/users/:userId', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    
    const [users] = await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    res.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name,
        bio: user.bio,
        location: user.location,
        website: user.website,
        profile_image: user.profile_image,
        banner_image: user.banner_image,
        is_verified: user.is_verified,
        follower_count: user.follower_count,
        following_count: user.following_count,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Follow/Unfollow user
app.post('/api/users/:userId/follow', authenticateToken, async (req, res) => {
  try {
    const followingId = parseInt(req.params.userId);
    const followerId = req.user.userId;

    if (followerId === followingId) {
      return res.status(400).json({ error: 'Cannot follow yourself' });
    }

    // Check if already following
    const [existingFollows] = await pool.query(
      'SELECT id FROM follows WHERE follower_id = ? AND following_id = ?',
      [followerId, followingId]
    );

    if (existingFollows.length > 0) {
      // Unfollow
      await pool.query('DELETE FROM follows WHERE follower_id = ? AND following_id = ?', [followerId, followingId]);
      await pool.query('UPDATE users SET following_count = following_count - 1 WHERE id = ?', [followerId]);
      await pool.query('UPDATE users SET follower_count = follower_count - 1 WHERE id = ?', [followingId]);
      
      res.json({ success: true, following: false });
    } else {
      // Follow
      await pool.query('INSERT INTO follows (follower_id, following_id) VALUES (?, ?)', [followerId, followingId]);
      await pool.query('UPDATE users SET following_count = following_count + 1 WHERE id = ?', [followerId]);
      await pool.query('UPDATE users SET follower_count = follower_count + 1 WHERE id = ?', [followingId]);
      
      res.json({ success: true, following: true });
    }
  } catch (error) {
    console.error('Follow user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'X Clone API Server is running',
    timestamp: new Date().toIso8601String()
  });
});

// Start server
async function startServer() {
  await initializeDatabase();
  
  app.listen(PORT, () => {
    console.log(`🚀 X Clone API Server running on http://localhost:${PORT}`);
    console.log(`📖 API Documentation:`);
    console.log(`   POST /api/auth/login - Login user`);
    console.log(`   POST /api/auth/register - Register user`);
    console.log(`   GET  /api/posts - Get posts`);
    console.log(`   POST /api/posts - Create post`);
    console.log(`   POST /api/posts/:id/like - Like/unlike post`);
    console.log(`   GET  /api/users/:id - Get user info`);
    console.log(`   POST /api/users/:id/follow - Follow/unfollow user`);
    console.log(`   GET  /api/health - Health check`);
  });
}

startServer().catch(console.error);