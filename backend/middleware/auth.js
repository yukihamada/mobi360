import { HTTPException } from 'hono/http-exception';
import { jwt } from 'hono/jwt';

export async function authMiddleware(c, next) {
  try {
    // 開発環境ではトークン検証をスキップ
    if (c.env.ENVIRONMENT === 'dev') {
      await next();
      return;
    }

    const token = c.req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      throw new HTTPException(401, {
        message: 'Authorization token required'
      });
    }

    // JWT検証は後で実装
    await next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    throw new HTTPException(401, {
      message: 'Invalid authorization token'
    });
  }
}