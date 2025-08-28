#!/usr/bin/env bash

# Set Up an Express app with typescript

echo "🚀 Setting up Express.js application with TypeScript..."


echo -n "📦 Initializing npm project..."
if npm init -y > /dev/null 2>&1; then
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to initialize npm project"
  exit 1
fi


echo -n "🔧 Installing TypeScript and development dependencies..."
if npm install typescript --save-dev > /dev/null 2>&1 && npm install --save-dev ts-node ts-node-dev @types/node > /dev/null 2>&1; then
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to install TypeScript and development dependencies"
  exit 1
fi


echo -n "⚙️ Configuring TypeScript..."
if npx tsc --init --outDir ./dist --rootDir ./src --esModuleInterop true --module commonjs --target es2016 --verbatimModuleSyntax false > /dev/null 2>&1 && npm pkg set scripts.build="tsc" > /dev/null 2>&1 && npm pkg set scripts.start="node dist/index.js" > /dev/null 2>&1; then
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to configure TypeScript"
  exit 1
fi


echo -n "🔍 Setting up ESLint..."
if npm install --save-dev eslint @eslint/js typescript-eslint > /dev/null 2>&1 && npm pkg set scripts.eslint="eslint ." > /dev/null 2>&1; then
  touch eslint.config.mjs
  echo "// @ts-check

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  tseslint.configs.strict,
  tseslint.configs.stylistic,
  {
    ignores: ['build/', 'jest.config.js', 'temp/', 'src/**/**.test.ts'],
  }
);" > eslint.config.mjs
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to set up ESLint"
  exit 1
fi


echo -n "💅 Setting up Prettier..."
if npm install --save-dev prettier > /dev/null 2>&1 && npm pkg set scripts.format="prettier --write . --ignore-unknown" > /dev/null 2>&1; then
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to set up Prettier"
  exit 1
fi


echo -n "🧪 Setting up Jest testing framework..."
if npm install --save-dev ts-jest > /dev/null 2>&1 && npm install --save-dev @types/jest > /dev/null 2>&1 && npm pkg set scripts.test="jest" > /dev/null 2>&1; then
  echo "const { createDefaultPreset } = require('ts-jest');
const tsJestTransformCfg = createDefaultPreset().transform;
/** @type {import('jest').Config} **/
module.exports = {
  testEnvironment: 'node',
  transform: {
    ...tsJestTransformCfg,
  },
  testPathIgnorePatterns: ['.dist/'],
  modulePathIgnorePatterns: ['.dist/'],
};" > jest.config.js
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to set up Jest testing framework"
  exit 1
fi


echo -n "🐕 Setting up Husky for git hooks..."
if npm install --save-dev husky > /dev/null 2>&1 && npx husky init > /dev/null 2>&1; then
  echo "npx npm run format
npx npm run eslint
npx npm run test
git add -A ." > .husky/pre-commit
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to set up Husky for git hooks"
  exit 1
fi


echo -n "📁 Creating project structure..."
if mkdir -p src/controllers src/routes src/middlewares src/services src/utils && npm pkg set scripts.dev="ts-node-dev --respawn --transpile-only src/index.ts" > /dev/null 2>&1; then
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to create project structure"
  exit 1
fi


echo -n "📦 Installing Express.js and dependencies..."
if npm install express cookie-parser cors dotenv winston zod --save > /dev/null 2>&1 && npm install --save-dev @types/cors @types/express @types/cookie-parser @types/dotenv > /dev/null 2>&1; then
  echo " ✅"
else
  echo " ❌"
  echo "Error: Failed to install Express.js and dependencies"
  exit 1
fi


echo -n "📝 Creating source files..."
# Create all source files
echo 'import winston from "winston";

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Define colors for each level
const colors = {
  error: "red",
  warn: "yellow",
  info: "green",
  http: "magenta",
  debug: "white",
};

// Tell winston that you want to link the colors
winston.addColors(colors);

// Define which level to log based on environment
const level = () => {
  const env = process.env.NODE_ENV || "development";
  const isDevelopment = env === "development";
  return isDevelopment ? "debug" : "warn";
};

// Define different log formats
const format = winston.format.combine(
  // Add timestamp
  winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss:ms" }),
  // Add colors
  winston.format.colorize({ all: true }),
  // Define format of the message showing the timestamp, the level and the message
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`,
  ),
);

// Define which transports the logger must use to print out messages
const transports = [
  // Console transport
  new winston.transports.Console(),
  // Error log file
  new winston.transports.File({
    filename: "logs/error.log",
    level: "error",
  }),
  // All logs file
  new winston.transports.File({ filename: "logs/all.log" }),
];

// Create the logger
const logger = winston.createLogger({
  level: level(),
  levels,
  format,
  transports,
});
export default logger;
'> src/utils/logger.ts

echo "Creating main application file..."
echo 'import "dotenv/config";
import express from "express";
import logger from "./utils/logger";
import cookieParser from "cookie-parser";
import loggingMiddleware from "./middlewares/logger.middleware";
import helloWorldRoute from "./routes/helloWorld.route";
import cors from "cors";

const app = express();
app.use(cookieParser()); // for parsing cookies
app.use(express.json()); // for parsing application/json
app.use(express.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.use(
  cors({
    origin: process.env.SITE_URL || "http://localhost:3000",
    credentials: true, // This allows cookies to be sent/received
  }),
);

// Request logging middleware
app.use(loggingMiddleware);

// Health check endpoint
app.get("/health", (req, res) => {
  logger.info("🏥 Health check requested");
  res.status(200).json({
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
    version: process.env.npm_package_version || "1.0.0",
  });
});

// Hello World endpoint
app.use("/hello-world", helloWorldRoute);
export default app;
' > src/app.ts

echo "Creating server entry point..."
echo 'import app from "./app";
import logger from "./utils/logger";
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  logger.info(`🚀 Server is running on port ${PORT}!`);
  logger.info(`📝 Environment: ${process.env.NODE_ENV || "development"}`);
  logger.info(`🔗 API Base URL: ${process.env.SITE_URL}/api/v1/`);
  logger.info(`📊 Health Check: ${process.env.SITE_URL}/health`);
});

// Handle uncaught exceptions
process.on("uncaughtException", (error) => {
  logger.error("Uncaught Exception:", error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on("unhandledRejection", (reason, promise) => {
  logger.error("Unhandled Rejection at:", promise, "reason:", reason);
  process.exit(1);
});
' > src/index.ts

echo "Creating environment configuration..."
echo 'PORT=3000
NODE_ENV=development
SITE_URL=http://localhost:3000' > .env

echo "Creating logging middleware..."
echo 'import type { Request, Response, NextFunction } from "express";
import logger from "../utils/logger";

/**
 * Middleware that logs the request and response status
 */
const loggingMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  res.on("finish", () => {
    const duration = Date.now() - start;
    const status = res.statusCode;
    const method = req.method;
    const url = req.url;
    const userAgent = req.get("User-Agent") || "Unknown";
    if (status >= 400) {
      logger.warn(
        `⚠️ ${method} ${url} - ${status} - ${duration}ms - ${userAgent}`,
      );
    } else {
      logger.http(
        `🔗 ${method} ${url} - ${status} - ${duration}ms - ${userAgent}`,
      );
    }
  });
  next();
};

export default loggingMiddleware;
' > src/middlewares/logger.middleware.ts

echo "Creating service layer..."
echo 'export const helloWorld = () => {
  return "Hello World";
};' > src/services/helloWorld.service.ts

echo "Creating controller..."
echo 'import type { Request, Response } from "express";
import logger from "../utils/logger";
import { helloWorld } from "../services/helloWorld.service";

export const helloWorldController = (req: Request, res: Response) => {
  logger.info("Hello World Request Controller");
  const message = helloWorld();
  res.status(200).json({
    message: message,
  });
};
' > src/controllers/helloWorld.controller.ts

echo "Creating route..."
echo 'import { Router } from "express";
import { helloWorldController } from "../controllers/helloWorld.controller";

const router = Router();

router.get("/", helloWorldController);

export default router;
' > src/routes/helloWorld.route.ts

echo "Creating .gitignore..."
echo 'node_modules/
dist/
.env
.env.**
--help/
logs/
*.log' > .gitignore

echo " ✅"

echo "🎉 Setup complete! Your Express.js application with TypeScript is ready."

echo "📋 Available scripts:"
echo "  npm run dev     - Start development server"
echo "  npm run build   - Build for production"
echo "  npm run start   - Start production server"
echo "  npm run test    - Run tests"
echo "  npm run eslint  - Run ESLint"
echo "  npm run format  - Format code with Prettier"

echo "🚀 To start development: npm run dev"
echo "🔗 Server will be available at: http://localhost:3000"
echo "📊 Health check: http://localhost:3000/health"
echo "👋 Hello World: http://localhost:3000/hello-world"
