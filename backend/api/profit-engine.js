import { Hono } from 'hono';

const app = new Hono();

app.get('/health', (c) => {
  return c.json({
    success: true,
    service: 'profit-engine',
    message: 'Service is healthy'
  });
});

export { app as profitEngineRoutes };