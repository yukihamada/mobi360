import { Hono } from 'hono';

const app = new Hono();

app.get('/health', (c) => {
  return c.json({
    success: true,
    service: 'notification',
    message: 'Service is healthy'
  });
});

export { app as notificationRoutes };