// server.js - Complete Node.js Backend Server for X Clone
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;

const app = express();
const PORT = 3000;
const JWT_SECRET = 'your-secret-key-change-this-in-production';

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

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

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    try {
      const userId = req.user.userId;
      const uploadDir = path.join(__dirname, 'uploads', 'users', userId.toString());
      
      // Create directory if it doesn't exist
      await fs.mkdir(uploadDir, { recursive: true });
      cb(null, uploadDir);
    } catch (error) {
      cb(error);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

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

    // Create likes table
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

    // Create follows table
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

    // Create replies table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS replies (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        post_id INT NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    `);

    // Create retweets table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS retweets (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        post_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_retweet (user_id, post_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    `);

    // Create bookmarks table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS bookmarks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        post_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_bookmark (user_id, post_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    `);

    // Create notifications table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        type ENUM('like', 'retweet', 'follow', 'mention', 'reply') NOT NULL,
        actor_id INT NOT NULL,
        post_id INT DEFAULT NULL,
        content TEXT DEFAULT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    `);

    // Create messages table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        receiver_id INT NOT NULL,
        content TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
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
      ['xoxo900', 'user@example.com', hashPassword('lightborn90@'), 'Mis X', 'Flutter Developer | UI/UX Enthusiast', 'Makassar, Indonesia', 'flutter.dev', 'uploads/users/1/profile-default.jpg', 'uploads/users/1/banner-default.jpg', true, 120, 245],
      ['starfess', 'starfess@example.com', hashPassword('password123'), 'Starfess || CEK PINNED UNTUK KIRIM MENFESS', 'Anonymous confession platform', 'Indonesia', 'starfess.com', 'uploads/users/2/profile-default.jpg', 'uploads/users/2/banner-default.jpg', true, 50000, 10],
      ['IndoPopBase', 'indopopbase@example.com', hashPassword('password123'), 'Indonesian Pop Base', 'Your source for Indonesian pop culture news', 'Jakarta, Indonesia', 'indopopbase.com', 'uploads/users/3/profile-default.jpg', 'uploads/users/3/banner-default.jpg', true, 125000, 500],
      ['tanyakanrl', 'tanyarl@example.com', hashPassword('password123'), 'TanyarI💚', 'Ask me anything about life!', 'Bandung, Indonesia', 'tanyarl.id', 'uploads/users/4/profile-default.jpg', 'uploads/users/4/banner-default.jpg', true, 75000, 1200],
      ['westenthu', 'west@example.com', hashPassword('password123'), 'Western Enthusiast', 'UTBK Tutor | English Teacher | Movie Lover', 'Surabaya, Indonesia', 'westernenthu.com', 'uploads/users/5/profile-default.jpg', 'uploads/users/5/banner-default.jpg', false, 15000, 800],
      ['johndoe', 'john@example.com', hashPassword('password123'), 'John Doe', 'Software Engineer | Tech Enthusiast', 'San Francisco, CA', 'johndoe.dev', 'uploads/users/6/profile-default.jpg', 'uploads/users/6/banner-default.jpg', false, 2500, 1200],
      ['flutterdev', 'flutter@google.com', hashPassword('password123'), 'Flutter', 'Build apps for any screen 📱💻🌐', 'Mountain View, CA', 'flutter.dev', 'uploads/users/7/profile-default.jpg', 'uploads/users/7/banner-default.jpg', true, 500000, 50]
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
      [4, 'buat yang main semua app sosmed, bener gak gambar ini? 😅 yang cuma main X tidak usah menjawab. 💚', 'uploads/posts/postingan1.jpg', 21000, 1000, 728],
      [5, 'Kalau Belly endingnya sama Conrad, saya Nazar\n- share 3 paket soal latihan UTBK PU/PM gratis di gdrive\n- membuka kelas privat toefl/ielts gratis 3 pertemuan untuk 3 org\n- Membagikan materi biologi SMA kelas XII gratis untuk angkt 2026\nyg mau silahkan ya wst', 'uploads/posts/postingan2.jpg', 5000, 996, 584],
      [1, 'Excited to start learning Flutter! 🚀 #FlutterDev', null, 45, 12, 5],
      [1, 'Just published my first Flutter app on Play Store. Check it out! #Flutter #MobileApp', 'uploads/posts/flutter_app.jpg', 87, 23, 14],
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

// =================== AUTH ENDPOINTS ===================

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

// =================== FILE UPLOAD ENDPOINTS ===================

// Upload profile image
app.post('/api/upload/profile-image', authenticateToken, upload.single('profileImage'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const userId = req.user.userId;
    const imagePath = `uploads/users/${userId}/${req.file.filename}`;

    // Update user profile image in database
    await pool.query('UPDATE users SET profile_image = ? WHERE id = ?', [imagePath, userId]);

    res.json({
      success: true,
      image_url: imagePath
    });
  } catch (error) {
    console.error('Profile image upload error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Upload banner image
app.post('/api/upload/banner-image', authenticateToken, upload.single('bannerImage'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const userId = req.user.userId;
    const imagePath = `uploads/users/${userId}/${req.file.filename}`;

    // Update user banner image in database
    await pool.query('UPDATE users SET banner_image = ? WHERE id = ?', [imagePath, userId]);

    res.json({
      success: true,
      image_url: imagePath
    });
  } catch (error) {
    console.error('Banner image upload error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Upload post image
app.post('/api/upload/post-image', authenticateToken, upload.single('postImage'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const userId = req.user.userId;
    const imagePath = `uploads/users/${userId}/${req.file.filename}`;

    res.json({
      success: true,
      image_url: imagePath
    });
  } catch (error) {
    console.error('Post image upload error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== POST ENDPOINTS ===================

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

// Get user posts
app.get('/api/users/:userId/posts', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const [posts] = await pool.query(`
      SELECT p.*, u.username, u.name, u.profile_image, u.is_verified 
      FROM posts p 
      JOIN users u ON p.user_id = u.id 
      WHERE p.user_id = ?
      ORDER BY p.created_at DESC 
      LIMIT ? OFFSET ?
    `, [userId, limit, offset]);

    res.json({
      success: true,
      posts
    });
  } catch (error) {
    console.error('Get user posts error:', error);
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
      
      // Create notification for post owner
      const [post] = await pool.query('SELECT user_id FROM posts WHERE id = ?', [postId]);
      if (post.length > 0 && post[0].user_id !== userId) {
        await pool.query(
          'INSERT INTO notifications (user_id, type, actor_id, post_id) VALUES (?, ?, ?, ?)',
          [post[0].user_id, 'like', userId, postId]
        );
      }
      
      res.json({ success: true, liked: true });
    }
  } catch (error) {
    console.error('Like post error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Retweet/Unretweet post
app.post('/api/posts/:postId/retweet', authenticateToken, async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const userId = req.user.userId;

    // Check if already retweeted
    const [existingRetweets] = await pool.query(
      'SELECT id FROM retweets WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );

    if (existingRetweets.length > 0) {
      // Unretweet
      await pool.query('DELETE FROM retweets WHERE user_id = ? AND post_id = ?', [userId, postId]);
      await pool.query('UPDATE posts SET retweet_count = retweet_count - 1 WHERE id = ?', [postId]);
      
      res.json({ success: true, retweeted: false });
    } else {
      // Retweet
      await pool.query('INSERT INTO retweets (user_id, post_id) VALUES (?, ?)', [userId, postId]);
      await pool.query('UPDATE posts SET retweet_count = retweet_count + 1 WHERE id = ?', [postId]);
      
      // Create notification for post owner
      const [post] = await pool.query('SELECT user_id FROM posts WHERE id = ?', [postId]);
      if (post.length > 0 && post[0].user_id !== userId) {
        await pool.query(
          'INSERT INTO notifications (user_id, type, actor_id, post_id) VALUES (?, ?, ?, ?)',
          [post[0].user_id, 'retweet', userId, postId]
        );
      }
      
      res.json({ success: true, retweeted: true });
    }
  } catch (error) {
    console.error('Retweet post error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Reply to post
app.post('/api/posts/:postId/replies', authenticateToken, async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const userId = req.user.userId;
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }

    const [result] = await pool.query(
      'INSERT INTO replies (user_id, post_id, content) VALUES (?, ?, ?)',
      [userId, postId, content]
    );

    // Update reply count
    await pool.query('UPDATE posts SET reply_count = reply_count + 1 WHERE id = ?', [postId]);

    // Create notification for post owner
    const [post] = await pool.query('SELECT user_id FROM posts WHERE id = ?', [postId]);
    if (post.length > 0 && post[0].user_id !== userId) {
      await pool.query(
        'INSERT INTO notifications (user_id, type, actor_id, post_id, content) VALUES (?, ?, ?, ?, ?)',
        [post[0].user_id, 'reply', userId, postId, content]
      );
    }

    const [replies] = await pool.query(`
      SELECT r.*, u.username, u.name, u.profile_image, u.is_verified 
      FROM replies r 
      JOIN users u ON r.user_id = u.id 
      WHERE r.id = ?
    `, [result.insertId]);

    res.status(201).json({
      success: true,
      reply: replies[0]
    });
  } catch (error) {
    console.error('Reply post error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get replies for a post
app.get('/api/posts/:postId/replies', async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);

    const [replies] = await pool.query(`
      SELECT r.*, u.username, u.name, u.profile_image, u.is_verified 
      FROM replies r 
      JOIN users u ON r.user_id = u.id 
      WHERE r.post_id = ?
      ORDER BY r.created_at DESC
    `, [postId]);

    res.json({
      success: true,
      replies
    });
  } catch (error) {
    console.error('Get replies error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== BOOKMARK ENDPOINTS ===================

// Bookmark/Unbookmark post
app.post('/api/posts/:postId/bookmark', authenticateToken, async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const userId = req.user.userId;

    // Check if already bookmarked
    const [existingBookmarks] = await pool.query(
      'SELECT id FROM bookmarks WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );

    if (existingBookmarks.length > 0) {
      // Remove bookmark
      await pool.query('DELETE FROM bookmarks WHERE user_id = ? AND post_id = ?', [userId, postId]);
      res.json({ success: true, bookmarked: false });
    } else {
      // Add bookmark
      await pool.query('INSERT INTO bookmarks (user_id, post_id) VALUES (?, ?)', [userId, postId]);
      res.json({ success: true, bookmarked: true });
    }
  } catch (error) {
    console.error('Bookmark post error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user bookmarks
app.get('/api/users/:userId/bookmarks', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    const [bookmarks] = await pool.query(`
      SELECT p.*, u.username, u.name, u.profile_image, u.is_verified 
      FROM bookmarks b
      JOIN posts p ON b.post_id = p.id
      JOIN users u ON p.user_id = u.id 
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    `, [userId]);

    res.json({
      success: true,
      bookmarks
    });
  } catch (error) {
    console.error('Get bookmarks error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check if post is bookmarked
app.get('/api/posts/:postId/is-bookmarked', authenticateToken, async (req, res) => {
  try {
    const postId = parseInt(req.params.postId);
    const userId = req.user.userId;

    const [bookmarks] = await pool.query(
      'SELECT id FROM bookmarks WHERE user_id = ? AND post_id = ?',
      [userId, postId]
    );

    res.json({
      success: true,
      bookmarked: bookmarks.length > 0
    });
  } catch (error) {
    console.error('Check bookmark error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== USER ENDPOINTS ===================

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

// Get user by username
app.get('/api/users/username/:username', async (req, res) => {
  try {
    const username = req.params.username;
    
    const [users] = await pool.query('SELECT * FROM users WHERE username = ?', [username]);
    
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
    console.error('Get user by username error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user profile
app.put('/api/users/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    const { name, bio, location, website } = req.body;

    // Check if user is updating their own profile
    if (req.user.userId !== userId) {
      return res.status(403).json({ error: 'Cannot update another user\'s profile' });
    }

    await pool.query(
      'UPDATE users SET name = ?, bio = ?, location = ?, website = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [name, bio, location, website, userId]
    );

    const [users] = await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
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
    console.error('Update user profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Search users
app.get('/api/users/search', async (req, res) => {
  try {
    const query = req.query.q;
    
    if (!query) {
      return res.status(400).json({ error: 'Query parameter required' });
    }

    const [users] = await pool.query(`
      SELECT id, username, name, profile_image, is_verified, follower_count
      FROM users 
      WHERE username LIKE ? OR name LIKE ? 
      LIMIT 20
    `, [`%${query}%`, `%${query}%`]);

    res.json({
      success: true,
      users
    });
  } catch (error) {
    console.error('Search users error:', error);
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
      
      // Create follow notification
      await pool.query(
        'INSERT INTO notifications (user_id, type, actor_id) VALUES (?, ?, ?)',
        [followingId, 'follow', followerId]
      );
      
      res.json({ success: true, following: true });
    }
  } catch (error) {
    console.error('Follow user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check if following user
app.get('/api/users/:userId/is-following', authenticateToken, async (req, res) => {
  try {
    const followingId = parseInt(req.params.userId);
    const followerId = req.user.userId;

    const [follows] = await pool.query(
      'SELECT id FROM follows WHERE follower_id = ? AND following_id = ?',
      [followerId, followingId]
    );

    res.json({
      success: true,
      following: follows.length > 0
    });
  } catch (error) {
    console.error('Check following error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user followers
app.get('/api/users/:userId/followers', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    const [followers] = await pool.query(`
      SELECT u.id, u.username, u.name, u.profile_image, u.is_verified, u.follower_count
      FROM follows f
      JOIN users u ON f.follower_id = u.id
      WHERE f.following_id = ?
      ORDER BY f.created_at DESC
    `, [userId]);

    res.json({
      success: true,
      followers
    });
  } catch (error) {
    console.error('Get followers error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user following
app.get('/api/users/:userId/following', async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    const [following] = await pool.query(`
      SELECT u.id, u.username, u.name, u.profile_image, u.is_verified, u.follower_count
      FROM follows f
      JOIN users u ON f.following_id = u.id
      WHERE f.follower_id = ?
      ORDER BY f.created_at DESC
    `, [userId]);

    res.json({
      success: true,
      following
    });
  } catch (error) {
    console.error('Get following error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get suggested users
app.get('/api/users/:userId/suggestions', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    // Get users that the current user is not following, excluding themselves
    const [suggestions] = await pool.query(`
      SELECT u.id, u.username, u.name, u.profile_image, u.is_verified, u.follower_count
      FROM users u
      WHERE u.id != ? 
      AND u.id NOT IN (
        SELECT following_id FROM follows WHERE follower_id = ?
      )
      ORDER BY u.follower_count DESC
      LIMIT 10
    `, [userId, userId]);

    res.json({
      success: true,
      suggestions
    });
  } catch (error) {
    console.error('Get suggested users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== NOTIFICATION ENDPOINTS ===================

// Get user notifications
app.get('/api/users/:userId/notifications', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    const [notifications] = await pool.query(`
      SELECT n.*, 
             u.username as actor_username, 
             u.name as actor_name, 
             u.profile_image as actor_profile_image, 
             u.is_verified as actor_is_verified
      FROM notifications n
      JOIN users u ON n.actor_id = u.id
      WHERE n.user_id = ?
      ORDER BY n.created_at DESC
      LIMIT 50
    `, [userId]);

    res.json({
      success: true,
      notifications
    });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Mark notification as read
app.patch('/api/notifications/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const notificationId = parseInt(req.params.notificationId);

    await pool.query('UPDATE notifications SET is_read = TRUE WHERE id = ?', [notificationId]);

    res.json({
      success: true
    });
  } catch (error) {
    console.error('Mark notification read error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get unread notification count
app.get('/api/users/:userId/notifications/unread-count', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    const [result] = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = FALSE',
      [userId]
    );

    res.json({
      success: true,
      count: result[0].count
    });
  } catch (error) {
    console.error('Get unread notification count error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== MESSAGE ENDPOINTS ===================

// Get user messages (conversations)
app.get('/api/users/:userId/messages', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    // Get latest message from each conversation
    const [messages] = await pool.query(`
      SELECT DISTINCT
        m.*,
        sender.username as sender_username,
        sender.name as sender_name,
        sender.profile_image as sender_profile_image,
        sender.is_verified as sender_is_verified
      FROM messages m
      JOIN users sender ON m.sender_id = sender.id
      WHERE m.id IN (
        SELECT MAX(id) FROM messages 
        WHERE sender_id = ? OR receiver_id = ?
        GROUP BY 
          CASE 
            WHEN sender_id = ? THEN receiver_id 
            ELSE sender_id 
          END
      )
      ORDER BY m.created_at DESC
    `, [userId, userId, userId]);

    res.json({
      success: true,
      messages
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get conversation messages between two users
app.get('/api/users/:userId/messages/:otherUserId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    const otherUserId = parseInt(req.params.otherUserId);

    const [messages] = await pool.query(`
      SELECT m.*,
             sender.username as sender_username,
             sender.name as sender_name,
             sender.profile_image as sender_profile_image,
             sender.is_verified as sender_is_verified
      FROM messages m
      JOIN users sender ON m.sender_id = sender.id
      WHERE (m.sender_id = ? AND m.receiver_id = ?) 
         OR (m.sender_id = ? AND m.receiver_id = ?)
      ORDER BY m.created_at ASC
    `, [userId, otherUserId, otherUserId, userId]);

    // Mark messages as read
    await pool.query(
      'UPDATE messages SET is_read = TRUE WHERE sender_id = ? AND receiver_id = ?',
      [otherUserId, userId]
    );

    res.json({
      success: true,
      messages
    });
  } catch (error) {
    console.error('Get conversation messages error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Send message
app.post('/api/messages', authenticateToken, async (req, res) => {
  try {
    const { receiver_id, content } = req.body;
    const senderId = req.user.userId;

    if (!receiver_id || !content) {
      return res.status(400).json({ error: 'Receiver ID and content are required' });
    }

    const [result] = await pool.query(
      'INSERT INTO messages (sender_id, receiver_id, content) VALUES (?, ?, ?)',
      [senderId, receiver_id, content]
    );

    const [messages] = await pool.query(`
      SELECT m.*,
             sender.username as sender_username,
             sender.name as sender_name,
             sender.profile_image as sender_profile_image,
             sender.is_verified as sender_is_verified
      FROM messages m
      JOIN users sender ON m.sender_id = sender.id
      WHERE m.id = ?
    `, [result.insertId]);

    res.status(201).json({
      success: true,
      message: messages[0]
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== TRENDING/EXPLORE ENDPOINTS ===================

// Get trending topics
app.get('/api/trending', async (req, res) => {
  try {
    const trendingTopics = [
      'Flutter Development',
      'React Native',
      'Mobile Apps',
      'Programming',
      'JavaScript',
      'TypeScript',
      'Node.js',
      'MongoDB',
      'MySQL',
      'API Development'
    ];

    res.json({
      success: true,
      trends: trendingTopics
    });
  } catch (error) {
    console.error('Get trending topics error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =================== UTILITY ENDPOINTS ===================

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'X Clone API Server is running',
    timestamp: new Date().toISOString()
  });
});

// Get server stats
app.get('/api/stats', async (req, res) => {
  try {
    const [userCount] = await pool.query('SELECT COUNT(*) as count FROM users');
    const [postCount] = await pool.query('SELECT COUNT(*) as count FROM posts');
    const [messageCount] = await pool.query('SELECT COUNT(*) as count FROM messages');
    const [notificationCount] = await pool.query('SELECT COUNT(*) as count FROM notifications');

    res.json({
      success: true,
      stats: {
        users: userCount[0].count,
        posts: postCount[0].count,
        messages: messageCount[0].count,
        notifications: notificationCount[0].count
      }
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large' });
    }
  }
  
  console.error('Unhandled error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler - This should be at the end
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
async function startServer() {
  try {
    await initializeDatabase();
    
    app.listen(PORT, () => {
      console.log(`🚀 X Clone API Server running on http://localhost:${PORT}`);
      console.log(`📖 API Documentation:`);
      console.log(`   === AUTHENTICATION ===`);
      console.log(`   POST /api/auth/login - Login user`);
      console.log(`   POST /api/auth/register - Register user`);
      console.log(`   === FILE UPLOADS ===`);
      console.log(`   POST /api/upload/profile-image - Upload profile image`);
      console.log(`   POST /api/upload/banner-image - Upload banner image`);
      console.log(`   POST /api/upload/post-image - Upload post image`);
      console.log(`   === POSTS ===`);
      console.log(`   GET  /api/posts - Get all posts`);
      console.log(`   POST /api/posts - Create post`);
      console.log(`   POST /api/posts/:id/like - Like/unlike post`);
      console.log(`   POST /api/posts/:id/retweet - Retweet/unretweet post`);
      console.log(`   POST /api/posts/:id/replies - Reply to post`);
      console.log(`   GET  /api/posts/:id/replies - Get post replies`);
      console.log(`   === BOOKMARKS ===`);
      console.log(`   POST /api/posts/:id/bookmark - Bookmark/unbookmark post`);
      console.log(`   GET  /api/users/:id/bookmarks - Get user bookmarks`);
      console.log(`   GET  /api/posts/:id/is-bookmarked - Check if bookmarked`);
      console.log(`   === USERS ===`);
      console.log(`   GET  /api/users/:id - Get user info`);
      console.log(`   GET  /api/users/username/:username - Get user by username`);
      console.log(`   PUT  /api/users/:id - Update user profile`);
      console.log(`   GET  /api/users/search - Search users`);
      console.log(`   GET  /api/users/:id/posts - Get user posts`);
      console.log(`   POST /api/users/:id/follow - Follow/unfollow user`);
      console.log(`   GET  /api/users/:id/is-following - Check if following`);
      console.log(`   GET  /api/users/:id/followers - Get user followers`);
      console.log(`   GET  /api/users/:id/following - Get user following`);
      console.log(`   GET  /api/users/:id/suggestions - Get suggested users`);
      console.log(`   === NOTIFICATIONS ===`);
      console.log(`   GET  /api/users/:id/notifications - Get user notifications`);
      console.log(`   PATCH /api/notifications/:id/read - Mark notification as read`);
      console.log(`   GET  /api/users/:id/notifications/unread-count - Get unread count`);
      console.log(`   === MESSAGES ===`);
      console.log(`   GET  /api/users/:id/messages - Get user conversations`);
      console.log(`   GET  /api/users/:id/messages/:otherId - Get conversation messages`);
      console.log(`   POST /api/messages - Send message`);
      console.log(`   === EXPLORE ===`);
      console.log(`   GET  /api/trending - Get trending topics`);
      console.log(`   === UTILITY ===`);
      console.log(`   GET  /api/health - Health check`);
      console.log(`   GET  /api/stats - Server statistics`);
      console.log(`\n📁 File uploads are stored in: backend/uploads/users/{userId}/`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();