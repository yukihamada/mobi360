import { HTTPException } from 'hono/http-exception';

export async function rateLimitMiddleware(c, next) {
  try {
    // 開発環境ではレート制限をスキップ
    if (c.env.ENVIRONMENT === 'dev') {
      await next();
      return;
    }

    const clientIP = c.req.header('CF-Connecting-IP') || c.req.header('X-Forwarded-For') || 'unknown';
    const key = `ratelimit:${clientIP}`;
    
    // KVストアでレート制限を管理（実装は後で詳細化）
    await next();
  } catch (error) {
    console.error('Rate limit middleware error:', error);
    throw new HTTPException(429, {
      message: 'Too Many Requests'
    });
  }
}