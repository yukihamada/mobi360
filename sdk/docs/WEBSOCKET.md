# Mobility Ops 360 SDK - WebSocket通信ガイド

## 📡 リアルタイム通信の実装

Mobility Ops 360は3種類のWebSocket接続を提供し、リアルタイムでの位置追跡、配車管理、ステータス更新を可能にします。

## 接続タイプ

### 1. 汎用WebSocket (`/websocket`)

すべてのクライアント向けの汎用接続。主に管理画面やモニタリング用途で使用。

```typescript
const ws = client.ws.connect('general');
```

### 2. ドライバー専用WebSocket (`/ws/driver/{driverId}`)

特定のドライバー向けの専用接続。配車リクエストの受信や位置情報の送信に使用。

```typescript
const ws = client.ws.connect('driver', 'driver_123');
```

### 3. 配車追跡用WebSocket (`/ws/dispatch/{dispatchId}`)

特定の配車を追跡するための接続。顧客やオペレーター向け。

```typescript
const ws = client.ws.connect('dispatch', 'dispatch_456');
```

---

## 基本的な使い方

### 接続の確立

```typescript
import { Mobi360Client } from '@mobi360/sdk';

const client = new Mobi360Client({
  debug: true // デバッグログを有効化
});

// 認証
await client.auth.login({
  email: 'driver@example.com',
  password: 'password123'
});

// WebSocket接続
const ws = client.ws.connect('driver', 'driver_123');
```

### イベントハンドリング

```typescript
// 接続成功
client.on('ws:open', ({ endpoint, id }) => {
  console.log(`WebSocket接続成功: ${endpoint} (ID: ${id})`);
});

// メッセージ受信（すべてのメッセージ）
client.on('ws:message', ({ endpoint, id, message }) => {
  console.log('受信:', message);
});

// 特定のメッセージタイプ
client.on('ws:dispatch_request', (data) => {
  console.log('新しい配車リクエスト:', data);
});

// エラー処理
client.on('ws:error', ({ endpoint, id, error }) => {
  console.error('WebSocketエラー:', error);
});

// 切断
client.on('ws:close', ({ endpoint, id }) => {
  console.log('WebSocket切断:', endpoint);
});
```

---

## メッセージタイプ

### 汎用WebSocket メッセージ

#### 認証メッセージ（送信）
```typescript
client.ws.send('general', {
  type: 'auth',
  driver_id: 'driver_123'
});
```

#### 位置情報更新（送信）
```typescript
client.ws.send('general', {
  type: 'location_update',
  location: {
    latitude: 35.6762,
    longitude: 139.6503,
    heading: 45.0,
    speed: 30.5,
    accuracy: 5.0
  }
}, 'driver_123');
```

#### ステータス更新（送信）
```typescript
client.ws.send('general', {
  type: 'status_update',
  status: 'available' // 'available' | 'busy' | 'offline'
}, 'driver_123');
```

#### 位置情報ブロードキャスト（受信）
```typescript
client.on('ws:location_broadcast', (data) => {
  console.log(`ドライバー ${data.driver_id} の位置:`, {
    lat: data.location.latitude,
    lng: data.location.longitude
  });
});
```

### ドライバー専用WebSocket メッセージ

#### 配車リクエスト（受信）
```typescript
client.on('ws:dispatch_request', (data) => {
  console.log('配車リクエスト受信:', {
    dispatchId: data.dispatch_id,
    customer: data.customer_name,
    pickup: data.pickup_location
  });
  
  // 自動承諾の例
  client.ws.send('driver', {
    type: 'dispatch_response',
    dispatch_id: data.dispatch_id,
    accept: true
  }, 'driver_123');
});
```

#### 配車キャンセル（受信）
```typescript
client.on('ws:dispatch_cancelled', (data) => {
  console.log('配車がキャンセルされました:', data.dispatch_id);
});
```

### 配車追跡用WebSocket メッセージ

#### ドライバー位置更新（受信）
```typescript
client.on('ws:driver_location_update', (data) => {
  console.log('ドライバーの現在位置:', {
    lat: data.latitude,
    lng: data.longitude,
    到着予定: `${data.estimated_arrival}分`
  });
});
```

#### 配車ステータス更新（受信）
```typescript
client.on('ws:dispatch_status_update', (data) => {
  console.log('配車ステータス:', data.status);
  // 'confirmed' | 'driver_assigned' | 'driver_arrived' | 'in_progress' | 'completed'
});
```

---

## 実装例

### 例1: ドライバー用リアルタイムアプリ

```typescript
class DriverApp {
  private client: Mobi360Client;
  private driverId: string;
  private locationInterval: NodeJS.Timer;

  constructor(driverId: string) {
    this.driverId = driverId;
    this.client = new Mobi360Client();
  }

  async connect() {
    // ログイン
    await this.client.auth.login({
      email: 'driver@example.com',
      password: 'password'
    });

    // WebSocket接続
    const ws = this.client.ws.connect('driver', this.driverId);

    // イベントハンドラー設定
    this.setupEventHandlers();

    // 位置情報の定期送信開始
    this.startLocationTracking();
  }

  private setupEventHandlers() {
    // 接続成功
    this.client.on('ws:open', () => {
      console.log('✅ サーバーに接続しました');
      this.updateStatus('available');
    });

    // 配車リクエスト
    this.client.on('ws:dispatch_request', async (data) => {
      console.log('📞 新しい配車リクエスト:', data);
      
      // UIに表示（実装は省略）
      const accepted = await this.showDispatchDialog(data);
      
      // 応答を送信
      this.client.ws.send('driver', {
        type: 'dispatch_response',
        dispatch_id: data.dispatch_id,
        accept: accepted
      }, this.driverId);

      if (accepted) {
        this.updateStatus('busy');
      }
    });

    // エラー処理
    this.client.on('ws:error', (error) => {
      console.error('❌ エラー:', error);
    });

    // 切断処理
    this.client.on('ws:close', () => {
      console.log('🔌 接続が切断されました');
      // 再接続ロジック
      setTimeout(() => this.connect(), 5000);
    });
  }

  private startLocationTracking() {
    // 5秒ごとに位置情報を送信
    this.locationInterval = setInterval(async () => {
      const location = await this.getCurrentLocation();
      
      // HTTP APIで更新
      await this.client.drivers.updateLocation(this.driverId, location);
      
      // WebSocketでも配信
      this.client.ws.send('driver', {
        type: 'location_update',
        location
      }, this.driverId);
    }, 5000);
  }

  private updateStatus(status: 'available' | 'busy' | 'offline') {
    this.client.ws.send('driver', {
      type: 'status_update',
      status
    }, this.driverId);
  }

  private async getCurrentLocation() {
    // 実際のGPS取得処理（ブラウザAPI or ネイティブ）
    return {
      latitude: 35.6762 + Math.random() * 0.01,
      longitude: 139.6503 + Math.random() * 0.01,
      heading: Math.random() * 360,
      speed: Math.random() * 60,
      accuracy: 5.0
    };
  }

  private async showDispatchDialog(data: any): Promise<boolean> {
    // UIダイアログ表示（実装は省略）
    return true;
  }

  disconnect() {
    clearInterval(this.locationInterval);
    this.client.disconnect();
  }
}

// 使用例
const app = new DriverApp('driver_123');
app.connect();
```

### 例2: 配車追跡画面

```typescript
class DispatchTracker {
  private client: Mobi360Client;
  private dispatchId: string;
  private map: any; // Google Maps等のインスタンス

  constructor(dispatchId: string) {
    this.dispatchId = dispatchId;
    this.client = new Mobi360Client();
  }

  async startTracking() {
    // 配車情報を取得
    const dispatch = await this.client.voiceDispatch.getById(this.dispatchId);
    console.log('配車情報:', dispatch.data);

    // WebSocket接続
    const ws = this.client.ws.connect('dispatch', this.dispatchId);

    // ドライバー位置更新
    this.client.on('ws:driver_location_update', (data) => {
      this.updateDriverMarker(data.latitude, data.longitude);
      this.updateETA(data.estimated_arrival);
    });

    // ステータス更新
    this.client.on('ws:dispatch_status_update', (data) => {
      this.updateStatus(data.status);
      
      if (data.status === 'completed') {
        this.showCompletionDialog();
        this.client.ws.disconnect('dispatch', this.dispatchId);
      }
    });
  }

  private updateDriverMarker(lat: number, lng: number) {
    // 地図上のマーカーを更新
    console.log('ドライバー位置更新:', { lat, lng });
  }

  private updateETA(minutes: number) {
    console.log(`到着予定時間: ${minutes}分`);
  }

  private updateStatus(status: string) {
    console.log(`ステータス: ${status}`);
  }

  private showCompletionDialog() {
    console.log('🎉 配車が完了しました！');
  }
}

// 使用例
const tracker = new DispatchTracker('dispatch_456');
tracker.startTracking();
```

### 例3: 管理画面（全体監視）

```typescript
class AdminDashboard {
  private client: Mobi360Client;
  private activeDrivers: Map<string, any> = new Map();

  constructor() {
    this.client = new Mobi360Client();
  }

  async connect() {
    // 管理者としてログイン
    await this.client.auth.login({
      email: 'admin@example.com',
      password: 'admin-password'
    });

    // 汎用WebSocket接続
    const ws = this.client.ws.connect('general');

    // すべての位置情報更新を監視
    this.client.on('ws:location_broadcast', (data) => {
      this.activeDrivers.set(data.driver_id, {
        location: data.location,
        timestamp: data.timestamp
      });
      
      this.updateMap();
      this.updateStats();
    });

    // 初期データ取得
    await this.loadInitialData();
  }

  private async loadInitialData() {
    // ダッシュボード統計
    const stats = await this.client.dashboard.stats();
    console.log('システム統計:', stats.data);

    // アクティブドライバー一覧
    const drivers = await this.client.drivers.list({
      page: 1,
      limit: 100
    });
    
    drivers.data.data.forEach(driver => {
      if (driver.status === 'available' || driver.status === 'busy') {
        this.activeDrivers.set(driver.id, driver);
      }
    });

    this.updateMap();
  }

  private updateMap() {
    console.log(`アクティブドライバー数: ${this.activeDrivers.size}`);
    // 地図上に全ドライバーを表示
    this.activeDrivers.forEach((driver, id) => {
      console.log(`Driver ${id}:`, driver.location);
    });
  }

  private updateStats() {
    const available = Array.from(this.activeDrivers.values())
      .filter(d => d.status === 'available').length;
    const busy = this.activeDrivers.size - available;
    
    console.log(`待機中: ${available}, 稼働中: ${busy}`);
  }
}

// 使用例
const dashboard = new AdminDashboard();
dashboard.connect();
```

---

## ベストプラクティス

### 1. 再接続の実装

```typescript
class ReconnectingWebSocket {
  private maxRetries = 5;
  private retryDelay = 1000;
  private retryCount = 0;

  connect() {
    const ws = this.client.ws.connect('driver', this.driverId);

    this.client.on('ws:close', () => {
      if (this.retryCount < this.maxRetries) {
        this.retryCount++;
        const delay = this.retryDelay * Math.pow(2, this.retryCount - 1);
        console.log(`再接続を試みます (${this.retryCount}/${this.maxRetries}) ${delay}ms後...`);
        
        setTimeout(() => this.connect(), delay);
      } else {
        console.error('再接続の最大試行回数に達しました');
      }
    });

    this.client.on('ws:open', () => {
      this.retryCount = 0; // リセット
      console.log('接続成功');
    });
  }
}
```

### 2. ハートビート実装

```typescript
class HeartbeatWebSocket {
  private heartbeatInterval: NodeJS.Timer;

  startHeartbeat() {
    // 30秒ごとにping送信
    this.heartbeatInterval = setInterval(() => {
      this.client.ws.send('general', {
        type: 'ping',
        timestamp: new Date().toISOString()
      });
    }, 30000);

    // pong応答を確認
    this.client.on('ws:pong', () => {
      console.log('サーバーからの応答確認');
    });
  }

  stopHeartbeat() {
    clearInterval(this.heartbeatInterval);
  }
}
```

### 3. メッセージキューイング

```typescript
class QueuedWebSocket {
  private messageQueue: any[] = [];
  private isConnected = false;

  constructor() {
    this.client.on('ws:open', () => {
      this.isConnected = true;
      this.flushQueue();
    });

    this.client.on('ws:close', () => {
      this.isConnected = false;
    });
  }

  send(message: any) {
    if (this.isConnected) {
      this.client.ws.send('general', message);
    } else {
      console.log('オフライン: メッセージをキューに追加');
      this.messageQueue.push(message);
    }
  }

  private flushQueue() {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      this.client.ws.send('general', message);
    }
  }
}
```

---

## トラブルシューティング

### 接続できない場合

1. **認証を確認**
   ```typescript
   // トークンが有効か確認
   const verified = await client.auth.verify();
   if (!verified.data.valid) {
     await client.auth.refresh();
   }
   ```

2. **ネットワーク状態を確認**
   ```typescript
   if (!navigator.onLine) {
     console.error('インターネット接続がありません');
   }
   ```

3. **デバッグモードで詳細確認**
   ```typescript
   const client = new Mobi360Client({ debug: true });
   ```

### メッセージが受信できない場合

1. **イベントリスナーの登録タイミング**
   ```typescript
   // 接続前にリスナーを登録
   client.on('ws:message', handler);
   const ws = client.ws.connect('general'); // この後で接続
   ```

2. **メッセージタイプの確認**
   ```typescript
   client.on('ws:message', ({ message }) => {
     console.log('メッセージタイプ:', message.type);
   });
   ```

---

## パフォーマンス最適化

### バッチ送信

```typescript
class BatchedLocationUpdates {
  private batch: any[] = [];
  private batchSize = 10;
  private batchInterval = 5000;

  startBatching() {
    setInterval(() => {
      if (this.batch.length > 0) {
        this.client.ws.send('general', {
          type: 'location_batch',
          updates: this.batch
        });
        this.batch = [];
      }
    }, this.batchInterval);
  }

  addLocation(location: any) {
    this.batch.push({
      timestamp: new Date().toISOString(),
      ...location
    });

    if (this.batch.length >= this.batchSize) {
      this.flush();
    }
  }

  private flush() {
    // 即座に送信
  }
}
```

---

## 🔗 関連リンク

- [完全なAPIリファレンス](./API.md)
- [クイックスタートガイド](./QUICKSTART.md)
- [サンプルコード](../examples/)
- [APIドキュメント](https://mobility-ops-360-api.yukihamada.workers.dev/docs)