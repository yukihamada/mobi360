// メインエクスポート
export { Mobi360Client } from './client';

// 型定義のエクスポート
export * from './types';

// デフォルトエクスポート
import { Mobi360Client } from './client';
export default Mobi360Client;

// 便利な初期化関数
export function createClient(config?: import('./types').Mobi360Config): Mobi360Client {
  return new Mobi360Client(config);
}