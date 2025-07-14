# Mobility Ops 360 SDK - API リファレンス

## 目次

- [クライアント初期化](#クライアント初期化)
- [認証 API](#認証-api)
- [ダッシュボード API](#ダッシュボード-api)
- [ドライバー管理 API](#ドライバー管理-api)
- [AI音声配車 API](#ai音声配車-api)
- [リアルタイム配車 API](#リアルタイム配車-api)
- [WebSocket API](#websocket-api)
- [データエクスポート API](#データエクスポート-api)
- [監視・ログ API](#監視ログ-api)
- [設定管理 API](#設定管理-api)
- [データベース管理 API](#データベース管理-api)
- [エラーハンドリング](#エラーハンドリング)
- [型定義](#型定義)

---

## クライアント初期化

### `new Mobi360Client(config?: Mobi360Config)`

Mobility Ops 360 APIクライアントを初期化します。

```typescript
import { Mobi360Client } from '@mobi360/sdk';

const client = new Mobi360Client({
  baseUrl: 'https://mobility-ops-360-api.yukihamada.workers.dev',
  apiKey: 'your-api-key',
  timeout: 30000,
  retryAttempts: 3,
  retryDelay: 1000,
  debug: true
});
```

#### パラメータ

| 名前 | 型 | 必須 | デフォルト | 説明 |
|------|---|------|-----------|------|
| `baseUrl` | `string` | いいえ | `https://mobility-ops-360-api.yukihamada.workers.dev` | APIのベースURL |
| `apiKey` | `string` | いいえ | - | APIキー（将来の拡張用） |
| `timeout` | `number` | いいえ | `30000` | リクエストタイムアウト（ミリ秒） |
| `retryAttempts` | `number` | いいえ | `3` | リトライ回数 |
| `retryDelay` | `number` | いいえ | `1000` | リトライ間隔（ミリ秒） |
| `debug` | `boolean` | いいえ | `false` | デバッグモード |

---

## 認証 API

### `client.auth.registerCompany(data: CompanyRegistration)`

新しいタクシー会社を登録します。

```typescript
const result = await client.auth.registerCompany({
  companyName: 'デモタクシー株式会社',
  companyAddress: '東京都新宿区西新宿1-1-1',
  companyPhone: '03-1234-5678',
  licenseNumber: '関自旅二第1234号',
  representativeName: '代表太郎',
  representativeEmail: 'demo@example.com',
  serviceArea: '東京都23区内',
  vehicleCount: '50',
  driverCount: '25',
  selectedPlan: 'standard'
});
```

#### レスポンス
```typescript
{
  success: true,
  message: '会社登録が完了しました',
  data: {
    companyId: 'company_1234567890_abcdefghi'
  }
}
```

### `client.auth.registerDriver(data: DriverRegistration)`

新しいドライバーを登録します。

```typescript
const result = await client.auth.registerDriver({
  name: 'ドライバー太郎',
  phone: '090-1234-5678',
  email: 'driver@example.com',
  address: '東京都渋谷区渋谷1-1-1',
  birthdate: '1985-01-01',
  licenseNumber: '123456789012',
  licenseExpiry: '2028-01-01',
  taxiLicenseNumber: '第12345号',
  hasOwnVehicle: true,
  isFullTime: true,
  workingArea: '東京都23区内',
  vehicleModel: 'トヨタ プリウス',
  vehicleYear: '2020',
  vehiclePlate: '品川500あ12-34',
  insuranceNumber: 'ABC123456',
  bankName: '三菱UFJ銀行',
  branchName: '新宿支店',
  accountNumber: '1234567',
  accountHolder: 'ドライバー太郎'
});
```

### `client.auth.login(credentials: LoginCredentials)`

ユーザー認証を行い、JWTトークンを取得します。

```typescript
const result = await client.auth.login({
  email: 'demo@example.com',
  password: 'password123'
});
// トークンは自動的にクライアントに設定されます
```

### `client.auth.verify()`

現在のトークンの有効性を検証します。

```typescript
const result = await client.auth.verify();
// { success: true, data: { valid: true } }
```

### `client.auth.refresh(token?: string)`

認証トークンをリフレッシュします。

```typescript
const result = await client.auth.refresh();
// 新しいトークンが自動的に設定されます
```

---

## ダッシュボード API

### `client.dashboard.stats()`

システム全体の統計情報を取得します。

```typescript
const stats = await client.dashboard.stats();
console.log(stats.data);
// {
//   companies: 45,
//   drivers: 123,
//   todayDispatches: 89,
//   activeDrivers: 67,
//   costReduction: 75.0,
//   driverSufficiency: 95.0,
//   profitIncrease: 12.0,
//   systemUptime: 99.9
// }
```

### `client.dashboard.recentRegistrations()`

最近登録された会社とドライバーの情報を取得します。

```typescript
const recent = await client.dashboard.recentRegistrations();
// {
//   companies: [...],
//   drivers: [...]
// }
```

---

## ドライバー管理 API

### `client.drivers.updateLocation(driverId: string, location: DriverLocation)`

ドライバーの位置情報を更新します。

```typescript
await client.drivers.updateLocation('driver_123', {
  latitude: 35.6762,
  longitude: 139.6503,
  heading: 45.0,
  speed: 30.5,
  accuracy: 5.0
});
```

### `client.drivers.getNearby(lat: number, lng: number, radius?: number)`

指定した位置の近くにいるドライバーを検索します。

```typescript
const nearbyDrivers = await client.drivers.getNearby(
  35.6762,  // 緯度
  139.6503, // 経度
  5.0       // 半径（km）
);
```

### `client.drivers.getById(driverId: string)`

特定のドライバーの詳細情報を取得します。

```typescript
const driver = await client.drivers.getById('driver_123');
```

### `client.drivers.list(params?: PaginationParams)`

ドライバー一覧を取得します。

```typescript
const drivers = await client.drivers.list({
  page: 1,
  limit: 20,
  sortBy: 'created_at',
  sortOrder: 'desc'
});
```

---

## AI音声配車 API

### `client.voiceDispatch.create(data: VoiceDispatchRequest)`

AI音声配車リクエストを作成します。

```typescript
const dispatch = await client.voiceDispatch.create({
  customerName: '田中太郎',
  customerPhone: '090-1234-5678',
  pickupLocation: '新宿駅東口',
  destination: '渋谷駅',
  vehicleType: 'standard'
});
```

### `client.voiceDispatch.getById(dispatchId: string)`

配車リクエストの詳細を取得します。

```typescript
const dispatch = await client.voiceDispatch.getById('dispatch_123');
```

### `client.voiceDispatch.list(params?: PaginationParams)`

配車リクエスト一覧を取得します。

```typescript
const dispatches = await client.voiceDispatch.list({
  page: 1,
  limit: 10
});
```

### `client.voiceDispatch.confirm(dispatchId: string)`

配車を確定します。

```typescript
await client.voiceDispatch.confirm('dispatch_123');
```

---

## リアルタイム配車 API

### `client.realtimeDispatch.create(data: RealtimeDispatchRequest)`

リアルタイム配車リクエストを作成します。

```typescript
const result = await client.realtimeDispatch.create({
  pickup_location: {
    latitude: 35.6762,
    longitude: 139.6503,
    address: '新宿駅'
  },
  destination: {
    latitude: 35.6585,
    longitude: 139.7016,
    address: '渋谷駅'
  },
  customer_phone: '090-1234-5678',
  vehicle_type: 'standard',
  notes: '東口でお待ちください'
});
```

---

## WebSocket API

### `client.ws.connect(endpoint: string, id?: string)`

WebSocket接続を確立します。

```typescript
// 汎用WebSocket
const ws1 = client.ws.connect('general');

// ドライバー専用WebSocket
const ws2 = client.ws.connect('driver', 'driver_123');

// 配車追跡用WebSocket
const ws3 = client.ws.connect('dispatch', 'dispatch_456');
```

### イベントリスナー

```typescript
// 接続イベント
client.on('ws:open', ({ endpoint, id }) => {
  console.log(`Connected to ${endpoint}`);
});

// メッセージ受信
client.on('ws:message', ({ endpoint, id, message }) => {
  console.log('Received:', message);
});

// 特定のメッセージタイプ
client.on('ws:location_broadcast', (data) => {
  console.log('Location update:', data);
});

// エラーイベント
client.on('ws:error', ({ endpoint, id, error }) => {
  console.error('WebSocket error:', error);
});

// 切断イベント
client.on('ws:close', ({ endpoint, id }) => {
  console.log('Disconnected');
});
```

### `client.ws.send(endpoint: string, message: WebSocketMessage, id?: string)`

WebSocketメッセージを送信します。

```typescript
client.ws.send('driver', {
  type: 'location_update',
  location: {
    latitude: 35.6762,
    longitude: 139.6503
  }
}, 'driver_123');
```

### `client.ws.disconnect(endpoint: string, id?: string)`

特定のWebSocket接続を切断します。

```typescript
client.ws.disconnect('driver', 'driver_123');
```

### `client.ws.disconnectAll()`

すべてのWebSocket接続を切断します。

```typescript
client.ws.disconnectAll();
```

---

## データエクスポート API

### `client.export.drivers(options?: ExportOptions)`

ドライバーデータをエクスポートします。

```typescript
const csvBlob = await client.export.drivers({
  format: 'csv',
  startDate: '2024-01-01',
  endDate: '2024-12-31',
  status: 'active'
});

// ブラウザでダウンロード
const url = URL.createObjectURL(csvBlob);
const a = document.createElement('a');
a.href = url;
a.download = 'drivers.csv';
a.click();
```

### `client.export.dispatches(options?: ExportOptions)`

配車履歴をエクスポートします。

```typescript
const pdfBlob = await client.export.dispatches({
  format: 'pdf',
  startDate: '2024-01-01',
  endDate: '2024-12-31',
  limit: 1000
});
```

---

## 監視・ログ API

### `client.monitoring.metrics()`

Prometheus形式のメトリクスを取得します。

```typescript
const metrics = await client.monitoring.metrics();
console.log(metrics);
// # HELP http_requests_total Total HTTP requests
// # TYPE http_requests_total counter
// http_requests_total{method="GET",status="200"} 12345
```

### `client.monitoring.logs(level?: string, limit?: number)`

システムログを取得します。

```typescript
const logs = await client.monitoring.logs('error', 100);
// {
//   success: true,
//   data: {
//     logs: [...]
//   }
// }
```

---

## 設定管理 API

### `client.config.get()`

システム設定を取得します。

```typescript
const config = await client.config.get();
// {
//   max_dispatch_radius: 10,
//   default_eta_buffer: 5,
//   surge_pricing_enabled: true,
//   ...
// }
```

---

## データベース管理 API

### `client.database.init()`

データベースを初期化します。

```typescript
const result = await client.database.init();
// { success: true, message: 'Database initialized' }
```

---

## エラーハンドリング

SDKは統一されたエラーハンドリングを提供します：

```typescript
import { AxiosError } from 'axios';

try {
  const result = await client.auth.login({
    email: 'test@example.com',
    password: 'wrong-password'
  });
} catch (error) {
  if (error instanceof AxiosError) {
    const apiError = error.response?.data;
    console.error('API Error:', {
      status: error.response?.status,
      message: apiError?.message,
      error: apiError?.error
    });
  } else {
    console.error('Unexpected error:', error);
  }
}
```

### 自動リトライ

5xx系のエラーは自動的にリトライされます：

- リトライ回数: 3回（デフォルト）
- リトライ間隔: 1秒（デフォルト）

---

## 型定義

SDKは完全なTypeScript型定義を提供しています：

```typescript
import type {
  ApiResponse,
  CompanyRegistration,
  DriverRegistration,
  LoginCredentials,
  AuthToken,
  DashboardStats,
  Driver,
  DriverLocation,
  NearbyDriver,
  VoiceDispatch,
  VoiceDispatchRequest,
  RealtimeDispatchRequest,
  WebSocketMessage,
  ExportOptions,
  SystemConfig,
  SystemMetrics,
  LogEntry,
  PaginationParams,
  PaginatedResponse,
  ApiError,
  Mobi360Config
} from '@mobi360/sdk';
```

### 主要な型定義

#### `ApiResponse<T>`
```typescript
interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}
```

#### `PaginationParams`
```typescript
interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}
```

#### `WebSocketMessage<T>`
```typescript
interface WebSocketMessage<T = any> {
  type: string;
  data?: T;
  timestamp?: string;
}
```

---

## 高度な使用例

### カスタムインターセプター

```typescript
// リクエストインターセプター追加
client.axios.interceptors.request.use(
  (config) => {
    console.log('Request:', config.url);
    return config;
  }
);

// レスポンスインターセプター追加
client.axios.interceptors.response.use(
  (response) => {
    console.log('Response:', response.status);
    return response;
  }
);
```

### イベント駆動アーキテクチャ

```typescript
// すべてのWebSocketメッセージを監視
client.on('ws:message', ({ endpoint, message }) => {
  // ログ記録、分析など
  analytics.track('websocket_message', {
    endpoint,
    type: message.type
  });
});

// 特定のイベントに反応
client.on('ws:dispatch_request', async (data) => {
  // 自動応答
  await client.voiceDispatch.confirm(data.dispatch_id);
});
```

---

## パフォーマンス最適化

### 接続プーリング

SDKは内部でAxiosの接続プーリングを使用しています：

```typescript
const client = new Mobi360Client({
  timeout: 30000,  // 適切なタイムアウト設定
  retryAttempts: 3 // 信頼性の向上
});
```

### WebSocket再接続

WebSocket接続が切断された場合の再接続パターン：

```typescript
function connectWithRetry(endpoint: string, id: string, maxRetries = 3) {
  let retries = 0;
  
  function connect() {
    const ws = client.ws.connect(endpoint, id);
    
    client.once('ws:close', ({ endpoint: e, id: i }) => {
      if (e === endpoint && i === id && retries < maxRetries) {
        retries++;
        setTimeout(() => connect(), 1000 * retries);
      }
    });
  }
  
  connect();
}
```

---

## トラブルシューティング

### CORS エラー

ブラウザからAPIを直接呼び出す場合：

```typescript
// プロキシサーバー経由での接続
const client = new Mobi360Client({
  baseUrl: '/api' // プロキシ設定
});
```

### 認証エラー

```typescript
// トークンの手動設定
client.setAuthToken('your-jwt-token');

// または環境変数から
const client = new Mobi360Client({
  apiKey: process.env.MOBI360_API_KEY
});
```

### WebSocket接続エラー

```typescript
client.on('ws:error', ({ endpoint, error }) => {
  console.error(`WebSocket error on ${endpoint}:`, error);
  // 再接続ロジック
});
```

---

## サポート

- 📧 Email: support@mobility360.jp
- 💬 Slack: #mobility360-sdk
- 📚 GitHub: https://github.com/mobility360/sdk-typescript
- 🌐 API Docs: https://mobility-ops-360-api.yukihamada.workers.dev/docs