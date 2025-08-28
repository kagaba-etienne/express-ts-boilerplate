import app from "./app";
import logger from "./utils/logger";
const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  logger.info(`🚀 Server is running on port ${PORT}!`);
  logger.info(`📝 Environment: ${process.env.NODE_ENV || "development"}`);
  logger.info(`🔗 API Base URL: ${process.env.SITE_URL}/api/v1/`);
  logger.info(`📊 Health Check: ${process.env.SITE_URL}/health`);
});

// Graceful shutdown handler
const gracefulShutdown = () => {
  logger.info("Received shutdown signal, closing server...");
  server.close(() => {
    logger.info("Server closed. Exiting process.");
    process.exit(0);
  });

  // Force close server after 10 seconds
  setTimeout(() => {
    logger.error(
      "Could not close connections in time, forcefully shutting down",
    );
    process.exit(1);
  }, 10000);
};

// Listen for termination signals
process.on("SIGTERM", gracefulShutdown);
process.on("SIGINT", gracefulShutdown);

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
