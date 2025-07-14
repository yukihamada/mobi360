/**
 * ドライバーリアルタイム位置追跡用 Durable Object
 * WebSocketを使用してリアルタイム位置情報を管理
 */
export class DriverTracker {
  constructor(state, env) {
    this.state = state;
    this.env = env;
    this.sessions = new Map(); // WebSocketセッション管理
    this.driverLocations = new Map(); // ドライバー位置情報キャッシュ
    this.lastUpdateTime = new Map(); // 最終更新時刻
  }

  /**
   * HTTPリクエストを処理
   */
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;

    switch (path) {
      case '/websocket':
        return this.handleWebSocket(request);
      case '/location':
        return this.handleLocationUpdate(request);
      case '/status':
        return this.getDriverStatus(request);
      case '/nearby':
        return this.getNearbyDrivers(request);
      default:
        return new Response('Not Found', { status: 404 });
    }
  }

  /**
   * WebSocket接続を処理
   */
  async handleWebSocket(request) {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const webSocketPair = new WebSocketPair();
    const [client, server] = Object.values(webSocketPair);

    server.accept();

    // セッション管理
    const sessionId = crypto.randomUUID();
    let driverId = null;

    server.addEventListener('message', async (event) => {
      try {
        const data = JSON.parse(event.data);
        
        switch (data.type) {
          case 'auth':
            driverId = data.driver_id;
            if (driverId) {
              this.sessions.set(sessionId, {
                websocket: server,
                driver_id: driverId,
                connected_at: new Date().toISOString()
              });
              
              server.send(JSON.stringify({
                type: 'auth_success',
                session_id: sessionId
              }));
            }
            break;

          case 'location_update':
            if (driverId) {
              await this.updateDriverLocation(driverId, data.location);
              
              // 他のクライアントに位置情報を配信
              await this.broadcastLocationUpdate(driverId, data.location);
            }
            break;

          case 'status_update':
            if (driverId) {
              await this.updateDriverStatus(driverId, data.status);
            }
            break;

          default:
            console.warn('Unknown message type:', data.type);
        }
      } catch (error) {
        console.error('WebSocket message error:', error);
        server.send(JSON.stringify({
          type: 'error',
          message: 'Invalid message format'
        }));
      }
    });

    server.addEventListener('close', () => {
      this.sessions.delete(sessionId);
      if (driverId) {
        this.cleanupDriverData(driverId);
      }
    });

    return new Response(null, {
      status: 101,
      webSocket: client
    });
  }

  /**
   * HTTP経由での位置情報更新
   */
  async handleLocationUpdate(request) {
    try {
      if (request.method !== 'POST') {
        return new Response('Method Not Allowed', { status: 405 });
      }

      const data = await request.json();
      const { driver_id, location } = data;

      if (!driver_id || !location) {
        return new Response('Missing driver_id or location', { status: 400 });
      }

      await this.updateDriverLocation(driver_id, location);
      await this.broadcastLocationUpdate(driver_id, location);

      return new Response(JSON.stringify({
        success: true,
        message: '位置情報を更新しました'
      }), {
        headers: { 'Content-Type': 'application/json' }
      });
    } catch (error) {
      console.error('Location update error:', error);
      return new Response(JSON.stringify({
        success: false,
        error: error.message
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      });
    }
  }

  /**
   * ドライバーステータスを取得
   */
  async getDriverStatus(request) {
    try {
      const url = new URL(request.url);
      const driverId = url.searchParams.get('driver_id');

      if (!driverId) {
        return new Response('Missing driver_id', { status: 400 });
      }

      const location = this.driverLocations.get(driverId);
      const lastUpdate = this.lastUpdateTime.get(driverId);

      return new Response(JSON.stringify({
        success: true,
        driver_id: driverId,
        location: location || null,
        last_update: lastUpdate || null,
        is_online: this.isDriverOnline(driverId)
      }), {
        headers: { 'Content-Type': 'application/json' }
      });
    } catch (error) {
      console.error('Get driver status error:', error);
      return new Response(JSON.stringify({
        success: false,
        error: error.message
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      });
    }
  }

  /**
   * 近くのドライバーを取得
   */
  async getNearbyDrivers(request) {
    try {
      const url = new URL(request.url);
      const lat = parseFloat(url.searchParams.get('lat'));
      const lng = parseFloat(url.searchParams.get('lng'));
      const radius = parseFloat(url.searchParams.get('radius') || '5');

      if (isNaN(lat) || isNaN(lng)) {
        return new Response('Invalid lat/lng parameters', { status: 400 });
      }

      const nearbyDrivers = [];
      const now = new Date();

      for (const [driverId, location] of this.driverLocations.entries()) {
        const lastUpdate = this.lastUpdateTime.get(driverId);
        
        // 5分以内に更新されたドライバーのみ
        if (lastUpdate && (now - new Date(lastUpdate)) < 5 * 60 * 1000) {
          const distance = this.calculateDistance(lat, lng, location.latitude, location.longitude);
          
          if (distance <= radius) {
            nearbyDrivers.push({
              driver_id: driverId,
              location: location,
              distance: distance,
              last_update: lastUpdate
            });
          }
        }
      }

      // 距離でソート
      nearbyDrivers.sort((a, b) => a.distance - b.distance);

      return new Response(JSON.stringify({
        success: true,
        drivers: nearbyDrivers,
        count: nearbyDrivers.length
      }), {
        headers: { 'Content-Type': 'application/json' }
      });
    } catch (error) {
      console.error('Get nearby drivers error:', error);
      return new Response(JSON.stringify({
        success: false,
        error: error.message
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      });
    }
  }

  /**
   * ドライバーの位置情報を更新
   */
  async updateDriverLocation(driverId, location) {
    try {
      const timestamp = new Date().toISOString();
      
      // メモリキャッシュを更新
      this.driverLocations.set(driverId, {
        ...location,
        timestamp: timestamp
      });
      this.lastUpdateTime.set(driverId, timestamp);

      // Durable Object Storageに永続化
      await this.state.storage.put(`location:${driverId}`, {
        ...location,
        timestamp: timestamp
      });

      // D1データベースにも記録（バックアップ用）
      try {
        await this.env.D1_MOBI360_DB.prepare(`
          INSERT OR REPLACE INTO driver_locations (
            driver_id, latitude, longitude, heading, speed, accuracy, timestamp
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
        `).bind(
          driverId,
          location.latitude,
          location.longitude,
          location.heading || 0,
          location.speed || 0,
          location.accuracy || 0,
          timestamp
        ).run();
      } catch (dbError) {
        console.warn('D1 update failed, but cache updated:', dbError);
      }
    } catch (error) {
      console.error('Update driver location error:', error);
      throw error;
    }
  }

  /**
   * ドライバーステータスを更新
   */
  async updateDriverStatus(driverId, status) {
    try {
      const timestamp = new Date().toISOString();
      
      // Durable Object Storageに保存
      await this.state.storage.put(`status:${driverId}`, {
        status: status,
        timestamp: timestamp
      });

      // D1データベースにも記録
      try {
        await this.env.D1_MOBI360_DB.prepare(`
          UPDATE drivers SET status = ?, updated_at = ? WHERE id = ?
        `).bind(status, timestamp, driverId).run();
      } catch (dbError) {
        console.warn('D1 status update failed:', dbError);
      }
    } catch (error) {
      console.error('Update driver status error:', error);
      throw error;
    }
  }

  /**
   * 位置情報更新を他のクライアントにブロードキャスト
   */
  async broadcastLocationUpdate(driverId, location) {
    const message = JSON.stringify({
      type: 'location_broadcast',
      driver_id: driverId,
      location: location,
      timestamp: new Date().toISOString()
    });

    // 管理者・監視クライアントに配信
    for (const [sessionId, session] of this.sessions.entries()) {
      if (session.driver_id !== driverId) { // 自分以外に配信
        try {
          session.websocket.send(message);
        } catch (error) {
          console.warn('Failed to send broadcast to session:', sessionId, error);
          this.sessions.delete(sessionId);
        }
      }
    }
  }

  /**
   * ドライバーがオンラインかどうか確認
   */
  isDriverOnline(driverId) {
    const lastUpdate = this.lastUpdateTime.get(driverId);
    if (!lastUpdate) return false;

    const now = new Date();
    const updateTime = new Date(lastUpdate);
    const diffMinutes = (now - updateTime) / (1000 * 60);

    return diffMinutes <= 5; // 5分以内の更新でオンライン判定
  }

  /**
   * 距離計算（ハーバーサイン公式）
   */
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // 地球の半径（km）
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  /**
   * 度をラジアンに変換
   */
  toRad(degrees) {
    return degrees * (Math.PI / 180);
  }

  /**
   * ドライバーデータのクリーンアップ
   */
  cleanupDriverData(driverId) {
    this.driverLocations.delete(driverId);
    this.lastUpdateTime.delete(driverId);
  }

  /**
   * アラーム処理（定期実行）
   */
  async alarm() {
    try {
      const now = new Date();
      
      // 古い位置情報をクリーンアップ（30分以上更新されていないもの）
      for (const [driverId, lastUpdate] of this.lastUpdateTime.entries()) {
        const updateTime = new Date(lastUpdate);
        const diffMinutes = (now - updateTime) / (1000 * 60);
        
        if (diffMinutes > 30) {
          this.cleanupDriverData(driverId);
        }
      }

      // 次回のアラームを設定（5分後）
      const nextAlarm = new Date(now.getTime() + 5 * 60 * 1000);
      await this.state.storage.setAlarm(nextAlarm);
    } catch (error) {
      console.error('Alarm processing error:', error);
    }
  }
}