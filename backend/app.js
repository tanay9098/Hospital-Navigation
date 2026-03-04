const path    = require('path');
const express = require('express');
const cors    = require('cors');
const helmet  = require('helmet');
const morgan  = require('morgan');
const errorHandler = require('./middleware/errorHandler');
const routes       = require('./routes/index');

const app = express();

// Security & logging middleware
// helmet's contentSecurityPolicy is relaxed so inline scripts in HTML pages work
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Body parsers – Twilio IVR sends application/x-www-form-urlencoded
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve the frontend (plain HTML/CSS/JS) as static files.
// Must come BEFORE API routes so index.html is reachable at /.
app.use(express.static(path.join(__dirname, '../frontend')));

// API routes
app.use('/api/v1', routes);

// Any non-API unknown route → serve index.html (SPA-style fallback)
app.use((req, res, next) => {
  if (req.path.startsWith('/api/')) {
    return res.status(404).json({
      success: false,
      message: `Route ${req.method} ${req.originalUrl} not found`,
    });
  }
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Global error handler (must be last)
app.use(errorHandler);

module.exports = app;
