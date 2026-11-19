
require("dotenv").config();
console.log("SUPABASE URL:", process.env.SUPABASE_URL);
console.log("SUPABASE KEY EXISTS:", !!process.env.SUPABASE_PUBLISHABLE_KEY);

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const medicationRoutes = require("./routes/medications");

const authRoutes = require("./routes/auth");

const app = express();
const PORT = process.env.PORT || 3000;

// Check environment variables
if (!process.env.SUPABASE_URL || !process.env.SUPABASE_PUBLISHABLE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY in .env");
  process.exit(1);
}

// Request logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  console.log("Origin:", req.headers.origin || "No origin");
  next();
});

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN
    ? process.env.CORS_ORIGIN.split(",").map((value) => value.trim())
    : true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

// Security and request parsing
app.use(helmet());
app.use(express.json({ limit: "10kb" }));

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    success: true,
    name: "Dr. Drugs API",
    status: "running",
    endpoints: {
      health: "GET /api/health",
      register: "POST /api/auth/register",
      login: "POST /api/auth/login",
      medications: "GET, POST /api/medications"
    }
  });
});

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Dr. Drugs API is healthy."
  });
});

// Authentication rate limiter
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 30,
  standardHeaders: "draft-7",
  legacyHeaders: false
});

// Authentication routes
app.use("/api/auth", authLimiter, authRoutes);
app.use("/api/medications", medicationRoutes);
console.log("MEDICATION ROUTES REGISTERED");

// 404 handler
app.use((req, res) => {
  console.log("404 ROUTE NOT FOUND:", req.method, req.originalUrl);

  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error("SERVER ERROR:", err);

  res.status(500).json({
    success: false,
    message: "An unexpected server error occurred."
  });
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
  console.log("--------------------------------");
  console.log("Dr. Drugs API is running!");
  console.log(`Local: http://localhost:${PORT}`);
  console.log(`Health: http://localhost:${PORT}/api/health`);
  console.log(`Register: POST http://localhost:${PORT}/api/auth/register`);
  console.log(`Login: POST http://localhost:${PORT}/api/auth/login`);
  console.log("--------------------------------");
});
