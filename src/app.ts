import "dotenv/config";
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
