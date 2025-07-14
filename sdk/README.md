# Mobility Ops 360 SDK for TypeScript

タクシー業界DXを実現するMobility Ops 360 APIの公式TypeScript SDKです。

## 🚀 インストール

```bash
npm install @mobi360/sdk
# または
yarn add @mobi360/sdk
# または
pnpm add @mobi360/sdk
```

## 📖 使い方

### 基本的な使い方

```typescript
import { Mobi360Client } from '@mobi360/sdk';

// クライアントの初期化
const client = new Mobi360Client({
  baseUrl: 'https://mobility-ops-360-api.yukihamada.workers.dev', // デフォルト
  apiKey: 'your-api-key', // オプション
  timeout: 30000, // タイムアウト（ミリ秒）
  debug: true // デバッグモード
});

// ヘルスチェック
const health = await client.health();
console.log(health); // { success: true, status: 'healthy', timestamp: '...' }
```

### 認証

```typescript
// 会社登録
const companyResult = await client.auth.registerCompany({
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

// ログイン
const loginResult = await client.auth.login({
  email: 'demo@example.com',
  password: 'password123'
});

// トークンは自動的にセットされますが、手動でも設定可能
client.setAuthToken(loginResult.data.token);

// トークン検証
const verifyResult = await client.auth.verify();

// トークンリフレッシュ
const refreshResult = await client.auth.refresh();
```

### ドライバー管理

```typescript
// ドライバー登録
const driverResult = await client.auth.registerDriver({
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

// 位置情報更新
await client.drivers.updateLocation('driver_id', {
  latitude: 35.6762,
  longitude: 139.6503,
  heading: 45.0,
  speed: 30.5,
  accuracy: 5.0
});

// 近くのドライバー検索
const nearbyDrivers = await client.drivers.getNearby(35.6762, 139.6503, 5.0);

// ドライバー詳細取得
const driver = await client.drivers.getById('driver_id');

// ドライバー一覧
const driverList = await client.drivers.list({
  page: 1,
  limit: 20,
  sortBy: 'created_at',
  sortOrder: 'desc'
});
```

### AI音声配車

```typescript
// 配車リクエスト作成
const dispatchResult = await client.voiceDispatch.create({
  customerName: '田中太郎',
  customerPhone: '090-1234-5678',
  pickupLocation: '新宿駅東口',
  destination: '渋谷駅',
  vehicleType: 'standard'
});

// 配車詳細取得
const dispatch = await client.voiceDispatch.getById(dispatchResult.data.dispatchId);

// 配車確定
await client.voiceDispatch.confirm(dispatchResult.data.dispatchId);

// 配車一覧
const dispatchList = await client.voiceDispatch.list();
```

### リアルタイム配車

```typescript
// リアルタイム配車作成
const realtimeResult = await client.realtimeDispatch.create({
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
  customer_phone: '090-1234-5678'
});
```

### WebSocket接続

```typescript
// 汎用WebSocket接続
const ws = client.ws.connect('general', 'driver_id');

// イベントリスナー
client.on('ws:open', ({ endpoint, id }) => {
  console.log(`WebSocket connected: ${endpoint} ${id}`);
});

client.on('ws:message', ({ endpoint, id, message }) => {
  console.log('Received:', message);
});

client.on('ws:location_broadcast', (data) => {
  console.log('Location update:', data);
});

// メッセージ送信
client.ws.send('general', {
  type: 'location_update',
  location: {
    latitude: 35.6762,
    longitude: 139.6503
  }
}, 'driver_id');

// ドライバー専用WebSocket
const driverWs = client.ws.connect('driver', 'driver_123');

// 配車追跡用WebSocket
const dispatchWs = client.ws.connect('dispatch', 'dispatch_456');

// 切断
client.ws.disconnect('general', 'driver_id');
client.ws.disconnectAll();
```

### ダッシュボード

```typescript
// 統計情報取得
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

// 最近の登録
const recent = await client.dashboard.recentRegistrations();
```

### データエクスポート

```typescript
// ドライバーデータのエクスポート（CSV）
const driversCSV = await client.export.drivers({
  format: 'csv',
  startDate: '2024-01-01',
  endDate: '2024-12-31'
});

// ブラウザでダウンロード
const url = URL.createObjectURL(driversCSV);
const a = document.createElement('a');
a.href = url;
a.download = 'drivers.csv';
a.click();

// 配車履歴のエクスポート（PDF）
const dispatchesPDF = await client.export.dispatches({
  format: 'pdf',
  startDate: '2024-01-01',
  endDate: '2024-12-31'
});
```

### 監視・ログ

```typescript
// メトリクス取得（Prometheus形式）
const metrics = await client.monitoring.metrics();
console.log(metrics);

// ログ取得
const logs = await client.monitoring.logs('error', 100);
```

### エラーハンドリング

```typescript
try {
  const result = await client.auth.login({
    email: 'test@example.com',
    password: 'wrong-password'
  });
} catch (error) {
  if (axios.isAxiosError(error)) {
    console.error('API Error:', error.response?.data);
    // {
    //   success: false,
    //   error: 'Authentication failed',
    //   message: 'Invalid email or password'
    // }
  }
}
```

### TypeScript型定義

このSDKは完全なTypeScript型定義を提供しています：

```typescript
import type {
  ApiResponse,
  CompanyRegistration,
  DriverRegistration,
  VoiceDispatch,
  NearbyDriver,
  WebSocketMessage
} from '@mobi360/sdk';
```

## 🔧 設定オプション

| オプション | 型 | デフォルト | 説明 |
|----------|---|---------|------|
| `baseUrl` | string | `https://mobility-ops-360-api.yukihamada.workers.dev` | APIのベースURL |
| `apiKey` | string | - | APIキー（オプション） |
| `timeout` | number | 30000 | タイムアウト（ミリ秒） |
| `retryAttempts` | number | 3 | リトライ回数 |
| `retryDelay` | number | 1000 | リトライ間隔（ミリ秒） |
| `debug` | boolean | false | デバッグモード |

## 📚 詳細ドキュメント

- [API仕様書](https://mobility-ops-360-api.yukihamada.workers.dev/docs)
- [GitHub](https://github.com/mobility360/sdk-typescript)

## 📄 ライセンス

MIT License

## 🤝 コントリビューション

プルリクエストを歓迎します。大きな変更の場合は、まずissueを作成して変更内容について議論してください。

## 📞 サポート

- Email: support@mobility360.jp
- Slack: #mobility360-sdk