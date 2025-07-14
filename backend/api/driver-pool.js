import { Hono } from 'hono';
import { z } from 'zod';
import { DriverManager } from '../../components/driver_pool/driver-manager.js';
import { MatchingEngine } from '../../components/driver_pool/matching-engine.js';

const app = new Hono();

// バリデーションスキーマ
const driverRegistrationSchema = z.object({
  name: z.string().min(1, '名前は必須です'),
  email: z.string().email('有効なメールアドレスを入力してください'),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/, '有効な電話番号を入力してください'),
  license_number: z.string().min(1, '運転免許証番号は必須です'),
  vehicle_type: z.enum(['standard', 'premium', 'wheelchair'], {
    errorMap: () => ({ message: '有効な車種を選択してください' })
  }),
  vehicle_number: z.string().min(1, '車両番号は必須です'),
  vehicle_model: z.string().min(1, '車両モデルは必須です'),
  vehicle_color: z.string().min(1, '車両色は必須です')
});

const locationUpdateSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  heading: z.number().min(0).max(360).optional(),
  speed: z.number().min(0).optional(),
  accuracy: z.number().min(0).optional()
});

const statusUpdateSchema = z.object({
  status: z.enum(['available', 'busy', 'offline'], {
    errorMap: () => ({ message: '有効な稼働状況を選択してください' })
  })
});

const driverSearchSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  radius: z.number().min(0.1).max(50).default(5),
  vehicle_type: z.enum(['standard', 'premium', 'wheelchair']).optional()
});

const ratingSchema = z.object({
  rating: z.number().min(1).max(5),
  comment: z.string().optional(),
  customer_id: z.string().min(1)
});

const shiftSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, '有効な日付形式を入力してください'),
  start_time: z.string().regex(/^\d{2}:\d{2}$/, '有効な時間形式を入力してください'),
  end_time: z.string().regex(/^\d{2}:\d{2}$/, '有効な時間形式を入力してください'),
  status: z.enum(['scheduled', 'active', 'completed', 'cancelled']).default('scheduled')
});

/**
 * ドライバー登録
 */
app.post('/register', async (c) => {
  try {
    const body = await c.req.json();
    const driverData = driverRegistrationSchema.parse(body);

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.registerDriver(driverData);

    return c.json(result, 201);
  } catch (error) {
    console.error('Driver registration error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'ドライバー登録に失敗しました'
    }, 400);
  }
});

/**
 * ドライバー位置情報更新
 */
app.post('/:driverId/location', async (c) => {
  try {
    const driverId = c.req.param('driverId');
    const body = await c.req.json();
    const locationData = locationUpdateSchema.parse(body);

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.updateDriverLocation(driverId, locationData);

    return c.json(result);
  } catch (error) {
    console.error('Location update error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: '位置情報の更新に失敗しました'
    }, 400);
  }
});

/**
 * ドライバー稼働状況更新
 */
app.post('/:driverId/status', async (c) => {
  try {
    const driverId = c.req.param('driverId');
    const body = await c.req.json();
    const statusData = statusUpdateSchema.parse(body);

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.updateDriverStatus(driverId, statusData.status);

    return c.json(result);
  } catch (error) {
    console.error('Status update error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: '稼働状況の更新に失敗しました'
    }, 400);
  }
});

/**
 * 利用可能なドライバーを検索
 */
app.post('/search', async (c) => {
  try {
    const body = await c.req.json();
    const searchData = driverSearchSchema.parse(body);

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.findAvailableDrivers(
      searchData.latitude,
      searchData.longitude,
      searchData.radius,
      searchData.vehicle_type
    );

    return c.json(result);
  } catch (error) {
    console.error('Driver search error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'ドライバー検索に失敗しました'
    }, 400);
  }
});

/**
 * 最適なドライバーをマッチング
 */
app.post('/match', async (c) => {
  try {
    const body = await c.req.json();
    const { dispatch_request, available_drivers } = body;

    if (!dispatch_request || !available_drivers) {
      return c.json({
        success: false,
        error: 'dispatch_request and available_drivers are required',
        message: '配車リクエストと利用可能なドライバー情報が必要です'
      }, 400);
    }

    const matchingEngine = new MatchingEngine(c.env);
    const result = await matchingEngine.findBestMatch(dispatch_request, available_drivers);

    return c.json(result);
  } catch (error) {
    console.error('Driver matching error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'ドライバーマッチングに失敗しました'
    }, 500);
  }
});

/**
 * ドライバーの評価を更新
 */
app.post('/:driverId/rating', async (c) => {
  try {
    const driverId = c.req.param('driverId');
    const body = await c.req.json();
    const ratingData = ratingSchema.parse(body);

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.updateDriverRating(
      driverId,
      ratingData.rating,
      ratingData.comment,
      ratingData.customer_id
    );

    return c.json(result);
  } catch (error) {
    console.error('Rating update error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: '評価の更新に失敗しました'
    }, 400);
  }
});

/**
 * ドライバーの収益を更新
 */
app.post('/:driverId/earnings', async (c) => {
  try {
    const driverId = c.req.param('driverId');
    const body = await c.req.json();
    const { amount, ride_id } = body;

    if (!amount || !ride_id) {
      return c.json({
        success: false,
        error: 'amount and ride_id are required',
        message: '収益金額と配車IDが必要です'
      }, 400);
    }

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.updateDriverEarnings(driverId, amount, ride_id);

    return c.json(result);
  } catch (error) {
    console.error('Earnings update error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: '収益の更新に失敗しました'
    }, 400);
  }
});

/**
 * ドライバーの詳細情報を取得
 */
app.get('/:driverId', async (c) => {
  try {
    const driverId = c.req.param('driverId');

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.getDriverDetails(driverId);

    return c.json(result);
  } catch (error) {
    console.error('Get driver details error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'ドライバー情報の取得に失敗しました'
    }, 400);
  }
});

/**
 * ドライバーのシフト管理
 */
app.post('/:driverId/shift', async (c) => {
  try {
    const driverId = c.req.param('driverId');
    const body = await c.req.json();
    const shiftData = shiftSchema.parse(body);

    const driverManager = new DriverManager(c.env);
    const result = await driverManager.updateDriverShift(driverId, shiftData);

    return c.json(result);
  } catch (error) {
    console.error('Shift update error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'シフト情報の更新に失敗しました'
    }, 400);
  }
});

/**
 * ドライバー配置の最適化
 */
app.post('/optimize-placement', async (c) => {
  try {
    const body = await c.req.json();
    const { demand_forecast } = body;

    if (!demand_forecast) {
      return c.json({
        success: false,
        error: 'demand_forecast is required',
        message: '需要予測データが必要です'
      }, 400);
    }

    const matchingEngine = new MatchingEngine(c.env);
    const result = await matchingEngine.optimizeDriverPlacement(demand_forecast);

    return c.json(result);
  } catch (error) {
    console.error('Driver placement optimization error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'ドライバー配置最適化に失敗しました'
    }, 500);
  }
});

/**
 * マッチング性能分析
 */
app.get('/analytics/matching-performance', async (c) => {
  try {
    const days = parseInt(c.req.query('days') || '7');
    
    const matchingEngine = new MatchingEngine(c.env);
    const result = await matchingEngine.analyzeMatchingPerformance({ days });

    return c.json(result);
  } catch (error) {
    console.error('Matching performance analysis error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'マッチング性能分析に失敗しました'
    }, 500);
  }
});

/**
 * ドライバー一覧取得
 */
app.get('/', async (c) => {
  try {
    const page = parseInt(c.req.query('page') || '1');
    const limit = parseInt(c.req.query('limit') || '20');
    const status = c.req.query('status');
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        d.id, d.name, d.email, d.phone, d.vehicle_type, d.vehicle_number,
        d.status, d.rating, d.total_rides, d.total_earnings,
        dl.latitude, dl.longitude, dl.timestamp as last_location_update
      FROM drivers d
      LEFT JOIN driver_locations dl ON d.id = dl.driver_id
    `;

    let params = [];
    if (status) {
      query += ` WHERE d.status = ?`;
      params.push(status);
    }

    query += ` ORDER BY d.created_at DESC LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const results = await c.env.D1_MOBI360_DB.prepare(query).bind(...params).all();

    return c.json({
      success: true,
      drivers: results.results || [],
      pagination: {
        page: page,
        limit: limit,
        total: results.results?.length || 0
      }
    });
  } catch (error) {
    console.error('Get drivers list error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'ドライバー一覧の取得に失敗しました'
    }, 500);
  }
});

export { app as driverPoolRoutes };