import { SignJWT, jwtVerify } from 'jose';

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS処理
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
      });
    }

    try {
      let response;

      switch (path) {
        case '/auth/register/company':
          response = await handleCompanyRegistration(request, env);
          break;
        case '/auth/register/driver':
          response = await handleDriverRegistration(request, env);
          break;
        case '/auth/login':
          response = await handleLogin(request, env);
          break;
        case '/auth/verify':
          response = await handleTokenVerification(request, env);
          break;
        case '/auth/refresh':
          response = await handleTokenRefresh(request, env);
          break;
        default:
          response = new Response('Not Found', { status: 404 });
      }

      // CORS ヘッダーを追加
      response.headers.set('Access-Control-Allow-Origin', '*');
      response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

      return response;
    } catch (error) {
      console.error('Auth API Error:', error);
      return new Response(JSON.stringify({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
  },
};

// 会社登録処理
async function handleCompanyRegistration(request, env) {
  const data = await request.json();
  
  // バリデーション
  const requiredFields = ['companyName', 'companyAddress', 'companyPhone', 'licenseNumber', 'representativeName', 'representativeEmail'];
  for (const field of requiredFields) {
    if (!data[field]) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Validation Error',
        message: `${field} is required`
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  }

  try {
    // 会社IDを生成
    const companyId = generateId('company');
    
    // D1データベースに保存
    const result = await env.DB.prepare(`
      INSERT INTO companies (
        id, company_name, company_address, company_phone, license_number,
        representative_name, representative_email, service_area, vehicle_count,
        driver_count, selected_plan, status, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', datetime('now'))
    `).bind(
      companyId,
      data.companyName,
      data.companyAddress,
      data.companyPhone,
      data.licenseNumber,
      data.representativeName,
      data.representativeEmail,
      data.serviceArea || '',
      parseInt(data.vehicleCount) || 0,
      parseInt(data.driverCount) || 0,
      data.selectedPlan || 'standard'
    ).run();

    if (!result.success) {
      throw new Error('Database insertion failed');
    }

    // JWTトークンを生成
    const token = await generateJWT({
      userId: companyId,
      userType: 'company',
      email: data.representativeEmail,
      companyName: data.companyName
    }, env.JWT_SECRET);

    return new Response(JSON.stringify({
      success: true,
      message: '会社登録が完了しました',
      data: {
        companyId: companyId,
        token: token,
        userType: 'company'
      }
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Company registration error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Registration Failed',
      message: 'データベースエラーが発生しました'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

// ドライバー登録処理
async function handleDriverRegistration(request, env) {
  const data = await request.json();
  
  // バリデーション
  const requiredFields = ['name', 'phone', 'email', 'address', 'birthdate'];
  for (const field of requiredFields) {
    if (!data[field]) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Validation Error',
        message: `${field} is required`
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  }

  try {
    // ドライバーIDを生成
    const driverId = generateId('driver');
    
    // D1データベースに保存
    const result = await env.DB.prepare(`
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
      data.phone,
      data.email,
      data.address,
      data.birthdate,
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

    // JWTトークンを生成
    const token = await generateJWT({
      userId: driverId,
      userType: 'driver',
      email: data.email,
      name: data.name
    }, env.JWT_SECRET);

    return new Response(JSON.stringify({
      success: true,
      message: 'ドライバー登録が完了しました',
      data: {
        driverId: driverId,
        token: token,
        userType: 'driver'
      }
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Driver registration error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Registration Failed',
      message: 'データベースエラーが発生しました'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

// ログイン処理
async function handleLogin(request, env) {
  const { email, password, userType } = await request.json();

  if (!email || !userType) {
    return new Response(JSON.stringify({
      success: false,
      error: 'Validation Error',
      message: 'Email and userType are required'
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  try {
    let user;
    const table = userType === 'company' ? 'companies' : 'drivers';
    const emailField = userType === 'company' ? 'representative_email' : 'email';
    
    const result = await env.DB.prepare(`
      SELECT * FROM ${table} WHERE ${emailField} = ? LIMIT 1
    `).bind(email).first();

    if (!result) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Login Failed',
        message: 'ユーザーが見つかりません'
      }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // JWTトークンを生成
    const token = await generateJWT({
      userId: result.id,
      userType: userType,
      email: email,
      name: userType === 'company' ? result.company_name : result.name
    }, env.JWT_SECRET);

    return new Response(JSON.stringify({
      success: true,
      message: 'ログインが成功しました',
      data: {
        userId: result.id,
        token: token,
        userType: userType,
        profile: {
          name: userType === 'company' ? result.company_name : result.name,
          email: email,
          status: result.status
        }
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Login error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Login Failed',
      message: 'ログインに失敗しました'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

// トークン検証処理
async function handleTokenVerification(request, env) {
  const authHeader = request.headers.get('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return new Response(JSON.stringify({
      success: false,
      error: 'Unauthorized',
      message: 'トークンが提供されていません'
    }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const token = authHeader.slice(7);

  try {
    const payload = await verifyJWT(token, env.JWT_SECRET);
    
    return new Response(JSON.stringify({
      success: true,
      data: {
        userId: payload.userId,
        userType: payload.userType,
        email: payload.email,
        name: payload.name
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    return new Response(JSON.stringify({
      success: false,
      error: 'Unauthorized',
      message: '無効なトークンです'
    }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

// トークンリフレッシュ処理
async function handleTokenRefresh(request, env) {
  const authHeader = request.headers.get('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return new Response(JSON.stringify({
      success: false,
      error: 'Unauthorized',
      message: 'トークンが提供されていません'
    }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const token = authHeader.slice(7);

  try {
    const payload = await verifyJWT(token, env.JWT_SECRET);
    
    // 新しいトークンを生成
    const newToken = await generateJWT({
      userId: payload.userId,
      userType: payload.userType,
      email: payload.email,
      name: payload.name
    }, env.JWT_SECRET);
    
    return new Response(JSON.stringify({
      success: true,
      data: {
        token: newToken
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    return new Response(JSON.stringify({
      success: false,
      error: 'Unauthorized',
      message: 'トークンのリフレッシュに失敗しました'
    }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

// ユーティリティ関数
function generateId(prefix) {
  const timestamp = Date.now().toString(36);
  const randomStr = Math.random().toString(36).substring(2, 8);
  return `${prefix}_${timestamp}_${randomStr}`;
}

async function generateJWT(payload, secret) {
  const encoder = new TextEncoder();
  const secretKey = encoder.encode(secret);
  
  return await new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('24h')
    .sign(secretKey);
}

async function verifyJWT(token, secret) {
  const encoder = new TextEncoder();
  const secretKey = encoder.encode(secret);
  
  const { payload } = await jwtVerify(token, secretKey);
  return payload;
}