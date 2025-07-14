# Mobility Ops 360 SDK - クイックスタートガイド

## 🚀 5分で始めるMobility Ops 360

### 1. インストール

```bash
npm install @mobi360/sdk
```

### 2. 基本的な使い方

```typescript
import { Mobi360Client } from '@mobi360/sdk';

// クライアントを初期化
const client = new Mobi360Client();

// システムヘルスチェック
const health = await client.health();
console.log(health.status); // "healthy"
```

### 3. 認証

```typescript
// ログイン
const loginResult = await client.auth.login({
  email: 'demo@example.com',
  password: 'password123'
});

// これで認証完了！APIを使う準備ができました
```

### 4. 最初のAPI呼び出し

```typescript
// ダッシュボード統計を取得
const stats = await client.dashboard.stats();
console.log(`アクティブドライバー数: ${stats.data.activeDrivers}`);

// 近くのドライバーを検索
const nearbyDrivers = await client.drivers.getNearby(
  35.6762,  // 新宿駅の緯度
  139.6503, // 新宿駅の経度
  5.0       // 5km圏内
);
console.log(`${nearbyDrivers.data.drivers.length}人のドライバーが見つかりました`);
```

### 5. AI音声配車を作成

```typescript
// 配車リクエストを作成
const dispatch = await client.voiceDispatch.create({
  customerName: '田中太郎',
  customerPhone: '090-1234-5678',
  pickupLocation: '新宿駅東口',
  destination: '渋谷駅',
  vehicleType: 'standard'
});

console.log(`配車ID: ${dispatch.data.dispatchId}`);
console.log(`予想到着時間: ${dispatch.data.estimatedArrival}分`);
```

---

## 📚 次のステップ

### より詳しく学ぶ

1. **[完全なAPIリファレンス](./API.md)** - すべてのメソッドと型定義
2. **[サンプルコード](../examples/)** - 実践的な使用例
3. **[WebSocket通信](./WEBSOCKET.md)** - リアルタイム機能の実装

### よくある実装パターン

#### パターン1: エラーハンドリング

```typescript
try {
  const result = await client.auth.login({
    email: 'test@example.com',
    password: 'password'
  });
} catch (error) {
  console.error('ログインエラー:', error.response?.data?.message);
}
```

#### パターン2: リアルタイム位置追跡

```typescript
// WebSocket接続
const ws = client.ws.connect('driver', 'driver_123');

// 位置情報の更新を受信
client.on('ws:location_broadcast', (data) => {
  console.log(`ドライバー ${data.driver_id} の位置:`, data.location);
});
```

#### パターン3: データエクスポート

```typescript
// 今月のドライバーデータをCSVでダウンロード
const csvData = await client.export.drivers({
  format: 'csv',
  startDate: '2024-01-01',
  endDate: '2024-01-31'
});

// ブラウザでダウンロード
const url = URL.createObjectURL(csvData);
const a = document.createElement('a');
a.href = url;
a.download = 'drivers-2024-01.csv';
a.click();
```

---

## 🔧 環境別設定

### 開発環境

```typescript
const client = new Mobi360Client({
  baseUrl: 'http://localhost:8787',
  debug: true
});
```

### 本番環境

```typescript
const client = new Mobi360Client({
  apiKey: process.env.MOBI360_API_KEY,
  timeout: 60000, // 本番環境では長めのタイムアウト
  retryAttempts: 5
});
```

---

## ❓ よくある質問

### Q: 認証トークンはどこに保存されますか？

A: SDKがメモリ内で自動管理します。永続化が必要な場合：

```typescript
// トークンを取得して保存
const loginResult = await client.auth.login({...});
localStorage.setItem('mobi360_token', loginResult.data.token);

// 次回起動時に復元
const savedToken = localStorage.getItem('mobi360_token');
if (savedToken) {
  client.setAuthToken(savedToken);
}
```

### Q: WebSocket接続が切れた場合は？

A: 自動再接続の実装例：

```typescript
function connectWithAutoReconnect() {
  const ws = client.ws.connect('driver', 'driver_123');
  
  client.on('ws:close', () => {
    console.log('接続が切れました。5秒後に再接続...');
    setTimeout(connectWithAutoReconnect, 5000);
  });
}
```

### Q: 大量のデータを扱う場合は？

A: ページネーションを活用：

```typescript
// 100件ずつ取得
let page = 1;
let hasMore = true;

while (hasMore) {
  const result = await client.drivers.list({
    page: page,
    limit: 100
  });
  
  // データを処理
  processDrivers(result.data.data);
  
  hasMore = page < result.data.totalPages;
  page++;
}
```

---

## 🆘 サポート

問題が発生した場合：

1. **デバッグモードを有効化**
   ```typescript
   const client = new Mobi360Client({ debug: true });
   ```

2. **[GitHub Issues](https://github.com/mobility360/sdk-typescript/issues)** で報告

3. **Slackチャンネル** `#mobility360-sdk` で質問

4. **メール** support@mobility360.jp

---

## 🎉 準備完了！

これでMobility Ops 360 SDKを使い始める準備が整いました。
タクシー業界のDXを一緒に実現しましょう！