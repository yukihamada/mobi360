import { Mobi360Client } from '@mobi360/sdk';

async function main() {
  // クライアントの初期化
  const client = new Mobi360Client({
    baseUrl: 'https://mobility-ops-360-api.yukihamada.workers.dev',
    debug: true
  });

  try {
    // 1. ヘルスチェック
    console.log('=== Health Check ===');
    const health = await client.health();
    console.log('System status:', health);

    // 2. 会社登録
    console.log('\n=== Company Registration ===');
    const companyResult = await client.auth.registerCompany({
      companyName: 'デモタクシー株式会社',
      companyAddress: '東京都新宿区西新宿1-1-1',
      companyPhone: '03-1234-5678',
      licenseNumber: '関自旅二第1234号',
      representativeName: '代表太郎',
      representativeEmail: `demo${Date.now()}@example.com`,
      serviceArea: '東京都23区内',
      vehicleCount: '50',
      driverCount: '25',
      selectedPlan: 'standard'
    });
    console.log('Company registered:', companyResult);

    // 3. ログイン
    console.log('\n=== Login ===');
    const loginResult = await client.auth.login({
      email: companyResult.data?.companyEmail || 'demo@example.com',
      password: 'password123'
    });
    console.log('Login successful:', loginResult);

    // 4. ダッシュボード統計
    console.log('\n=== Dashboard Stats ===');
    const stats = await client.dashboard.stats();
    console.log('Dashboard stats:', stats.data);

    // 5. 近くのドライバー検索
    console.log('\n=== Nearby Drivers ===');
    const nearbyDrivers = await client.drivers.getNearby(35.6762, 139.6503, 5.0);
    console.log(`Found ${nearbyDrivers.data?.drivers.length} nearby drivers`);

    // 6. AI音声配車作成
    console.log('\n=== Voice Dispatch ===');
    const dispatchResult = await client.voiceDispatch.create({
      customerName: '田中太郎',
      customerPhone: '090-1234-5678',
      pickupLocation: '新宿駅東口',
      destination: '渋谷駅',
      vehicleType: 'standard'
    });
    console.log('Dispatch created:', dispatchResult);

    // 7. WebSocket接続例
    console.log('\n=== WebSocket Connection ===');
    const ws = client.ws.connect('general');
    
    client.on('ws:open', () => {
      console.log('WebSocket connected');
    });

    client.on('ws:message', ({ message }) => {
      console.log('WebSocket message:', message);
    });

    // 10秒後に切断
    setTimeout(() => {
      client.ws.disconnectAll();
      console.log('WebSocket disconnected');
    }, 10000);

  } catch (error) {
    console.error('Error:', error);
  }
}

// 実行
main().catch(console.error);