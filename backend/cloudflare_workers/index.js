import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';
import { secureHeaders } from 'hono/secure-headers';
import { timing } from 'hono/timing';

import { aiVoiceDispatchRoutes } from '../api/ai-voice-dispatch.js';
import { driverPoolRoutes } from '../api/driver-pool.js';
import { secureGatekeeperRoutes } from '../api/secure-gatekeeper.js';
import { connectorHubRoutes } from '../api/connector-hub.js';
import { profitEngineRoutes } from '../api/profit-engine.js';
import { notificationRoutes } from '../api/notification.js';
import { authMiddleware } from '../middleware/auth.js';
import { errorHandler } from '../middleware/error-handler.js';
import { rateLimitMiddleware } from '../middleware/rate-limit.js';

const app = new Hono();

// Middleware
app.use('*', logger());
app.use('*', timing());
app.use('*', secureHeaders());
app.use('*', cors({
  origin: ['https://mobi360.app', 'https://dev.mobi360.app', 'https://stg.mobi360.app'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  credentials: true
}));
app.use('*', prettyJSON());

// Health check endpoint
app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: c.env.ENVIRONMENT || 'dev'
  });
});

// API routes with authentication and rate limiting
app.route('/api/v1/ai-voice-dispatch', authMiddleware, rateLimitMiddleware, aiVoiceDispatchRoutes);
app.route('/api/v1/driver-pool', authMiddleware, rateLimitMiddleware, driverPoolRoutes);
app.route('/api/v1/secure-gatekeeper', authMiddleware, rateLimitMiddleware, secureGatekeeperRoutes);
app.route('/api/v1/connector-hub', authMiddleware, rateLimitMiddleware, connectorHubRoutes);
app.route('/api/v1/profit-engine', authMiddleware, rateLimitMiddleware, profitEngineRoutes);
app.route('/api/v1/notification', authMiddleware, rateLimitMiddleware, notificationRoutes);

// Error handling
app.onError(errorHandler);

// 404 handler
app.notFound((c) => {
  return c.json({ error: 'Not Found', message: 'The requested resource was not found' }, 404);
});

export default app;