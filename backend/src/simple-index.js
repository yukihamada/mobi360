import { Hono } from 'hono';
import { cors } from 'hono/cors';

const app = new Hono();

// CORS設定
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
}));

// データベース初期化API
app.post('/api/init-database', async (c) => {
  try {
    // 会社テーブル作成・初期データ
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS companies (
        id TEXT PRIMARY KEY,
        company_name TEXT NOT NULL,
        company_address TEXT,
        company_phone TEXT,
        twilio_phone_number TEXT,
        twilio_phone_sid TEXT,
        license_number TEXT,
        representative_name TEXT,
        representative_email TEXT,
        service_area TEXT,
        vehicle_count INTEGER DEFAULT 0,
        driver_count INTEGER DEFAULT 0,
        selected_plan TEXT DEFAULT 'standard',
        ai_routing_enabled INTEGER DEFAULT 1,
        operator_phone TEXT,
        status TEXT DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // ドライバーテーブル作成・初期データ
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS drivers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        birthdate TEXT,
        license_number TEXT,
        license_expiry TEXT,
        taxi_license_number TEXT,
        has_own_vehicle INTEGER DEFAULT 0,
        is_full_time INTEGER DEFAULT 1,
        working_area TEXT,
        vehicle_model TEXT,
        vehicle_year TEXT,
        vehicle_plate TEXT,
        insurance_number TEXT,
        bank_name TEXT,
        branch_name TEXT,
        account_number TEXT,
        account_holder TEXT,
        latitude REAL,
        longitude REAL,
        last_location_update DATETIME,
        is_available INTEGER DEFAULT 1,
        status TEXT DEFAULT 'active',
        company_id TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // 配車リクエストテーブル作成
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS dispatch_requests (
        id TEXT PRIMARY KEY,
        customer_name TEXT,
        customer_phone TEXT,
        pickup_location TEXT NOT NULL,
        destination TEXT NOT NULL,
        vehicle_type TEXT DEFAULT 'standard',
        status TEXT DEFAULT 'pending',
        assigned_driver_id TEXT,
        estimated_arrival INTEGER,
        fare_amount INTEGER,
        dispatch_source TEXT DEFAULT 'manual',
        priority_score INTEGER DEFAULT 0,
        pickup_time DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // 音声配車ログテーブル作成
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS voice_dispatch_logs (
        id TEXT PRIMARY KEY,
        dispatch_request_id TEXT,
        phone_number TEXT,
        transcription TEXT,
        call_status TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // ドライバー評価テーブル作成
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS driver_ratings (
        id TEXT PRIMARY KEY,
        driver_id TEXT,
        dispatch_request_id TEXT,
        rating INTEGER,
        comment TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // ドライバーパフォーマンステーブル作成
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS driver_performance (
        id TEXT PRIMARY KEY,
        driver_id TEXT,
        performance_score INTEGER DEFAULT 100,
        total_trips INTEGER DEFAULT 0,
        completion_rate REAL DEFAULT 1.0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // Twilioログテーブル作成
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS twilio_logs (
        id TEXT PRIMARY KEY,
        call_sid TEXT,
        phone_number TEXT,
        status TEXT,
        direction TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // デモ会社データ挿入
    await c.env.DB.prepare(`
      INSERT OR REPLACE INTO companies (
        id, company_name, company_address, company_phone, license_number,
        representative_name, representative_email, service_area, vehicle_count,
        driver_count, selected_plan, ai_routing_enabled, status, created_at
      ) VALUES (
        'company_demo_001', 'デモタクシー株式会社', '東京都渋谷区渋谷1-1-1', 
        '03-1234-5678', 'TAXI-2024-001', '田中太郎', 'demo@example.com',
        '東京23区', 10, 5, 'premium', 1, 'active', datetime('now')
      )
    `).run();

    // デモドライバーデータ挿入
    const driverData = [
      {
        id: 'driver_demo_001',
        name: '佐藤一郎',
        phone: '090-1234-5678',
        email: 'driver@example.com',
        vehicle_model: 'トヨタ クラウン',
        vehicle_plate: '品川 500 あ 1234',
        latitude: 35.6762,
        longitude: 139.6503,
        working_area: '渋谷・新宿・池袋'
      },
      {
        id: 'driver_demo_002', 
        name: '鈴木次郎',
        phone: '090-2345-6789',
        email: 'suzuki@example.com',
        vehicle_model: 'レクサス LS',
        vehicle_plate: '品川 500 あ 5678',
        latitude: 35.6895,
        longitude: 139.6917,
        working_area: '新宿・池袋・上野'
      },
      {
        id: 'driver_demo_003',
        name: '田中三郎',
        phone: '090-3456-7890', 
        email: 'tanaka@example.com',
        vehicle_model: 'トヨタ アルファード',
        vehicle_plate: '品川 500 あ 9012',
        latitude: 35.6584,
        longitude: 139.7016,
        working_area: '銀座・丸の内・有楽町'
      }
    ];

    for (const driver of driverData) {
      await c.env.DB.prepare(`
        INSERT OR REPLACE INTO drivers (
          id, name, phone, email, vehicle_model, vehicle_plate,
          latitude, longitude, last_location_update, is_available,
          status, working_area, is_full_time, has_own_vehicle,
          company_id, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), 1, 'active', ?, 1, 1, 'company_demo_001', datetime('now'))
      `).bind(
        driver.id, driver.name, driver.phone, driver.email,
        driver.vehicle_model, driver.vehicle_plate,
        driver.latitude, driver.longitude, driver.working_area
      ).run();
    }

    // 初期評価データ
    for (let i = 0; i < driverData.length; i++) {
      await c.env.DB.prepare(`
        INSERT OR REPLACE INTO driver_ratings (
          id, driver_id, rating, comment, created_at
        ) VALUES (?, ?, ?, ?, datetime('now'))
      `).bind(
        `rating_${i + 1}`,
        driverData[i].id,
        4 + Math.random(),
        'テスト評価'
      ).run();

      await c.env.DB.prepare(`
        INSERT OR REPLACE INTO driver_performance (
          id, driver_id, performance_score, total_trips, completion_rate, created_at
        ) VALUES (?, ?, ?, ?, ?, datetime('now'))
      `).bind(
        `perf_${i + 1}`,
        driverData[i].id,
        90 + Math.floor(Math.random() * 10),
        50 + Math.floor(Math.random() * 100),
        0.95 + Math.random() * 0.05
      ).run();
    }

    return c.json({
      success: true,
      message: 'データベースの初期化が完了しました',
      data: {
        tables: ['companies', 'drivers', 'dispatch_requests', 'voice_dispatch_logs', 'driver_ratings', 'driver_performance', 'twilio_logs'],
        demoCompany: 'company_demo_001',
        demoDrivers: driverData.length,
        loginCredentials: {
          email: 'demo@example.com',
          password: 'pass1234',
          userType: 'company'
        }
      }
    });

  } catch (error) {
    console.error('Database initialization error:', error);
    return c.json({
      success: false,
      error: 'Database Initialization Failed',
      message: error.message
    }, 500);
  }
});

// ヘルスチェック
app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: c.env.ENVIRONMENT || 'development',
    version: '1.0.0',
  });
});

// ダッシュボード統計データ取得
app.get('/api/dashboard/stats', async (c) => {
  try {
    // 登録会社数を取得
    const companyCount = await c.env.DB.prepare(
      'SELECT COUNT(*) as count FROM companies'
    ).first();

    // 登録ドライバー数を取得
    const driverCount = await c.env.DB.prepare(
      'SELECT COUNT(*) as count FROM drivers'
    ).first();

    // 今日の配車数（仮）
    const todayDispatchCount = await c.env.DB.prepare(
      'SELECT COUNT(*) as count FROM dispatch_requests WHERE DATE(created_at) = DATE("now")'
    ).first();

    // アクティブドライバー数（仮）
    const activeDriverCount = await c.env.DB.prepare(
      'SELECT COUNT(*) as count FROM drivers WHERE status = "active"'
    ).first();

    return c.json({
      success: true,
      data: {
        companies: companyCount?.count || 0,
        drivers: driverCount?.count || 0,
        todayDispatches: todayDispatchCount?.count || 0,
        activeDrivers: activeDriverCount?.count || 0,
        costReduction: 75.0,
        driverSufficiency: 95.0,
        profitIncrease: 12.0,
        systemUptime: 99.9,
      }
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    return c.json({
      success: false,
      error: 'Failed to fetch dashboard stats',
      message: error.message
    }, 500);
  }
});

// 最近の登録一覧取得
app.get('/api/dashboard/recent-registrations', async (c) => {
  try {
    // 最近の会社登録
    const recentCompanies = await c.env.DB.prepare(
      'SELECT id, company_name, status, created_at FROM companies ORDER BY created_at DESC LIMIT 5'
    ).all();

    // 最近のドライバー登録
    const recentDrivers = await c.env.DB.prepare(
      'SELECT id, name, status, created_at FROM drivers ORDER BY created_at DESC LIMIT 5'
    ).all();

    return c.json({
      success: true,
      data: {
        companies: recentCompanies.results || [],
        drivers: recentDrivers.results || [],
      }
    });
  } catch (error) {
    console.error('Recent registrations error:', error);
    return c.json({
      success: false,
      error: 'Failed to fetch recent registrations',
      message: error.message
    }, 500);
  }
});

// 認証API
app.post('/auth/register/company', async (c) => {
  try {
    const data = await c.req.json();
    
    // 簡単なバリデーション
    if (!data.companyName || !data.representativeEmail) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Company name and email are required'
      }, 400);
    }

    // 会社IDを生成
    const companyId = `company_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // D1データベースに保存
    const result = await c.env.DB.prepare(`
      INSERT INTO companies (
        id, company_name, company_address, company_phone, license_number,
        representative_name, representative_email, service_area, vehicle_count,
        driver_count, selected_plan, status, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', datetime('now'))
    `).bind(
      companyId,
      data.companyName,
      data.companyAddress || '',
      data.companyPhone || '',
      data.licenseNumber || '',
      data.representativeName || '',
      data.representativeEmail,
      data.serviceArea || '',
      parseInt(data.vehicleCount) || 0,
      parseInt(data.driverCount) || 0,
      data.selectedPlan || 'standard'
    ).run();

    if (!result.success) {
      throw new Error('Database insertion failed');
    }

    return c.json({
      success: true,
      message: '会社登録が完了しました',
      data: {
        companyId: companyId,
        userType: 'company'
      }
    }, 201);

  } catch (error) {
    console.error('Company registration error:', error);
    return c.json({
      success: false,
      error: 'Registration Failed',
      message: 'データベースエラーが発生しました'
    }, 500);
  }
});

// ドライバー登録API
app.post('/auth/register/driver', async (c) => {
  try {
    const data = await c.req.json();
    
    // 簡単なバリデーション
    if (!data.name || !data.email) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Name and email are required'
      }, 400);
    }

    // ドライバーIDを生成
    const driverId = `driver_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // D1データベースに保存
    const result = await c.env.DB.prepare(`
      INSERT INTO drivers (
        id, name, phone, email, address, birthdate, license_number,
        license_expiry, taxi_license_number, has_own_vehicle, is_full_time,
        working_area, vehicle_model, vehicle_year, vehicle_plate,
        insurance_number, bank_name, branch_name, account_number,
        account_holder, status, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', datetime('now'))
    `).bind(
      driverId,
      data.name,
      data.phone || '',
      data.email,
      data.address || '',
      data.birthdate || '',
      data.licenseNumber || '',
      data.licenseExpiry || '',
      data.taxiLicenseNumber || '',
      data.hasOwnVehicle ? 1 : 0,
      data.isFullTime ? 1 : 0,
      data.workingArea || '',
      data.vehicleModel || '',
      data.vehicleYear || '',
      data.vehiclePlate || '',
      data.insuranceNumber || '',
      data.bankName || '',
      data.branchName || '',
      data.accountNumber || '',
      data.accountHolder || ''
    ).run();

    if (!result.success) {
      throw new Error('Database insertion failed');
    }

    return c.json({
      success: true,
      message: 'ドライバー登録が完了しました',
      data: {
        driverId: driverId,
        userType: 'driver'
      }
    }, 201);

  } catch (error) {
    console.error('Driver registration error:', error);
    return c.json({
      success: false,
      error: 'Registration Failed',
      message: 'データベースエラーが発生しました'
    }, 500);
  }
});

// ログインAPI
app.post('/auth/login', async (c) => {
  try {
    const { email, password, userType } = await c.req.json();

    // バリデーション
    if (!email || !password || !userType) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'メールアドレス、パスワード、ユーザータイプが必要です'
      }, 400);
    }

    let user = null;
    let userData = null;

    if (userType === 'company') {
      // 会社アカウントのログイン
      const company = await c.env.DB.prepare(
        'SELECT * FROM companies WHERE representative_email = ?'
      ).bind(email).first();

      if (!company) {
        return c.json({
          success: false,
          error: 'Authentication Failed',
          message: 'メールアドレスまたはパスワードが違います'
        }, 401);
      }

      // デモ用簡易パスワードチェック
      if (email === 'demo@example.com' && password === 'pass1234') {
        user = company;
        
        // Twilio電話番号を取得または生成
        let twilioPhoneNumber = company.twilio_phone_number;
        if (!twilioPhoneNumber) {
          // 実際のTwilio番号を使用
          twilioPhoneNumber = '+12407927324';
          
          // データベースに保存
          await c.env.DB.prepare(
            'UPDATE companies SET twilio_phone_number = ? WHERE id = ?'
          ).bind(twilioPhoneNumber, company.id).run();
        }
        
        userData = {
          id: company.id,
          name: company.company_name,
          email: company.representative_email,
          type: 'company',
          phoneNumber: twilioPhoneNumber,
          companyPhone: company.company_phone,
          aiRoutingEnabled: company.ai_routing_enabled || true
        };
      } else {
        return c.json({
          success: false,
          error: 'Authentication Failed',
          message: 'メールアドレスまたはパスワードが違います'
        }, 401);
      }

    } else if (userType === 'driver') {
      // ドライバーアカウントのログイン
      const driver = await c.env.DB.prepare(
        'SELECT * FROM drivers WHERE email = ?'
      ).bind(email).first();

      if (!driver) {
        return c.json({
          success: false,
          error: 'Authentication Failed',
          message: 'メールアドレスまたはパスワードが違います'
        }, 401);
      }

      // デモ用簡易パスワードチェック
      if (email === 'driver@example.com' && password === 'pass1234') {
        user = driver;
        userData = {
          id: driver.id,
          name: driver.name,
          email: driver.email,
          type: 'driver',
          companyId: driver.company_id,
          phoneNumber: driver.phone,
          status: driver.status,
          currentLocation: {
            latitude: driver.latitude || 35.6762,
            longitude: driver.longitude || 139.6503
          }
        };
      } else {
        return c.json({
          success: false,
          error: 'Authentication Failed',
          message: 'メールアドレスまたはパスワードが違います'
        }, 401);
      }
    }

    // JWTトークン生成（簡易版）
    const token = btoa(JSON.stringify({
      userId: userData.id,
      userType: userData.type,
      email: userData.email,
      exp: Date.now() + (24 * 60 * 60 * 1000) // 24時間有効
    }));

    return c.json({
      success: true,
      message: 'ログインに成功しました',
      data: {
        user: userData,
        token: token
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    return c.json({
      success: false,
      error: 'Login Failed',
      message: 'ログイン処理中にエラーが発生しました'
    }, 500);
  }
});

// セッション検証
app.get('/auth/verify', async (c) => {
  try {
    const authorization = c.req.header('Authorization');
    
    if (!authorization || !authorization.startsWith('Bearer ')) {
      return c.json({
        success: false,
        error: 'Unauthorized',
        message: '認証トークンが必要です'
      }, 401);
    }

    const token = authorization.substring(7);
    
    try {
      const payload = JSON.parse(atob(token));
      
      if (payload.exp < Date.now()) {
        return c.json({
          success: false,
          error: 'Token Expired',
          message: 'トークンの有効期限が切れています'
        }, 401);
      }

      return c.json({
        success: true,
        data: {
          userId: payload.userId,
          userType: payload.userType,
          email: payload.email
        }
      });
      
    } catch (e) {
      return c.json({
        success: false,
        error: 'Invalid Token',
        message: '無効なトークンです'
      }, 401);
    }

  } catch (error) {
    console.error('Verify error:', error);
    return c.json({
      success: false,
      error: 'Verification Failed',
      message: '認証検証中にエラーが発生しました'
    }, 500);
  }
});

// AI音声配車API - 配車リクエスト作成
app.post('/api/voice-dispatch/create', async (c) => {
  try {
    const data = await c.req.json();
    
    // バリデーション
    if (!data.customerName || !data.customerPhone || !data.pickupLocation || !data.destination) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Customer name, phone, pickup location, and destination are required'
      }, 400);
    }

    // 配車リクエストIDを生成
    const dispatchId = `dispatch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // 最適なドライバーを検索
    const availableDrivers = await findAvailableDrivers(c.env.DB, data.pickupLocation);
    const bestDriver = availableDrivers.length > 0 ? availableDrivers[0] : null;
    
    // D1データベースに配車リクエストを保存
    const result = await c.env.DB.prepare(`
      INSERT INTO dispatch_requests (
        id, customer_name, customer_phone, pickup_location, destination,
        vehicle_type, status, assigned_driver_id, created_at,
        estimated_arrival, fare_amount
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), ?, ?)
    `).bind(
      dispatchId,
      data.customerName,
      data.customerPhone,
      data.pickupLocation,
      data.destination,
      data.vehicleType || 'standard',
      'pending',
      bestDriver?.id || null,
      bestDriver ? 10 : 15, // 予想到着時間（分）
      1500 // 概算料金
    ).run();

    if (!result.success) {
      throw new Error('Database insertion failed');
    }

    // 音声通話ログも記録
    await c.env.DB.prepare(`
      INSERT INTO voice_dispatch_logs (
        id, dispatch_request_id, phone_number, call_status, created_at
      ) VALUES (?, ?, ?, 'initiated', datetime('now'))
    `).bind(
      `voice_${Date.now()}`,
      dispatchId,
      data.customerPhone
    ).run();

    return c.json({
      success: true,
      message: 'AI音声配車リクエストを作成しました',
      data: {
        dispatchId: dispatchId,
        assignedDriver: bestDriver ? {
          name: bestDriver.name,
          vehicleModel: bestDriver.vehicle_model,
          vehiclePlate: bestDriver.vehicle_plate
        } : null,
        estimatedArrival: bestDriver ? 10 : 15,
        twimlUrl: `/api/voice-dispatch/twiml/${dispatchId}`
      }
    }, 201);

  } catch (error) {
    console.error('Voice dispatch creation error:', error);
    return c.json({
      success: false,
      error: 'Voice Dispatch Failed',
      message: 'AI音声配車の作成に失敗しました'
    }, 500);
  }
});

// 電話転送受信エンドポイント（Groq LLM統合）
app.post('/api/voice/incoming', async (c) => {
  try {
    const body = await c.req.parseBody();
    const from = body.From || '';
    const to = body.To || '';
    
    // 会社を特定
    const company = await c.env.DB.prepare(`
      SELECT * FROM companies WHERE company_phone = ? OR twilio_phone_number = ?
    `).bind(to, to).first();
    
    if (!company) {
      return c.text(generateErrorTwiML('この番号は登録されていません'), 200, {
        'Content-Type': 'application/xml'
      });
    }
    
    // 時間帯チェック
    const now = new Date();
    const hour = now.getHours();
    const isBusinessHours = hour >= 8 && hour < 20;
    
    // リアルタイムドライバー可用性チェック
    const availableDriversCount = await c.env.DB.prepare(`
      SELECT COUNT(*) as count FROM drivers 
      WHERE status = 'active' AND is_available = 1
        AND datetime(last_location_update) > datetime('now', '-15 minutes')
    `).first();
    
    const hasAvailableDrivers = (availableDriversCount?.count || 0) > 0;
    
    if ((!isBusinessHours || company.ai_routing_enabled) && hasAvailableDrivers) {
      // AI応答へ（ドライバーが利用可能な場合）
      const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">お電話ありがとうございます。${company.company_name}のAI配車システムです。現在${availableDriversCount.count}台の車両が利用可能です。</Say>
  <Gather input="speech" language="ja-JP" timeout="10" action="/api/voice/process-speech">
    <Say language="ja-JP">配車をご希望の場合は、お迎え場所を教えてください。</Say>
  </Gather>
  <Say language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
</Response>`;
      return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
    } else if (hasAvailableDrivers) {
      // 人間のオペレーターへ転送（ドライバーが利用可能な場合）
      const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">お電話ありがとうございます。${company.company_name}です。オペレーターにおつなぎいたします。</Say>
  <Dial timeout="30">${company.operator_phone || company.company_phone}</Dial>
  <Say language="ja-JP">オペレーターに接続できませんでした。後ほどおかけ直しください。</Say>
</Response>`;
      return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
    } else {
      // ドライバーが利用不可の場合
      const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">お電話ありがとうございます。${company.company_name}です。申し訳ございませんが、現在すべての車両が出動中です。しばらくしてから再度お電話ください。</Say>
</Response>`;
      return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
    }
  } catch (error) {
    console.error('Incoming call error:', error);
    return c.text(generateErrorTwiML('システムエラーが発生しました'), 200, {
      'Content-Type': 'application/xml'
    });
  }
});

// 音声認識結果処理（Groq Llama 4統合）
app.post('/api/voice/process-speech', async (c) => {
  try {
    const body = await c.req.parseBody();
    const speechResult = body.SpeechResult || '';
    const from = body.From || '';
    const callSid = body.CallSid || '';
    
    // セッション情報を保存
    if (!c.env.CALL_SESSIONS) {
      c.env.CALL_SESSIONS = new Map();
    }
    
    let session = c.env.CALL_SESSIONS.get(callSid) || { step: 'pickup', data: {} };
    
    // Groq LLMを使用して自然言語処理
    const llmResponse = await processWithGroqLlama(speechResult, session.step, c.env.GROQ_API_KEY);
    
    if (session.step === 'pickup') {
      session.data.pickupLocation = llmResponse.extractedLocation || speechResult;
      session.step = 'destination';
      
      const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">${llmResponse.confirmationMessage || `お迎え場所は${session.data.pickupLocation}ですね。`}</Say>
  <Gather input="speech" language="ja-JP" timeout="5" action="/api/voice/process-speech">
    <Say language="ja-JP">目的地をお聞かせください。</Say>
  </Gather>
</Response>`;
      
      c.env.CALL_SESSIONS.set(callSid, session);
      return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
      
    } else if (session.step === 'destination') {
      session.data.destination = llmResponse.extractedLocation || speechResult;
      session.data.customerPhone = from;
      
      // リアルタイム最適ドライバー検索
      const optimalDriver = await findOptimalDriverRealtime(c.env.DB, {
        pickupLocation: session.data.pickupLocation,
        destination: session.data.destination,
        pickupLatitude: llmResponse.coordinates?.pickup?.lat,
        pickupLongitude: llmResponse.coordinates?.pickup?.lng,
        vehicleType: llmResponse.vehicleType || 'standard'
      });
      
      // 配車リクエスト作成
      const dispatchId = await createAdvancedDispatchFromCall(c.env.DB, session.data, optimalDriver);
      
      const arrivalTime = optimalDriver ? Math.ceil(optimalDriver.distance * 2 + 5) : 15;
      const driverInfo = optimalDriver ? 
        `担当ドライバーは${optimalDriver.name}、車両は${optimalDriver.vehicle_model}です。` :
        '最適なドライバーを検索中です。';
      
      const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">かしこまりました。${session.data.pickupLocation}から${session.data.destination}までの配車を手配いたします。${driverInfo}${arrivalTime}分ほどでお迎えに上がります。</Say>
  <Say language="ja-JP">配車番号は${dispatchId.slice(-6)}です。ありがとうございました。</Say>
</Response>`;
      
      return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
    }
  } catch (error) {
    console.error('Speech processing error:', error);
    return c.text(generateErrorTwiML('音声認識エラーが発生しました'), 200, {
      'Content-Type': 'application/xml'
    });
  }
});

// TwiML音声応答生成
app.post('/api/voice-dispatch/twiml/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    
    // 配車データを取得
    const dispatch = await c.env.DB.prepare(`
      SELECT dr.*, d.name as driver_name, d.vehicle_model, d.vehicle_plate 
      FROM dispatch_requests dr 
      LEFT JOIN drivers d ON dr.assigned_driver_id = d.id 
      WHERE dr.id = ?
    `).bind(dispatchId).first();

    if (!dispatch) {
      return c.text(generateErrorTwiML('配車情報が見つかりません'), 200, {
        'Content-Type': 'application/xml'
      });
    }

    const twiml = generateVoiceTwiML(dispatch);
    
    return c.text(twiml, 200, {
      'Content-Type': 'application/xml'
    });
  } catch (error) {
    console.error('TwiML generation error:', error);
    return c.text(generateErrorTwiML('システムエラーが発生しました'), 200, {
      'Content-Type': 'application/xml'
    });
  }
});

// 音声入力処理
app.post('/api/voice-dispatch/process/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    const body = await c.req.parseBody();
    
    const speechResult = body.SpeechResult || '';
    const confidence = parseFloat(body.Confidence || '0');
    
    // 配車データを取得
    const dispatch = await c.env.DB.prepare(`
      SELECT dr.*, d.name as driver_name, d.vehicle_model, d.vehicle_plate 
      FROM dispatch_requests dr 
      LEFT JOIN drivers d ON dr.assigned_driver_id = d.id 
      WHERE dr.id = ?
    `).bind(dispatchId).first();

    if (!dispatch) {
      return c.text(generateErrorTwiML('配車情報が見つかりません'), 200, {
        'Content-Type': 'application/xml'
      });
    }

    // 音声入力をログに記録
    await c.env.DB.prepare(`
      INSERT INTO voice_dispatch_logs (
        id, dispatch_request_id, phone_number, transcription, 
        call_status, created_at
      ) VALUES (?, ?, ?, ?, 'processing', datetime('now'))
    `).bind(
      `voice_${Date.now()}`,
      dispatchId,
      dispatch.customer_phone,
      speechResult
    ).run();

    // 音声入力を処理してTwiMLを生成
    const twiml = processVoiceInputTwiML(dispatch, speechResult, confidence);
    
    return c.text(twiml, 200, {
      'Content-Type': 'application/xml'
    });
  } catch (error) {
    console.error('Voice processing error:', error);
    return c.text(generateErrorTwiML('音声処理中にエラーが発生しました'), 200, {
      'Content-Type': 'application/xml'
    });
  }
});

// 配車確定
app.post('/api/voice-dispatch/confirm/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    
    // 配車を確定状態に更新
    await c.env.DB.prepare(`
      UPDATE dispatch_requests 
      SET status = 'confirmed', pickup_time = datetime('now', '+10 minutes')
      WHERE id = ?
    `).bind(dispatchId).run();

    // 音声ログも更新
    await c.env.DB.prepare(`
      INSERT INTO voice_dispatch_logs (
        id, dispatch_request_id, phone_number, call_status, created_at
      ) VALUES (?, ?, ?, 'confirmed', datetime('now'))
    `).bind(
      `voice_${Date.now()}`,
      dispatchId,
      'system'
    ).run();

    return c.json({
      success: true,
      dispatchId: dispatchId,
      status: 'confirmed',
      message: 'AI音声配車が確定しました'
    });
  } catch (error) {
    console.error('Voice dispatch confirmation error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: '配車確定処理中にエラーが発生しました'
    }, 500);
  }
});

// 配車状況取得
app.get('/api/voice-dispatch/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    
    const dispatch = await c.env.DB.prepare(`
      SELECT dr.*, d.name as driver_name, d.vehicle_model, d.vehicle_plate,
             d.phone as driver_phone
      FROM dispatch_requests dr 
      LEFT JOIN drivers d ON dr.assigned_driver_id = d.id 
      WHERE dr.id = ?
    `).bind(dispatchId).first();

    if (!dispatch) {
      return c.json({
        success: false,
        error: 'Dispatch not found'
      }, 404);
    }

    return c.json({
      success: true,
      dispatch: dispatch
    });
  } catch (error) {
    console.error('Get voice dispatch error:', error);
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// リアルタイム車両位置更新API
app.post('/api/drivers/location', async (c) => {
  try {
    const { driverId, latitude, longitude, status } = await c.req.json();
    
    if (!driverId || !latitude || !longitude) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Driver ID, latitude, and longitude are required'
      }, 400);
    }
    
    // 位置情報とステータスを更新
    await c.env.DB.prepare(`
      UPDATE drivers 
      SET latitude = ?, longitude = ?, last_location_update = datetime('now'),
          is_available = ?, status = ?
      WHERE id = ?
    `).bind(
      latitude, 
      longitude, 
      status !== 'busy' ? 1 : 0,
      status || 'active',
      driverId
    ).run();
    
    return c.json({
      success: true,
      message: '位置情報を更新しました',
      data: {
        latitude,
        longitude,
        status: status || 'active',
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Location update error:', error);
    return c.json({
      success: false,
      error: 'Location Update Failed',
      message: '位置情報の更新に失敗しました'
    }, 500);
  }
});

// リアルタイム配車リクエストAPI
app.post('/api/realtime-dispatch', async (c) => {
  try {
    const data = await c.req.json();
    
    if (!data.pickupLocation || !data.destination || !data.customerPhone) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Pickup location, destination, and customer phone are required'
      }, 400);
    }
    
    const startTime = Date.now();
    
    // リアルタイム最適ドライバー検索
    const optimalDriver = await findOptimalDriverRealtime(c.env.DB, {
      pickupLocation: data.pickupLocation,
      destination: data.destination,
      pickupLatitude: data.pickupLatitude,
      pickupLongitude: data.pickupLongitude,
      vehicleType: data.vehicleType || 'standard',
      priority: data.priority || 'normal'
    });
    
    // 配車リクエスト作成
    const dispatchId = await createAdvancedDispatchFromCall(c.env.DB, data, optimalDriver);
    
    const processingTime = Date.now() - startTime;
    
    return c.json({
      success: true,
      message: `リアルタイム配車が完了しました（${processingTime}ms）`,
      data: {
        dispatchId,
        assignedDriver: optimalDriver ? {
          id: optimalDriver.id,
          name: optimalDriver.name,
          vehicleModel: optimalDriver.vehicle_model,
          vehiclePlate: optimalDriver.vehicle_plate,
          phone: optimalDriver.phone,
          estimatedArrival: optimalDriver.estimatedArrival,
          distance: optimalDriver.distance,
          matchingScore: optimalDriver.matchingScore
        } : null,
        estimatedArrival: optimalDriver?.estimatedArrival || 15,
        estimatedFare: calculateEstimatedFare(
          data.pickupLocation, 
          data.destination, 
          optimalDriver?.distance
        ),
        processingTime
      }
    });
    
  } catch (error) {
    console.error('Realtime dispatch error:', error);
    return c.json({
      success: false,
      error: 'Realtime Dispatch Failed',
      message: 'リアルタイム配車に失敗しました'
    }, 500);
  }
});

// 近くの利用可能ドライバー取得API
app.get('/api/nearby-drivers', async (c) => {
  try {
    const { latitude, longitude, radius = 5 } = c.req.query;
    
    if (!latitude || !longitude) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Latitude and longitude are required'
      }, 400);
    }
    
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const searchRadius = parseFloat(radius);
    
    // 近くのアクティブドライバーを取得
    const nearbyDrivers = await c.env.DB.prepare(`
      SELECT 
        d.id, d.name, d.latitude, d.longitude, d.vehicle_model, d.vehicle_plate,
        d.status, d.is_available, d.phone,
        datetime(d.last_location_update) as last_update,
        COALESCE(avg_rating.rating, 4.0) as average_rating,
        COALESCE(trip_count.count, 0) as total_trips,
        CASE 
          WHEN datetime(d.last_location_update) > datetime('now', '-2 minutes') THEN 'real_time'
          WHEN datetime(d.last_location_update) > datetime('now', '-10 minutes') THEN 'recent'
          ELSE 'stale'
        END as location_freshness
      FROM drivers d
      LEFT JOIN (
        SELECT driver_id, AVG(CAST(rating AS REAL)) as rating 
        FROM driver_ratings 
        WHERE created_at > datetime('now', '-30 days')
        GROUP BY driver_id
      ) avg_rating ON d.id = avg_rating.driver_id
      LEFT JOIN (
        SELECT assigned_driver_id, COUNT(*) as count 
        FROM dispatch_requests 
        WHERE status = 'completed' AND created_at > datetime('now', '-7 days')
        GROUP BY assigned_driver_id
      ) trip_count ON d.id = trip_count.assigned_driver_id
      WHERE d.status = 'active' AND d.is_available = 1
        AND d.latitude IS NOT NULL AND d.longitude IS NOT NULL
      ORDER BY d.last_location_update DESC
      LIMIT 20
    `).all();
    
    const drivers = nearbyDrivers.results || [];
    
    // 距離計算とフィルタリング
    const driversWithDistance = drivers
      .map(driver => {
        const distance = calculateDistance(lat, lng, driver.latitude, driver.longitude);
        return {
          ...driver,
          distance: Math.round(distance * 100) / 100,
          estimatedArrival: Math.ceil(distance * 2 + 3)
        };
      })
      .filter(driver => driver.distance <= searchRadius)
      .sort((a, b) => a.distance - b.distance);
    
    return c.json({
      success: true,
      data: {
        searchLocation: { latitude: lat, longitude: lng },
        searchRadius,
        drivers: driversWithDistance,
        count: driversWithDistance.length
      }
    });
    
  } catch (error) {
    console.error('Nearby drivers error:', error);
    return c.json({
      success: false,
      error: 'Nearby Drivers Search Failed',
      message: '近くのドライバー検索に失敗しました'
    }, 500);
  }
});

// Twilio電話番号検索API
app.get('/api/twilio/search-numbers', async (c) => {
  try {
    const { type = 'Local', areaCode, limit = 10 } = c.req.query;
    
    const accountSid = c.env.TWILIO_ACCOUNT_SID;
    const authToken = c.env.TWILIO_AUTH_TOKEN;
    
    if (!accountSid || !authToken) {
      return c.json({
        success: false,
        error: 'Configuration Error',
        message: 'Twilio credentials not configured'
      }, 500);
    }
    
    // Twilio Available Numbers API
    let url = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/AvailablePhoneNumbers/JP/${type}.json?Limit=${limit}`;
    
    if (areaCode) {
      url += `&AreaCode=${areaCode}`;
    }
    
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${btoa(`${accountSid}:${authToken}`)}`
      }
    });
    
    if (!response.ok) {
      throw new Error(`Twilio API error: ${response.status}`);
    }
    
    const data = await response.json();
    
    return c.json({
      success: true,
      data: {
        availableNumbers: data.available_phone_numbers || [],
        count: data.available_phone_numbers?.length || 0,
        type,
        country: 'JP'
      }
    });
    
  } catch (error) {
    console.error('Twilio search numbers error:', error);
    return c.json({
      success: false,
      error: 'Search Failed',
      message: `電話番号の検索に失敗しました: ${error.message}`
    }, 500);
  }
});

// Twilio電話番号設定API（既存番号のWebhook設定）
app.post('/api/twilio/configure-number', async (c) => {
  try {
    const { phoneNumber, companyId } = await c.req.json();
    
    if (!phoneNumber) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Phone number is required'
      }, 400);
    }
    
    const accountSid = c.env.TWILIO_ACCOUNT_SID;
    const authToken = c.env.TWILIO_AUTH_TOKEN;
    
    if (!accountSid || !authToken) {
      return c.json({
        success: false,
        error: 'Configuration Error',
        message: 'Twilio credentials not configured'
      }, 500);
    }
    
    // Webhook URLを設定
    const webhookUrl = `https://mobi360-api.yukihamada.workers.dev/api/voice/incoming`;
    
    // 既存の電話番号一覧を取得
    const numbersResponse = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/IncomingPhoneNumbers.json`, {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${btoa(`${accountSid}:${authToken}`)}`
      }
    });
    
    if (!numbersResponse.ok) {
      throw new Error(`Failed to fetch phone numbers: ${numbersResponse.status}`);
    }
    
    const numbersData = await numbersResponse.json();
    const existingNumber = numbersData.incoming_phone_numbers?.find(num => num.phone_number === phoneNumber);
    
    if (!existingNumber) {
      throw new Error(`Phone number ${phoneNumber} not found in your Twilio account`);
    }
    
    // Webhookを更新
    const updateResponse = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/IncomingPhoneNumbers/${existingNumber.sid}.json`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${btoa(`${accountSid}:${authToken}`)}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        VoiceUrl: webhookUrl,
        VoiceMethod: 'POST',
        StatusCallback: `https://mobi360-api.yukihamada.workers.dev/api/twilio/status`,
        StatusCallbackMethod: 'POST'
      })
    });
    
    if (!updateResponse.ok) {
      const errorData = await updateResponse.json();
      throw new Error(`Webhook update error: ${errorData.message || updateResponse.status}`);
    }
    
    const data = await updateResponse.json();
    
    // データベースに番号を保存
    if (companyId) {
      await c.env.DB.prepare(`
        UPDATE companies 
        SET twilio_phone_number = ?, twilio_phone_sid = ?, ai_routing_enabled = 1
        WHERE id = ?
      `).bind(data.phone_number, data.sid, companyId).run();
    }
    
    return c.json({
      success: true,
      message: '電話番号のWebhook設定が完了しました',
      data: {
        phoneNumber: data.phone_number,
        phoneSid: data.sid,
        friendlyName: data.friendly_name,
        capabilities: data.capabilities,
        webhookUrl,
        voiceUrl: data.voice_url
      }
    });
    
  } catch (error) {
    console.error('Twilio configure number error:', error);
    return c.json({
      success: false,
      error: 'Configuration Failed',
      message: `電話番号の設定に失敗しました: ${error.message}`
    }, 500);
  }
});

// Twilio電話番号購入API
app.post('/api/twilio/purchase-number', async (c) => {
  try {
    const { phoneNumber, companyId } = await c.req.json();
    
    if (!phoneNumber) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Phone number is required'
      }, 400);
    }
    
    const accountSid = c.env.TWILIO_ACCOUNT_SID;
    const authToken = c.env.TWILIO_AUTH_TOKEN;
    
    if (!accountSid || !authToken) {
      return c.json({
        success: false,
        error: 'Configuration Error',
        message: 'Twilio credentials not configured'
      }, 500);
    }
    
    // Webhook URLを設定
    const webhookUrl = `https://mobi360-api.yukihamada.workers.dev/api/voice/incoming`;
    
    // Twilio Incoming Phone Numbers API
    const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/IncomingPhoneNumbers.json`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${btoa(`${accountSid}:${authToken}`)}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        PhoneNumber: phoneNumber,
        VoiceUrl: webhookUrl,
        VoiceMethod: 'POST',
        StatusCallback: `https://mobi360-api.yukihamada.workers.dev/api/twilio/status`,
        StatusCallbackMethod: 'POST'
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Twilio purchase error: ${errorData.message || response.status}`);
    }
    
    const data = await response.json();
    
    // データベースに購入した番号を保存
    if (companyId) {
      await c.env.DB.prepare(`
        UPDATE companies 
        SET twilio_phone_number = ?, twilio_phone_sid = ?, ai_routing_enabled = 1
        WHERE id = ?
      `).bind(data.phone_number, data.sid, companyId).run();
    }
    
    return c.json({
      success: true,
      message: '電話番号の購入が完了しました',
      data: {
        phoneNumber: data.phone_number,
        phoneSid: data.sid,
        friendlyName: data.friendly_name,
        capabilities: data.capabilities,
        webhookUrl
      }
    });
    
  } catch (error) {
    console.error('Twilio purchase number error:', error);
    return c.json({
      success: false,
      error: 'Purchase Failed',
      message: `電話番号の購入に失敗しました: ${error.message}`
    }, 500);
  }
});

// Twilioステータスコールバック
app.post('/api/twilio/status', async (c) => {
  try {
    const body = await c.req.parseBody();
    console.log('Twilio status callback:', body);
    
    // ステータス情報をログに記録
    await c.env.DB.prepare(`
      INSERT INTO twilio_logs (
        id, call_sid, phone_number, status, direction, created_at
      ) VALUES (?, ?, ?, ?, ?, datetime('now'))
    `).bind(
      `log_${Date.now()}`,
      body.CallSid || '',
      body.From || body.To || '',
      body.CallStatus || 'unknown',
      body.Direction || 'unknown'
    ).run();
    
    return c.text('OK', 200);
  } catch (error) {
    console.error('Twilio status callback error:', error);
    return c.text('Error', 500);
  }
});

// 配車リクエスト一覧取得（管理画面用）
app.get('/api/voice-dispatch/list', async (c) => {
  try {
    const dispatches = await c.env.DB.prepare(`
      SELECT dr.*, d.name as driver_name, d.vehicle_model, d.vehicle_plate
      FROM dispatch_requests dr 
      LEFT JOIN drivers d ON dr.assigned_driver_id = d.id 
      ORDER BY dr.created_at DESC 
      LIMIT 50
    `).all();

    return c.json({
      success: true,
      dispatches: dispatches.results || []
    });
  } catch (error) {
    console.error('List voice dispatches error:', error);
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// ユーティリティ関数

// 利用可能ドライバー検索（スマートマッチング）
async function findAvailableDrivers(db, pickupLocation) {
  try {
    const drivers = await db.prepare(`
      SELECT *, 
             CASE 
               WHEN status = 'active' THEN 100
               WHEN status = 'pending' THEN 50
               ELSE 0
             END as status_score,
             CASE 
               WHEN is_full_time = 1 THEN 20
               ELSE 10
             END as availability_score,
             CASE 
               WHEN has_own_vehicle = 1 THEN 15
               ELSE 5
             END as vehicle_score
      FROM drivers 
      WHERE status IN ('active', 'pending')
      ORDER BY (status_score + availability_score + vehicle_score) DESC, RANDOM()
      LIMIT 5
    `).all();
    
    return drivers.results || [];
  } catch (error) {
    console.error('Find available drivers error:', error);
    return [];
  }
}

// 高度なドライバーマッチング（位置情報・評価・経験値考慮）
async function findOptimalDriver(db, dispatchRequest) {
  try {
    const { pickupLatitude, pickupLongitude, vehicleType } = dispatchRequest;
    
    // 基本的なドライバー検索
    const drivers = await db.prepare(`
      SELECT d.*, 
             COALESCE(avg_rating.rating, 4.0) as average_rating,
             COALESCE(trip_count.count, 0) as total_trips,
             CASE 
               WHEN d.status = 'active' THEN 100
               WHEN d.status = 'pending' THEN 50
               ELSE 0
             END as status_score
      FROM drivers d
      LEFT JOIN (
        SELECT driver_id, AVG(CAST(rating AS REAL)) as rating 
        FROM driver_ratings 
        GROUP BY driver_id
      ) avg_rating ON d.id = avg_rating.driver_id
      LEFT JOIN (
        SELECT assigned_driver_id, COUNT(*) as count 
        FROM dispatch_requests 
        WHERE status = 'completed'
        GROUP BY assigned_driver_id
      ) trip_count ON d.id = trip_count.assigned_driver_id
      WHERE d.status IN ('active', 'pending')
      ORDER BY d.created_at DESC
      LIMIT 10
    `).all();

    const availableDrivers = drivers.results || [];
    
    if (availableDrivers.length === 0) {
      return null;
    }

    // スコアリングアルゴリズム
    const scoredDrivers = availableDrivers.map(driver => {
      let score = 0;
      
      // ステータススコア（最重要）
      score += driver.status_score;
      
      // 評価スコア（1-5を0-30に変換）
      score += (driver.average_rating / 5) * 30;
      
      // 経験値スコア（trips数を考慮）
      const experienceScore = Math.min(driver.total_trips * 2, 25);
      score += experienceScore;
      
      // 車両タイプマッチング
      if (driver.vehicle_model && vehicleType) {
        if (vehicleType === 'premium' && driver.vehicle_model.includes('レクサス')) {
          score += 20;
        } else if (vehicleType === 'standard') {
          score += 10;
        }
      }
      
      // フルタイムドライバー優遇
      if (driver.is_full_time) {
        score += 15;
      }
      
      // 距離ボーナス（位置情報がある場合）
      if (driver.latitude && driver.longitude && pickupLatitude && pickupLongitude) {
        const distance = calculateDistance(
          pickupLatitude, pickupLongitude,
          driver.latitude, driver.longitude
        );
        // 近いほど高得点（最大20点）
        const distanceScore = Math.max(0, 20 - (distance * 2));
        score += distanceScore;
      }
      
      // 需要予測ボーナス（時間帯考慮）
      const hour = new Date().getHours();
      if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
        // ラッシュ時間帯
        score += 10;
      }
      
      return {
        ...driver,
        matchingScore: Math.round(score),
        distance: driver.latitude && driver.longitude && pickupLatitude && pickupLongitude 
          ? calculateDistance(pickupLatitude, pickupLongitude, driver.latitude, driver.longitude)
          : null
      };
    });

    // スコア順でソート
    scoredDrivers.sort((a, b) => b.matchingScore - a.matchingScore);
    
    return scoredDrivers[0]; // 最適なドライバーを返す
    
  } catch (error) {
    console.error('Find optimal driver error:', error);
    return null;
  }
}

// 距離計算（ハヴァサイン公式）
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // 地球の半径（km）
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c;
  
  return distance;
}

function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}

// TwiML音声応答生成
function generateVoiceTwiML(dispatch) {
  const driverInfo = dispatch.driver_name ? 
    `担当ドライバーは${dispatch.driver_name}です。車両は${dispatch.vehicle_model}、ナンバープレートは${dispatch.vehicle_plate}です。` :
    'ドライバーを検索中です。';
    
  const message = `こんにちは、${dispatch.customer_name}様。
    Mobility Ops 360のAI音声配車システムです。
    ${dispatch.pickup_location}から${dispatch.destination}への配車をご依頼いただき、ありがとうございます。
    ${driverInfo}
    到着予定時刻は約${dispatch.estimated_arrival}分後となります。
    この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。`;

  return `<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">${message}</Say>
    <Gather input="speech" speechTimeout="auto" language="ja-JP" 
            action="/api/voice-dispatch/process/${dispatch.id}">
        <Say voice="Polly.Mizuki" language="ja-JP">お返事をお聞かせください。</Say>
    </Gather>
    <Say voice="Polly.Mizuki" language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
    <Hangup/>
</Response>`;
}

// 音声入力処理TwiML
function processVoiceInputTwiML(dispatch, speechResult, confidence) {
  const input = speechResult.toLowerCase();
  let response;

  if (input.includes('はい') || input.includes('オッケー') || input.includes('ok') || input.includes('確認')) {
    response = `ありがとうございます。配車を確定いたします。
      ${dispatch.driver_name}が約${dispatch.estimated_arrival}分後にお迎えにあがります。
      車両は${dispatch.vehicle_model}、ナンバープレートは${dispatch.vehicle_plate}です。
      お待ちください。失礼いたします。`;
  } else if (input.includes('いいえ') || input.includes('キャンセル') || input.includes('やめ')) {
    response = `承知いたしました。配車をキャンセルいたします。
      またのご利用をお待ちしております。失礼いたします。`;
  } else if (input.includes('時間') || input.includes('いつ') || input.includes('何分')) {
    response = `到着予定時刻は約${dispatch.estimated_arrival}分後となります。
      この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。`;
  } else if (input.includes('車') || input.includes('ナンバー') || input.includes('ドライバー')) {
    response = `担当ドライバーは${dispatch.driver_name}です。
      車両は${dispatch.vehicle_model}、ナンバープレートは${dispatch.vehicle_plate}です。
      この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。`;
  } else {
    response = `申し訳ございません。もう一度お聞かせください。
      配車内容は、${dispatch.pickup_location}から${dispatch.destination}への移動で、
      約${dispatch.estimated_arrival}分後の到着予定です。
      「はい」で配車確定、「いいえ」でキャンセルとなります。`;
  }

  return `<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">${response}</Say>
    <Hangup/>
</Response>`;
}

// エラー用TwiML
function generateErrorTwiML(message) {
  return `<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">${message}しばらく経ってから再度お試しください。失礼いたします。</Say>
    <Hangup/>
</Response>`;
}

// 404ハンドラー
app.notFound((c) => {
  return c.json({
    success: false,
    error: 'Not Found',
    message: 'The requested endpoint was not found',
    path: c.req.path,
  }, 404);
});

// エラーハンドラー
app.onError((err, c) => {
  console.error('Global error handler:', err);
  
  return c.json({
    success: false,
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString(),
  }, 500);
});


// 電話からの配車リクエスト作成
async function createDispatchFromCall(db, data) {
  const dispatchId = `dispatch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  // 最適なドライバーを検索
  const availableDrivers = await findAvailableDrivers(db, data.pickupLocation);
  const bestDriver = availableDrivers.length > 0 ? availableDrivers[0] : null;
  
  await db.prepare(`
    INSERT INTO dispatch_requests (
      id, customer_name, customer_phone, pickup_location, destination,
      vehicle_type, status, assigned_driver_id, created_at,
      estimated_arrival, fare_amount
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), ?, ?)
  `).bind(
    dispatchId,
    'AI音声配車',
    data.customerPhone,
    data.pickupLocation,
    data.destination,
    'standard',
    bestDriver ? 'assigned' : 'pending',
    bestDriver?.id || null,
    bestDriver ? 10 : 15,
    1500
  ).run();
  
  return dispatchId;
}

// Groq Llama 4 による自然言語処理
async function processWithGroqLlama(speechText, step, apiKey) {
  if (!apiKey) {
    console.log('Groq API key not found, using fallback processing');
    return {
      extractedLocation: speechText,
      confirmationMessage: step === 'pickup' ? 
        `お迎え場所は${speechText}ですね。` :
        `目的地は${speechText}ですね。`,
      vehicleType: 'standard'
    };
  }

  try {
    const prompt = step === 'pickup' ? 
      `以下の音声入力から正確な住所や場所を抽出してください。日本語の住所形式に正規化し、確認メッセージも生成してください。\n\n音声入力: "${speechText}"\n\nJSON形式で回答（extractedLocation, confirmationMessage, coordinates）:` :
      `以下の音声入力から目的地を抽出し、車両タイプの要望があれば判定してください。\n\n音声入力: "${speechText}"\n\nJSON形式で回答（extractedLocation, vehicleType, coordinates）:`;
    
    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        messages: [
          {
            role: 'system',
            content: 'あなたは日本のタクシー配車システムのAIアシスタントです。音声入力から正確な住所や場所情報を抽出し、適切な応答を生成してください。'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.3,
        max_tokens: 500
      })
    });
    
    if (!response.ok) {
      throw new Error(`Groq API error: ${response.status}`);
    }
    
    const data = await response.json();
    
    try {
      const parsed = JSON.parse(data.choices[0].message.content);
      return parsed;
    } catch (e) {
      // JSONパースに失敗した場合はフォールバック
      return {
        extractedLocation: speechText,
        confirmationMessage: step === 'pickup' ? 
          `お迎え場所は${speechText}ですね。` :
          `目的地は${speechText}ですね。`,
        vehicleType: 'standard'
      };
    }
  } catch (error) {
    console.error('Groq LLM processing error:', error);
    return {
      extractedLocation: speechText,
      confirmationMessage: `${speechText}ですね。`,
      vehicleType: 'standard'
    };
  }
}

// リアルタイム最適ドライバー検索（超高速）
async function findOptimalDriverRealtime(db, dispatchRequest) {
  try {
    const startTime = Date.now();
    
    // 並列でドライバー情報と位置情報を取得
    const [driversResult, nearbyDriversResult] = await Promise.all([
      db.prepare(`
        SELECT d.*, 
               COALESCE(avg_rating.rating, 4.0) as average_rating,
               COALESCE(trip_count.count, 0) as total_trips,
               COALESCE(recent_performance.score, 100) as performance_score
        FROM drivers d
        LEFT JOIN (
          SELECT driver_id, AVG(CAST(rating AS REAL)) as rating 
          FROM driver_ratings 
          WHERE created_at > datetime('now', '-30 days')
          GROUP BY driver_id
        ) avg_rating ON d.id = avg_rating.driver_id
        LEFT JOIN (
          SELECT assigned_driver_id, COUNT(*) as count 
          FROM dispatch_requests 
          WHERE status = 'completed' AND created_at > datetime('now', '-7 days')
          GROUP BY assigned_driver_id
        ) trip_count ON d.id = trip_count.assigned_driver_id
        LEFT JOIN (
          SELECT driver_id, AVG(performance_score) as score
          FROM driver_performance
          WHERE created_at > datetime('now', '-24 hours')
          GROUP BY driver_id
        ) recent_performance ON d.id = recent_performance.driver_id
        WHERE d.status = 'active' AND d.is_available = 1
        ORDER BY d.last_location_update DESC
        LIMIT 15
      `).all(),
      // 地理的に近いドライバーを優先取得
      db.prepare(`
        SELECT id, name, latitude, longitude, vehicle_model, vehicle_plate,
               datetime(last_location_update) as last_update,
               CASE 
                 WHEN datetime(last_location_update) > datetime('now', '-5 minutes') THEN 'real_time'
                 WHEN datetime(last_location_update) > datetime('now', '-15 minutes') THEN 'recent'
                 ELSE 'stale'
               END as location_freshness
        FROM drivers 
        WHERE status = 'active' AND is_available = 1
          AND latitude IS NOT NULL AND longitude IS NOT NULL
        ORDER BY last_location_update DESC
        LIMIT 10
      `).all()
    ]);
    
    const drivers = driversResult.results || [];
    const nearbyDrivers = nearbyDriversResult.results || [];
    
    if (drivers.length === 0) {
      console.log(`Real-time driver search completed in ${Date.now() - startTime}ms - No drivers available`);
      return null;
    }
    
    // 高速スコアリングアルゴリズム
    const scoredDrivers = drivers.map(driver => {
      let score = 0;
      const nearbyInfo = nearbyDrivers.find(n => n.id === driver.id);
      
      // ベーススコア（アクティブ度）
      score += 100;
      
      // 評価スコア（30点満点）
      score += (driver.average_rating / 5) * 30;
      
      // 経験値スコア（最近の実績重視、25点満点）
      score += Math.min(driver.total_trips * 3, 25);
      
      // パフォーマンススコア（20点満点）
      score += (driver.performance_score / 100) * 20;
      
      // 位置情報の新しさボーナス（15点満点）
      if (nearbyInfo) {
        switch (nearbyInfo.location_freshness) {
          case 'real_time': score += 15; break;
          case 'recent': score += 10; break;
          case 'stale': score += 5; break;
        }
        
        // 距離計算（座標が利用可能な場合）
        if (dispatchRequest.pickupLatitude && dispatchRequest.pickupLongitude) {
          const distance = calculateDistance(
            dispatchRequest.pickupLatitude, 
            dispatchRequest.pickupLongitude,
            nearbyInfo.latitude, 
            nearbyInfo.longitude
          );
          
          // 距離ボーナス（近いほど高得点、30点満点）
          const distanceScore = Math.max(0, 30 - (distance * 5));
          score += distanceScore;
          
          driver.distance = distance;
          driver.estimatedArrival = Math.ceil(distance * 2 + 3); // 分
        }
      }
      
      // 車両タイプマッチング（10点満点）
      if (driver.vehicle_model && dispatchRequest.vehicleType) {
        if (dispatchRequest.vehicleType === 'premium' && 
            (driver.vehicle_model.includes('レクサス') || driver.vehicle_model.includes('クラウン'))) {
          score += 10;
        } else if (dispatchRequest.vehicleType === 'standard') {
          score += 5;
        }
      }
      
      // 時間帯ボーナス（ラッシュ時間は経験豊富なドライバー優遇）
      const hour = new Date().getHours();
      if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
        if (driver.total_trips > 50) score += 10;
      }
      
      return {
        ...driver,
        matchingScore: Math.round(score),
        distance: driver.distance || null,
        estimatedArrival: driver.estimatedArrival || 15
      };
    });
    
    // スコア順でソート
    scoredDrivers.sort((a, b) => b.matchingScore - a.matchingScore);
    
    const processingTime = Date.now() - startTime;
    console.log(`Real-time driver search completed in ${processingTime}ms - Found ${scoredDrivers.length} candidates`);
    
    return scoredDrivers[0]; // 最適なドライバーを返す
    
  } catch (error) {
    console.error('Real-time driver search error:', error);
    return null;
  }
}

// 高度な配車リクエスト作成
async function createAdvancedDispatchFromCall(db, callData, optimalDriver) {
  const dispatchId = `dispatch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  const estimatedFare = calculateEstimatedFare(
    callData.pickupLocation, 
    callData.destination,
    optimalDriver?.distance || 5
  );
  
  await db.prepare(`
    INSERT INTO dispatch_requests (
      id, customer_name, customer_phone, pickup_location, destination,
      vehicle_type, status, assigned_driver_id, created_at,
      estimated_arrival, fare_amount, dispatch_source, priority_score
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), ?, ?, 'ai_voice', ?)
  `).bind(
    dispatchId,
    'AI音声配車',
    callData.customerPhone,
    callData.pickupLocation,
    callData.destination,
    'standard',
    optimalDriver ? 'assigned' : 'pending',
    optimalDriver?.id || null,
    optimalDriver?.estimatedArrival || 15,
    estimatedFare,
    optimalDriver?.matchingScore || 0
  ).run();
  
  // ドライバーの可用性を更新
  if (optimalDriver) {
    await db.prepare(
      'UPDATE drivers SET is_available = 0, last_dispatch_time = datetime("now") WHERE id = ?'
    ).bind(optimalDriver.id).run();
  }
  
  return dispatchId;
}

// 運賃計算
function calculateEstimatedFare(pickup, destination, distance) {
  const baseRate = 500; // 基本料金
  const distanceRate = 200; // 1kmあたり
  const timeRate = 100; // 1分あたり（渋滞時）
  
  if (distance) {
    return Math.round(baseRate + (distance * distanceRate));
  }
  
  // 距離不明の場合は住所から概算
  const estimatedDistance = pickup && destination ? 
    Math.random() * 10 + 2 : 5; // 2-12km程度と仮定
  
  return Math.round(baseRate + (estimatedDistance * distanceRate));
}

export default app;