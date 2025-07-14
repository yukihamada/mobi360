import { describe, test, expect, beforeAll, afterAll } from '@jest/globals';
import axios from 'axios';

const API_BASE_URL = process.env.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev';
const TEST_TIMEOUT = 30000;

// テストユーザー情報
const testCompany = {
  companyName: `テストタクシー${Date.now()}`,
  companyAddress: '東京都新宿区西新宿1-1-1',
  companyPhone: '03-1234-5678',
  licenseNumber: '関自旅二第1234号',
  representativeName: 'テスト代表',
  representativeEmail: `test${Date.now()}@example.com`,
  serviceArea: '東京都23区内',
  vehicleCount: '10',
  driverCount: '5',
  selectedPlan: 'standard'
};

const testDriver = {
  name: `テストドライバー${Date.now()}`,
  phone: '090-1234-5678',
  email: `driver${Date.now()}@example.com`,
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
  accountHolder: 'テストドライバー'
};

let authToken = null;
let companyId = null;
let driverId = null;
let dispatchId = null;

describe('Mobility Ops 360 API E2E Tests', () => {
  // 1. ヘルスチェック
  describe('Health Check', () => {
    test('GET /health should return healthy status', async () => {
      const response = await axios.get(`${API_BASE_URL}/health`);
      expect(response.status).toBe(200);
      expect(response.data.status).toBe('healthy');
    }, TEST_TIMEOUT);

    test('GET /docs should return Swagger UI', async () => {
      const response = await axios.get(`${API_BASE_URL}/docs`);
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('text/html');
    }, TEST_TIMEOUT);

    test('GET /api/openapi.yaml should return OpenAPI spec', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/openapi.yaml`);
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('yaml');
    }, TEST_TIMEOUT);
  });

  // 2. 認証・登録
  describe('Authentication & Registration', () => {
    test('POST /auth/register/company should register a new company', async () => {
      const response = await axios.post(`${API_BASE_URL}/auth/register/company`, testCompany);
      expect(response.status).toBe(201);
      expect(response.data.success).toBe(true);
      expect(response.data.data.companyId).toBeTruthy();
      companyId = response.data.data.companyId;
    }, TEST_TIMEOUT);

    test('POST /auth/register/driver should register a new driver', async () => {
      const response = await axios.post(`${API_BASE_URL}/auth/register/driver`, testDriver);
      expect(response.status).toBe(201);
      expect(response.data.success).toBe(true);
      expect(response.data.data.driverId).toBeTruthy();
      driverId = response.data.data.driverId;
    }, TEST_TIMEOUT);

    test('POST /auth/login should authenticate user', async () => {
      const response = await axios.post(`${API_BASE_URL}/auth/login`, {
        email: testCompany.representativeEmail,
        password: 'test1234' // デフォルトパスワード
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.token).toBeTruthy();
      authToken = response.data.token;
    }, TEST_TIMEOUT);

    test('GET /auth/verify should verify token', async () => {
      const response = await axios.get(`${API_BASE_URL}/auth/verify`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
    }, TEST_TIMEOUT);

    test('POST /auth/refresh should refresh token', async () => {
      const response = await axios.post(`${API_BASE_URL}/auth/refresh`, {
        token: authToken
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.token).toBeTruthy();
    }, TEST_TIMEOUT);
  });

  // 3. ダッシュボード
  describe('Dashboard', () => {
    test('GET /api/dashboard/stats should return statistics', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/dashboard/stats`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.data).toHaveProperty('companies');
      expect(response.data.data).toHaveProperty('drivers');
    }, TEST_TIMEOUT);

    test('GET /api/dashboard/recent-registrations should return recent data', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/dashboard/recent-registrations`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.data).toHaveProperty('companies');
      expect(response.data.data).toHaveProperty('drivers');
    }, TEST_TIMEOUT);
  });

  // 4. ドライバー管理
  describe('Driver Management', () => {
    test('POST /api/drivers/location should update driver location', async () => {
      const response = await axios.post(`${API_BASE_URL}/api/drivers/location`, {
        driver_id: driverId,
        latitude: 35.6762,
        longitude: 139.6503,
        heading: 45.0,
        speed: 30.5,
        accuracy: 5.0
      }, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
    }, TEST_TIMEOUT);

    test('GET /api/nearby-drivers should return nearby drivers', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/nearby-drivers`, {
        params: {
          lat: 35.6762,
          lng: 139.6503,
          radius: 5.0
        },
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(Array.isArray(response.data.drivers)).toBe(true);
    }, TEST_TIMEOUT);

    test('GET /api/drivers/:driverId should return driver details', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/drivers/${driverId}`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.driver).toBeTruthy();
    }, TEST_TIMEOUT);

    test('GET /api/drivers should return driver list', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/drivers`, {
        params: { page: 1, limit: 10 },
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(Array.isArray(response.data.drivers)).toBe(true);
    }, TEST_TIMEOUT);
  });

  // 5. AI音声配車
  describe('AI Voice Dispatch', () => {
    test('POST /api/voice-dispatch/create should create dispatch request', async () => {
      const response = await axios.post(`${API_BASE_URL}/api/voice-dispatch/create`, {
        customerName: '田中太郎',
        customerPhone: '090-1234-5678',
        pickupLocation: '新宿駅東口',
        destination: '渋谷駅',
        vehicleType: 'standard'
      }, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(201);
      expect(response.data.success).toBe(true);
      expect(response.data.data.dispatchId).toBeTruthy();
      dispatchId = response.data.data.dispatchId;
    }, TEST_TIMEOUT);

    test('POST /api/voice-dispatch/twiml/:dispatchId should return TwiML', async () => {
      const response = await axios.post(`${API_BASE_URL}/api/voice-dispatch/twiml/${dispatchId}`);
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('xml');
    }, TEST_TIMEOUT);

    test('GET /api/voice-dispatch/:dispatchId should return dispatch details', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/voice-dispatch/${dispatchId}`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.dispatch).toBeTruthy();
    }, TEST_TIMEOUT);

    test('GET /api/voice-dispatch/list should return dispatch list', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/voice-dispatch/list`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(Array.isArray(response.data.dispatches)).toBe(true);
    }, TEST_TIMEOUT);
  });

  // 6. リアルタイム配車
  describe('Realtime Dispatch', () => {
    test('POST /api/realtime-dispatch should create realtime dispatch', async () => {
      const response = await axios.post(`${API_BASE_URL}/api/realtime-dispatch`, {
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
      }, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(201);
      expect(response.data.success).toBe(true);
    }, TEST_TIMEOUT);
  });

  // 7. データエクスポート
  describe('Data Export', () => {
    test('GET /api/export/drivers should export driver data', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/export/drivers`, {
        params: { format: 'json' },
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('json');
    }, TEST_TIMEOUT);

    test('GET /api/export/dispatches should export dispatch data', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/export/dispatches`, {
        params: { format: 'json' },
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('json');
    }, TEST_TIMEOUT);
  });

  // 8. 監視・ログ
  describe('Monitoring & Logs', () => {
    test('GET /api/metrics should return metrics', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/metrics`);
      expect(response.status).toBe(200);
      expect(response.headers['content-type']).toContain('text/plain');
    }, TEST_TIMEOUT);

    test('GET /api/logs should return logs', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/logs`, {
        params: { level: 'info', limit: 10 },
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(Array.isArray(response.data.logs)).toBe(true);
    }, TEST_TIMEOUT);
  });

  // 9. 設定管理
  describe('Configuration', () => {
    test('GET /api/config should return configuration', async () => {
      const response = await axios.get(`${API_BASE_URL}/api/config`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
      expect(response.data.config).toBeTruthy();
    }, TEST_TIMEOUT);
  });

  // 10. データベース
  describe('Database', () => {
    test('POST /api/init-database should initialize database', async () => {
      const response = await axios.post(`${API_BASE_URL}/api/init-database`, {}, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      expect(response.status).toBe(200);
      expect(response.data.success).toBe(true);
    }, TEST_TIMEOUT);
  });
});

// WebSocketテスト（別ファイルで実装予定）
describe('WebSocket Tests', () => {
  test.skip('WebSocket connections should work', () => {
    // WebSocketテストは別途実装
  });
});