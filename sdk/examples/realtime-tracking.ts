import { Mobi360Client } from '@mobi360/sdk';

async function realtimeTracking() {
  const client = new Mobi360Client({
    debug: true
  });

  // ドライバーIDと認証トークンを設定
  const driverId = 'driver_123';
  const authToken = 'your-auth-token';
  
  client.setAuthToken(authToken);

  // ドライバー専用WebSocket接続
  const ws = client.ws.connect('driver', driverId);

  // イベントハンドラー設定
  client.on('ws:open', () => {
    console.log('Connected to driver WebSocket');
    
    // 初期位置を送信
    updateLocation();
  });

  client.on('ws:dispatch_request', (data) => {
    console.log('New dispatch request:', data);
    // 配車リクエストに対する処理
  });

  client.on('ws:error', (error) => {
    console.error('WebSocket error:', error);
  });

  // 位置情報を定期的に更新（5秒ごと）
  async function updateLocation() {
    const location = {
      latitude: 35.6762 + Math.random() * 0.01,
      longitude: 139.6503 + Math.random() * 0.01,
      heading: Math.random() * 360,
      speed: Math.random() * 60,
      accuracy: 5.0
    };

    try {
      // HTTP APIで位置更新
      await client.drivers.updateLocation(driverId, location);
      
      // WebSocketでも位置情報を配信
      client.ws.send('driver', {
        type: 'location_update',
        location
      }, driverId);

      console.log('Location updated:', location);
    } catch (error) {
      console.error('Failed to update location:', error);
    }
  }

  // 定期更新開始
  const intervalId = setInterval(updateLocation, 5000);

  // ステータス更新例
  setTimeout(async () => {
    client.ws.send('driver', {
      type: 'status_update',
      status: 'available'
    }, driverId);
    console.log('Status updated to available');
  }, 3000);

  // 60秒後にクリーンアップ
  setTimeout(() => {
    clearInterval(intervalId);
    client.disconnect();
    console.log('Tracking stopped');
  }, 60000);
}

// 実行
realtimeTracking().catch(console.error);