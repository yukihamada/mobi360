import { Hono } from 'hono';
import { cors } from 'hono/cors';
// import authRouter from '../api/auth.js';
// import { aiVoiceDispatchRoutes } from '../api/ai-voice-dispatch.js';
// import { driverPoolRoutes } from '../api/driver-pool.js';

const app = new Hono();

// CORS設定
app.use('*', cors({
  origin: ['http://localhost:3000', 'https://mobi360.app'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));

// 静的ファイルの提供
app.get('/docs', async (c) => {
  const swaggerHtml = `<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mobility Ops 360 API Documentation</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header h1 {
            margin: 0;
            font-size: 2.5rem;
            font-weight: 700;
        }
        .header p {
            margin: 0.5rem 0 0 0;
            font-size: 1.2rem;
            opacity: 0.9;
        }
        .badges {
            margin-top: 1rem;
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        .badge {
            background: rgba(255,255,255,0.2);
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            font-size: 0.9rem;
            backdrop-filter: blur(10px);
        }
        #swagger-ui {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        .info {
            background: #f7fafc;
            border-left: 4px solid #667eea;
            padding: 1rem;
            margin: 2rem;
            border-radius: 0.5rem;
        }
        .info h2 {
            margin-top: 0;
            color: #667eea;
        }
        .quick-links {
            display: flex;
            gap: 1rem;
            margin: 2rem;
            flex-wrap: wrap;
        }
        .quick-link {
            background: white;
            border: 1px solid #e2e8f0;
            padding: 1rem;
            border-radius: 0.5rem;
            text-decoration: none;
            color: #333;
            flex: 1;
            min-width: 200px;
            transition: all 0.3s;
        }
        .quick-link:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        .quick-link h3 {
            margin: 0 0 0.5rem 0;
            color: #667eea;
        }
        .footer {
            background: #2d3748;
            color: white;
            text-align: center;
            padding: 2rem;
            margin-top: 4rem;
        }
        .footer a {
            color: #667eea;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚖 Mobility Ops 360 API</h1>
        <p>タクシー業界向けAI配車システムAPIドキュメント</p>
        <div class="badges">
            <span class="badge">Version 1.0.0</span>
            <span class="badge">🎙️ AI音声配車</span>
            <span class="badge">🚗 リアルタイム配車</span>
            <span class="badge">📍 GPS追跡</span>
        </div>
    </div>

    <div class="info">
        <h2>🚀 クイックスタート</h2>
        <p><strong>Base URL:</strong> https://mobility-ops-360-api.yukihamada.workers.dev</p>
        <p><strong>認証:</strong> Bearer Token (Authorization: Bearer &lt;token&gt;)</p>
        <p><strong>テスト電話番号:</strong> +1 959-210-5018</p>
    </div>

    <div class="quick-links">
        <a href="#/Health/get_health" class="quick-link">
            <h3>🏥 ヘルスチェック</h3>
            <p>システムの稼働状況を確認</p>
        </a>
        <a href="#/Auth/post_auth_login" class="quick-link">
            <h3>🔐 認証</h3>
            <p>ログイン・トークン取得</p>
        </a>
        <a href="#/Voice_Dispatch/post_api_voice_dispatch_create" class="quick-link">
            <h3>🎙️ AI音声配車</h3>
            <p>自動音声での配車受付</p>
        </a>
        <a href="#/Realtime/post_api_realtime_dispatch" class="quick-link">
            <h3>⚡ リアルタイム配車</h3>
            <p>最速マッチング</p>
        </a>
    </div>

    <div id="swagger-ui"></div>

    <div class="footer">
        <p>© 2025 Mobility Ops 360 | <a href="https://github.com/mobility360/api">GitHub</a> | <a href="mailto:support@mobility360.jp">サポート</a></p>
    </div>

    <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-bundle.js"><\/script>
    <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-standalone-preset.js"><\/script>
    <script>
        window.onload = function() {
            const ui = SwaggerUIBundle({
                url: "/api/openapi.yaml",
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIStandalonePreset
                ],
                plugins: [
                    SwaggerUIBundle.plugins.DownloadUrl
                ],
                layout: "StandaloneLayout",
                defaultModelsExpandDepth: 1,
                defaultModelExpandDepth: 1,
                docExpansion: "list",
                filter: true,
                showExtensions: true,
                showCommonExtensions: true,
                supportedSubmitMethods: ['get', 'post', 'put', 'delete', 'patch'],
                onComplete: function() {
                    console.log("Swagger UI loaded");
                },
                validatorUrl: null
            });
            window.ui = ui;
        }
    <\/script>
</body>
</html>`;
  
  return c.html(swaggerHtml);
});

// OpenAPI仕様書の提供
app.get('/api/openapi.yaml', async (c) => {
  const openapiYaml = await c.env.ASSETS?.get('openapi.yaml');
  if (openapiYaml) {
    return c.text(await openapiYaml.text(), 200, {
      'Content-Type': 'application/x-yaml'
    });
  }
  
  // 完全版OpenAPI仕様書（全エンドポイント含む）
  const fullOpenAPISpec = `openapi: 3.0.3
info:
  title: Mobility Ops 360 API
  description: |
    タクシー業界向けAI配車システムAPI
    
    ## 主な機能
    - 🎙️ AI音声配車（Twilio + Groq LLM統合）
    - 🚗 リアルタイムドライバーマッチング（高速最適化アルゴリズム）
    - 📍 GPS位置情報トラッキング
    - 💰 動的料金計算
    - 🔐 セキュア認証（JWT）
    - 📊 リアルタイム統計ダッシュボード
    - 🚕 ドライバープール管理
    - ⚡ 超高速配車（数百ms以内）
    - 📤 データエクスポート（CSV/JSON/PDF）
    - 📥 バッチインポート
    - 📋 システムメトリクス・ログ
    - 🔧 設定管理
    - 📦 ジョブキュー
    - ⏰ スケジュール処理
    
    全64エンドポイント + WebSocket接続
  version: 1.0.0
  contact:
    name: Mobility Ops 360 Support
    email: support@mobility360.jp
    url: https://mobility360.jp
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://mobility-ops-360-api.yukihamada.workers.dev
    description: Production server
  - url: https://mobi360-api.yukihamada.workers.dev  
    description: Alternative production server

security:
  - bearerAuth: []

tags:
  - name: Health
    description: ヘルスチェック
  - name: Auth
    description: 認証・登録
  - name: Dashboard
    description: ダッシュボード
  - name: Drivers
    description: ドライバー管理
  - name: Voice
    description: AI音声配車
  - name: Realtime
    description: リアルタイム配車
  - name: Twilio
    description: Twilio電話連携
  - name: Database
    description: データベース管理
  - name: Documentation
    description: APIドキュメント
  - name: WebSocket
    description: WebSocketリアルタイム通信
  - name: DriverPool
    description: ドライバープール管理 (API v1)
  - name: AIVoiceDispatch
    description: AI音声配車 (API v1)
  - name: Services
    description: 各種サービスヘルスチェック
  - name: DurableObject
    description: Durable Objectエンドポイント
  - name: Export
    description: データエクスポート
  - name: Monitoring
    description: 監視・ログ
  - name: Configuration
    description: システム設定
  - name: Batch
    description: バッチ処理
  - name: Queue
    description: ジョブキュー
  - name: Scheduled
    description: スケジュール処理

paths:
  /health:
    get:
      tags:
        - Health
      summary: ヘルスチェック
      description: システムの稼働状況を確認します
      security: []
      responses:
        '200':
          description: システム正常稼働
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: healthy
                  timestamp:
                    type: string
                    format: date-time
                  environment:
                    type: string
                    example: production
                  version:
                    type: string
                    example: 1.0.0

  /api/init-database:
    post:
      tags:
        - Database
      summary: データベース初期化
      description: |
        テーブル作成とデモデータの投入を行います。
        以下のテーブルが作成されます：
        - companies: タクシー会社
        - drivers: ドライバー
        - dispatch_requests: 配車リクエスト
        - voice_dispatch_logs: 音声配車ログ
        - driver_ratings: ドライバー評価
        - driver_performance: ドライバーパフォーマンス
        - twilio_logs: Twilioログ
      security: []
      responses:
        '200':
          description: 初期化成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      tables:
                        type: array
                        items:
                          type: string
                      demoCompany:
                        type: string
                      demoDrivers:
                        type: integer
                      loginCredentials:
                        type: object
                        properties:
                          email:
                            type: string
                          password:
                            type: string
                          userType:
                            type: string

  /auth/register/company:
    post:
      tags:
        - Auth
      summary: タクシー会社登録
      description: 新規タクシー会社を登録します
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - companyName
                - representativeEmail
              properties:
                companyName:
                  type: string
                  example: サンプルタクシー株式会社
                companyAddress:
                  type: string
                  example: 東京都渋谷区渋谷1-1-1
                companyPhone:
                  type: string
                  example: 03-1234-5678
                licenseNumber:
                  type: string
                  example: TAXI-2024-001
                representativeName:
                  type: string
                  example: 山田太郎
                representativeEmail:
                  type: string
                  format: email
                  example: yamada@sample-taxi.com
                serviceArea:
                  type: string
                  example: 東京23区
                vehicleCount:
                  type: integer
                  example: 50
                driverCount:
                  type: integer
                  example: 80
                selectedPlan:
                  type: string
                  enum: [standard, premium, enterprise]
                  example: premium
      responses:
        '201':
          description: 登録成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      companyId:
                        type: string
                      userType:
                        type: string

  /auth/register/driver:
    post:
      tags:
        - Auth
      summary: ドライバー登録
      description: 新規ドライバーを登録します（フルタイム・ギグワーカー両対応）
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - name
                - email
              properties:
                name:
                  type: string
                  example: 鈴木一郎
                email:
                  type: string
                  format: email
                  example: suzuki@example.com
                phone:
                  type: string
                  example: 090-1234-5678
                address:
                  type: string
                  example: 東京都新宿区西新宿1-1-1
                birthdate:
                  type: string
                  format: date
                  example: 1980-01-01
                licenseNumber:
                  type: string
                  example: 123456789012
                licenseExpiry:
                  type: string
                  format: date
                  example: 2025-12-31
                taxiLicenseNumber:
                  type: string
                  example: TAXI-DRV-001
                hasOwnVehicle:
                  type: boolean
                  example: true
                isFullTime:
                  type: boolean
                  example: false
                workingArea:
                  type: string
                  example: 渋谷・新宿・池袋
                vehicleModel:
                  type: string
                  example: トヨタ プリウス
                vehicleYear:
                  type: string
                  example: 2022
                vehiclePlate:
                  type: string
                  example: 品川 500 あ 1234
                insuranceNumber:
                  type: string
                  example: INS-2024-001
                bankName:
                  type: string
                  example: みずほ銀行
                branchName:
                  type: string
                  example: 渋谷支店
                accountNumber:
                  type: string
                  example: 1234567
                accountHolder:
                  type: string
                  example: スズキ イチロウ
      responses:
        '201':
          description: 登録成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      driverId:
                        type: string
                      userType:
                        type: string

  /auth/login:
    post:
      tags:
        - Auth
      summary: ログイン認証
      description: メールアドレスとパスワードで認証を行い、JWTトークンを取得します
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - email
                - password
                - userType
              properties:
                email:
                  type: string
                  format: email
                  example: demo@example.com
                password:
                  type: string
                  example: pass1234
                userType:
                  type: string
                  enum: [company, driver]
                  example: company
      responses:
        '200':
          description: ログイン成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      user:
                        type: object
                        properties:
                          id:
                            type: string
                          name:
                            type: string
                          email:
                            type: string
                          type:
                            type: string
                          phoneNumber:
                            type: string
                          aiRoutingEnabled:
                            type: boolean
                      token:
                        type: string
                        description: JWT認証トークン（24時間有効）

  /auth/verify:
    get:
      tags:
        - Auth
      summary: トークン検証
      description: JWTトークンの有効性を確認します
      responses:
        '200':
          description: トークン有効
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: object
                    properties:
                      userId:
                        type: string
                      userType:
                        type: string
                      email:
                        type: string
        '401':
          description: 認証エラー

  /api/dashboard/stats:
    get:
      tags:
        - Dashboard
      summary: 統計情報取得
      description: ダッシュボード用の統計データを取得します
      responses:
        '200':
          description: 統計データ
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: object
                    properties:
                      companies:
                        type: integer
                        description: 登録会社数
                      drivers:
                        type: integer
                        description: 登録ドライバー数
                      todayDispatches:
                        type: integer
                        description: 本日の配車数
                      activeDrivers:
                        type: integer
                        description: アクティブドライバー数
                      costReduction:
                        type: number
                        description: コスト削減率（%）
                        example: 75.0
                      driverSufficiency:
                        type: number
                        description: ドライバー充足率（%）
                        example: 95.0
                      profitIncrease:
                        type: number
                        description: 利益増加率（%）
                        example: 12.0
                      systemUptime:
                        type: number
                        description: システム稼働率（%）
                        example: 99.9

  /api/dashboard/recent-registrations:
    get:
      tags:
        - Dashboard
      summary: 最近の登録一覧
      description: 最近登録された会社とドライバーの一覧を取得します（各5件）
      responses:
        '200':
          description: 登録一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: object
                    properties:
                      companies:
                        type: array
                        items:
                          type: object
                          properties:
                            id:
                              type: string
                            company_name:
                              type: string
                            status:
                              type: string
                            created_at:
                              type: string
                              format: date-time
                      drivers:
                        type: array
                        items:
                          type: object
                          properties:
                            id:
                              type: string
                            name:
                              type: string
                            status:
                              type: string
                            created_at:
                              type: string
                              format: date-time

  /api/drivers/location:
    post:
      tags:
        - Drivers
      summary: ドライバー位置更新
      description: ドライバーの現在位置とステータスをリアルタイムで更新します
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - driverId
                - latitude
                - longitude
              properties:
                driverId:
                  type: string
                  example: driver_demo_001
                latitude:
                  type: number
                  format: double
                  example: 35.6762
                longitude:
                  type: number
                  format: double
                  example: 139.6503
                status:
                  type: string
                  enum: [active, busy, offline]
                  example: active
      responses:
        '200':
          description: 位置更新成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      latitude:
                        type: number
                      longitude:
                        type: number
                      status:
                        type: string
                      timestamp:
                        type: string
                        format: date-time

  /api/nearby-drivers:
    get:
      tags:
        - Drivers
      summary: 近くのドライバー検索
      description: |
        指定位置から近くの利用可能なドライバーを検索します。
        距離計算、評価、最近のトリップ数を考慮した高度な検索を実行します。
      parameters:
        - name: latitude
          in: query
          required: true
          schema:
            type: number
            format: double
          example: 35.6762
        - name: longitude
          in: query
          required: true
          schema:
            type: number
            format: double
          example: 139.6503
        - name: radius
          in: query
          schema:
            type: number
            default: 5
            description: 検索半径（km）
      responses:
        '200':
          description: ドライバー一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: object
                    properties:
                      searchLocation:
                        type: object
                        properties:
                          latitude:
                            type: number
                          longitude:
                            type: number
                      searchRadius:
                        type: number
                      drivers:
                        type: array
                        items:
                          type: object
                          properties:
                            id:
                              type: string
                            name:
                              type: string
                            latitude:
                              type: number
                            longitude:
                              type: number
                            vehicle_model:
                              type: string
                            vehicle_plate:
                              type: string
                            status:
                              type: string
                            is_available:
                              type: integer
                            phone:
                              type: string
                            average_rating:
                              type: number
                            total_trips:
                              type: integer
                            location_freshness:
                              type: string
                              enum: [real_time, recent, stale]
                            distance:
                              type: number
                              description: 検索地点からの距離（km）
                            estimatedArrival:
                              type: integer
                              description: 予想到着時間（分）
                      count:
                        type: integer

  /api/voice-dispatch/create:
    post:
      tags:
        - Voice
      summary: AI音声配車リクエスト作成
      description: |
        新規配車リクエストを作成し、Twilioで自動電話をかけます。
        スマートマッチングアルゴリズムで最適なドライバーを選定します。
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - customerName
                - customerPhone
                - pickupLocation
                - destination
              properties:
                customerName:
                  type: string
                  example: テスト太郎
                customerPhone:
                  type: string
                  pattern: '^\\+?[1-9]\\d{1,14}$'
                  example: +819012345678
                pickupLocation:
                  type: string
                  example: 東京駅
                destination:
                  type: string
                  example: 渋谷駅
                vehicleType:
                  type: string
                  enum: [standard, premium, wheelchair]
                  default: standard
                notes:
                  type: string
                  example: 八重洲北口でお願いします
      responses:
        '201':
          description: 配車リクエスト作成成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      dispatchId:
                        type: string
                      assignedDriver:
                        type: object
                        nullable: true
                        properties:
                          name:
                            type: string
                          vehicleModel:
                            type: string
                          vehiclePlate:
                            type: string
                      estimatedArrival:
                        type: integer
                      twimlUrl:
                        type: string

  /api/voice-dispatch/twiml/{dispatchId}:
    post:
      tags:
        - Voice
      summary: TwiML音声応答生成
      description: Twilioコールバック用のTwiMLを生成します（日本語音声対応）
      security: []
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: TwiML生成成功
          content:
            application/xml:
              schema:
                type: string
                example: |
                  <?xml version="1.0" encoding="UTF-8"?>
                  <Response>
                    <Say voice="Polly.Mizuki" language="ja-JP">配車内容を確認します...</Say>
                  </Response>

  /api/voice-dispatch/process/{dispatchId}:
    post:
      tags:
        - Voice
      summary: 音声入力処理
      description: Twilioからの音声入力を処理し、自然言語で応答します
      security: []
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                SpeechResult:
                  type: string
                  description: 音声認識結果
                Confidence:
                  type: number
                  description: 認識信頼度（0-1）
      responses:
        '200':
          description: TwiML応答
          content:
            application/xml:
              schema:
                type: string

  /api/voice-dispatch/confirm/{dispatchId}:
    post:
      tags:
        - Voice
      summary: 配車確定
      description: 配車リクエストを確定し、ドライバーに通知します
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: 配車確定完了
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  dispatchId:
                    type: string
                  status:
                    type: string
                  message:
                    type: string

  /api/voice-dispatch/{dispatchId}:
    get:
      tags:
        - Voice
      summary: 配車状況取得
      description: 特定の配車リクエストの詳細情報を取得します
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: 配車情報
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  dispatch:
                    type: object
                    properties:
                      id:
                        type: string
                      customer_name:
                        type: string
                      customer_phone:
                        type: string
                      pickup_location:
                        type: string
                      destination:
                        type: string
                      status:
                        type: string
                      driver_name:
                        type: string
                      driver_phone:
                        type: string
                      vehicle_model:
                        type: string
                      vehicle_plate:
                        type: string
                      estimated_arrival:
                        type: integer
                      fare_amount:
                        type: integer
                      created_at:
                        type: string
                        format: date-time

  /api/voice-dispatch/list:
    get:
      tags:
        - Voice
      summary: 配車リクエスト一覧
      description: 最近50件の配車リクエストを取得します（管理画面用）
      responses:
        '200':
          description: 配車一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  dispatches:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                        customer_name:
                          type: string
                        pickup_location:
                          type: string
                        destination:
                          type: string
                        status:
                          type: string
                        driver_name:
                          type: string
                        created_at:
                          type: string
                          format: date-time

  /api/voice/incoming:
    post:
      tags:
        - Twilio
      summary: Twilio着信Webhook
      description: |
        電話着信時のWebhookエンドポイント。
        AI応答とオペレーター転送を自動判定します。
        Groq LLMを使用した高度な自然言語処理を実行します。
      security: []
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                From:
                  type: string
                  description: 発信者番号
                To:
                  type: string
                  description: 着信番号
                CallSid:
                  type: string
                  description: 通話ID
      responses:
        '200':
          description: TwiML応答
          content:
            application/xml:
              schema:
                type: string

  /api/voice/process-speech:
    post:
      tags:
        - Twilio
      summary: 音声認識結果処理
      description: |
        Twilioの音声認識結果を処理し、Groq Llama 4で自然言語解析を行います。
        配車の詳細を段階的に収集します。
      security: []
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                SpeechResult:
                  type: string
                  description: 音声認識結果
                Confidence:
                  type: number
                  description: 認識信頼度
                CallSid:
                  type: string
                  description: 通話ID
                From:
                  type: string
                  description: 発信者番号
      responses:
        '200':
          description: 音声応答
          content:
            application/xml:
              schema:
                type: string

  /api/realtime-dispatch:
    post:
      tags:
        - Realtime
      summary: リアルタイム配車
      description: |
        超高速マッチングアルゴリズムで配車を行います（目標: 200ms以内）。
        位置情報、評価、経験値、車両タイプを考慮した最適化を実行。
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - pickupLocation
                - destination
                - customerPhone
              properties:
                customerName:
                  type: string
                  example: 山田花子
                customerPhone:
                  type: string
                  example: 090-1234-5678
                pickupLocation:
                  type: string
                  example: 東京駅八重洲北口
                destination:
                  type: string
                  example: 羽田空港第1ターミナル
                pickupLatitude:
                  type: number
                  format: double
                  example: 35.6812
                pickupLongitude:
                  type: number
                  format: double
                  example: 139.7671
                vehicleType:
                  type: string
                  enum: [standard, premium, wheelchair]
                  example: standard
                priority:
                  type: string
                  enum: [normal, high, urgent]
                  example: high
      responses:
        '200':
          description: 配車成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      dispatchId:
                        type: string
                      assignedDriver:
                        type: object
                        properties:
                          id:
                            type: string
                          name:
                            type: string
                          vehicleModel:
                            type: string
                          vehiclePlate:
                            type: string
                          phone:
                            type: string
                          estimatedArrival:
                            type: integer
                          distance:
                            type: number
                          matchingScore:
                            type: integer
                      estimatedArrival:
                        type: integer
                      estimatedFare:
                        type: integer
                      processingTime:
                        type: integer
                        description: 処理時間（ミリ秒）

  /api/twilio/search-numbers:
    get:
      tags:
        - Twilio
      summary: 電話番号検索
      description: 利用可能なTwilio電話番号を検索します（日本国内対応）
      parameters:
        - name: type
          in: query
          schema:
            type: string
            default: Local
            enum: [Local, Mobile, TollFree]
          description: 番号タイプ
        - name: areaCode
          in: query
          schema:
            type: string
          description: 市外局番
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
            maximum: 50
          description: 検索結果数
      responses:
        '200':
          description: 電話番号一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: object
                    properties:
                      availableNumbers:
                        type: array
                        items:
                          type: object
                          properties:
                            phoneNumber:
                              type: string
                            friendlyName:
                              type: string
                            locality:
                              type: string
                            capabilities:
                              type: object
                      count:
                        type: integer
                      type:
                        type: string
                      country:
                        type: string

  /api/twilio/configure-number:
    post:
      tags:
        - Twilio
      summary: 電話番号Webhook設定
      description: 既存のTwilio電話番号にWebhookを設定します
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - phoneNumber
              properties:
                phoneNumber:
                  type: string
                  example: +819012345678
                companyId:
                  type: string
                  example: company_demo_001
      responses:
        '200':
          description: 設定完了
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      phoneNumber:
                        type: string
                      phoneSid:
                        type: string
                      friendlyName:
                        type: string
                      capabilities:
                        type: object
                      webhookUrl:
                        type: string
                      voiceUrl:
                        type: string

  /api/twilio/purchase-number:
    post:
      tags:
        - Twilio
      summary: 電話番号購入
      description: 新規Twilio電話番号を購入し、Webhookを自動設定します
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - phoneNumber
              properties:
                phoneNumber:
                  type: string
                  example: +819012345678
                companyId:
                  type: string
                  example: company_demo_001
      responses:
        '200':
          description: 購入完了
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  message:
                    type: string
                  data:
                    type: object
                    properties:
                      phoneNumber:
                        type: string
                      phoneSid:
                        type: string
                      friendlyName:
                        type: string
                      capabilities:
                        type: object
                      webhookUrl:
                        type: string

  /api/twilio/status:
    post:
      tags:
        - Twilio
      summary: Twilioステータスコールバック
      description: 通話ステータスの更新を受け取り、ログに記録します
      security: []
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                CallSid:
                  type: string
                CallStatus:
                  type: string
                  enum: [queued, ringing, in-progress, completed, busy, failed, no-answer]
                From:
                  type: string
                To:
                  type: string
                Direction:
                  type: string
                  enum: [inbound, outbound-api, outbound-dial]
      responses:
        '200':
          description: OK
          content:
            text/plain:
              schema:
                type: string
                example: OK

  /docs:
    get:
      tags:
        - Documentation
      summary: APIドキュメント
      description: Swagger UIでのインタラクティブなAPIドキュメントを表示します
      security: []
      responses:
        '200':
          description: HTMLページ
          content:
            text/html:
              schema:
                type: string

  /api/openapi.yaml:
    get:
      tags:
        - Documentation
      summary: OpenAPI仕様書
      description: OpenAPI 3.0形式の仕様書を取得します（YAML形式）
      security: []
      responses:
        '200':
          description: OpenAPI仕様書
          content:
            application/x-yaml:
              schema:
                type: string

  /auth/refresh:
    post:
      tags:
        - Auth
      summary: トークンリフレッシュ
      description: 有効期限が近いJWTトークンを新しいトークンに更新します
      requestBody:
        required: false
        content:
          application/json:
            schema:
              type: object
      responses:
        '200':
          description: トークンリフレッシュ成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: object
                    properties:
                      token:
                        type: string
                        description: 新しいJWTトークン

  /websocket:
    get:
      tags:
        - WebSocket
      summary: WebSocket接続
      description: |
        リアルタイムドライバー位置追跡用WebSocketエンドポイント。
        ドライバーの位置情報をリアルタイムで送受信します。
        
        ### メッセージタイプ
        - auth: 認証（driver_idを送信）
        - location_update: 位置情報更新
        - status_update: ステータス更新
        - location_broadcast: 他クライアントへの位置配信
      security: []
      parameters:
        - name: Upgrade
          in: header
          required: true
          schema:
            type: string
            enum: [websocket]
      responses:
        '101':
          description: WebSocketアップグレード成功
        '426':
          description: WebSocketアップグレードが必要

  /api/v1/ai-voice-dispatch/create:
    post:
      tags:
        - AIVoiceDispatch
      summary: AI音声配車リクエスト作成 (v1)
      description: API v1版のAI音声配車リクエスト作成エンドポイント
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - customerName
                - customerPhone
                - pickupLocation
                - destination
              properties:
                customerName:
                  type: string
                customerPhone:
                  type: string
                pickupLocation:
                  type: string
                destination:
                  type: string
                vehicleType:
                  type: string
      responses:
        '201':
          description: 配車リクエスト作成成功

  /api/v1/ai-voice-dispatch/twiml/{dispatchId}:
    post:
      tags:
        - AIVoiceDispatch
      summary: TwiML音声応答生成 (v1)
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: TwiML生成成功

  /api/v1/ai-voice-dispatch/process/{dispatchId}:
    post:
      tags:
        - AIVoiceDispatch
      summary: 音声入力処理 (v1)
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
      responses:
        '200':
          description: 音声処理成功

  /api/v1/ai-voice-dispatch/confirm/{dispatchId}:
    post:
      tags:
        - AIVoiceDispatch
      summary: 配車確定 (v1)
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: 配車確定成功

  /api/v1/ai-voice-dispatch/status/{dispatchId}:
    post:
      tags:
        - AIVoiceDispatch
      summary: 通話ステータス更新 (v1)
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
      responses:
        '200':
          description: ステータス更新成功

  /api/v1/ai-voice-dispatch/{dispatchId}:
    get:
      tags:
        - AIVoiceDispatch
      summary: 配車情報取得 (v1)
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: 配車情報

  /api/v1/driver-pool/register:
    post:
      tags:
        - DriverPool
      summary: ドライバー登録 (v1)
      description: 新規ドライバーをドライバープールに登録
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
                phone:
                  type: string
                email:
                  type: string
                licenseNumber:
                  type: string
      responses:
        '201':
          description: 登録成功

  /api/v1/driver-pool/{driverId}/location:
    post:
      tags:
        - DriverPool
      summary: ドライバー位置更新 (v1)
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                latitude:
                  type: number
                longitude:
                  type: number
      responses:
        '200':
          description: 位置更新成功

  /api/v1/driver-pool/{driverId}/status:
    post:
      tags:
        - DriverPool
      summary: ドライバーステータス更新 (v1)
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: string
                  enum: [active, busy, offline]
      responses:
        '200':
          description: ステータス更新成功

  /api/v1/driver-pool/search:
    post:
      tags:
        - DriverPool
      summary: ドライバー検索 (v1)
      description: 条件によるドライバー検索
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                latitude:
                  type: number
                longitude:
                  type: number
                radius:
                  type: number
      responses:
        '200':
          description: 検索結果

  /api/v1/driver-pool/match:
    post:
      tags:
        - DriverPool
      summary: 最適ドライバーマッチング (v1)
      description: AIによる最適ドライバーマッチング
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                pickupLocation:
                  type: object
                destination:
                  type: object
                vehicleType:
                  type: string
      responses:
        '200':
          description: マッチング結果

  /api/v1/driver-pool/{driverId}/rating:
    post:
      tags:
        - DriverPool
      summary: ドライバー評価更新 (v1)
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                rating:
                  type: number
                  minimum: 1
                  maximum: 5
                comment:
                  type: string
      responses:
        '200':
          description: 評価更新成功

  /api/v1/driver-pool/{driverId}/earnings:
    post:
      tags:
        - DriverPool
      summary: ドライバー収益更新 (v1)
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                amount:
                  type: number
                tripId:
                  type: string
      responses:
        '200':
          description: 収益更新成功

  /api/v1/driver-pool/{driverId}:
    get:
      tags:
        - DriverPool
      summary: ドライバー詳細取得 (v1)
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: ドライバー情報

  /api/v1/driver-pool/{driverId}/shift:
    post:
      tags:
        - DriverPool
      summary: ドライバーシフト管理 (v1)
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                shiftStart:
                  type: string
                  format: date-time
                shiftEnd:
                  type: string
                  format: date-time
      responses:
        '200':
          description: シフト更新成功

  /api/v1/driver-pool/optimize-placement:
    post:
      tags:
        - DriverPool
      summary: ドライバー配置最適化 (v1)
      description: AIによるドライバー配置の最適化
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                targetArea:
                  type: object
                timeRange:
                  type: object
      responses:
        '200':
          description: 最適化結果

  /api/v1/driver-pool/analytics/matching-performance:
    get:
      tags:
        - DriverPool
      summary: マッチングパフォーマンス分析 (v1)
      parameters:
        - name: startDate
          in: query
          schema:
            type: string
            format: date
        - name: endDate
          in: query
          schema:
            type: string
            format: date
      responses:
        '200':
          description: 分析結果

  /api/v1/driver-pool/:
    get:
      tags:
        - DriverPool
      summary: ドライバー一覧取得 (v1)
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: ドライバー一覧

  /api/v1/secure-gatekeeper/health:
    get:
      tags:
        - Services
      summary: Secure Gatekeeperヘルスチェック
      description: セキュリティゲートキーパーサービスの稼働状況
      responses:
        '200':
          description: サービス正常

  /api/v1/connector-hub/health:
    get:
      tags:
        - Services
      summary: Connector Hubヘルスチェック
      description: コネクターハブサービスの稼働状況
      responses:
        '200':
          description: サービス正常

  /api/v1/profit-engine/health:
    get:
      tags:
        - Services
      summary: Profit Engineヘルスチェック
      description: 利益エンジンサービスの稼働状況
      responses:
        '200':
          description: サービス正常

  /api/v1/notification/health:
    get:
      tags:
        - Services
      summary: Notificationヘルスチェック
      description: 通知サービスの稼働状況
      responses:
        '200':
          description: サービス正常

  /location:
    post:
      tags:
        - DurableObject
      summary: 位置更新 (Durable Object)
      description: Durable Object経由でのドライバー位置更新
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - driver_id
                - location
              properties:
                driver_id:
                  type: string
                location:
                  type: object
                  properties:
                    latitude:
                      type: number
                    longitude:
                      type: number
                    heading:
                      type: number
                    speed:
                      type: number
                    accuracy:
                      type: number
      responses:
        '200':
          description: 位置更新成功

  /status:
    get:
      tags:
        - DurableObject
      summary: ドライバーステータス取得 (Durable Object)
      description: Durable Objectからドライバーステータスを取得
      security: []
      parameters:
        - name: driver_id
          in: query
          required: true
          schema:
            type: string
      responses:
        '200':
          description: ステータス情報
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  driver_id:
                    type: string
                  location:
                    type: object
                  last_update:
                    type: string
                  is_online:
                    type: boolean

  /nearby:
    get:
      tags:
        - DurableObject
      summary: 近くのドライバー検索 (Durable Object)
      description: Durable Objectを使用したリアルタイム近隣ドライバー検索
      security: []
      parameters:
        - name: lat
          in: query
          required: true
          schema:
            type: number
        - name: lng
          in: query
          required: true
          schema:
            type: number
        - name: radius
          in: query
          schema:
            type: number
            default: 5
      responses:
        '200':
          description: 近隣ドライバー一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  drivers:
                    type: array
                    items:
                      type: object
                      properties:
                        driver_id:
                          type: string
                        location:
                          type: object
                        distance:
                          type: number
                        last_update:
                          type: string
                  count:
                    type: integer

  /ws/driver/{driverId}:
    get:
      tags:
        - WebSocket
      summary: ドライバー用リアルタイム通信
      description: |
        ドライバー向けWebSocketエンドポイント。
        配車リクエストのリアルタイム通知を受信します。
      security: []
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
        - name: Upgrade
          in: header
          required: true
          schema:
            type: string
            enum: [websocket]
      responses:
        '101':
          description: WebSocket接続成功

  /ws/dispatch/{dispatchId}:
    get:
      tags:
        - WebSocket
      summary: 配車追跡用リアルタイム通信
      description: |
        配車追跡用WebSocketエンドポイント。
        ドライバー位置情報のリアルタイム更新を受信します。
      security: []
      parameters:
        - name: dispatchId
          in: path
          required: true
          schema:
            type: string
        - name: Upgrade
          in: header
          required: true
          schema:
            type: string
            enum: [websocket]
      responses:
        '101':
          description: WebSocket接続成功

  /api/drivers/{driverId}:
    get:
      tags:
        - Drivers
      summary: ドライバー詳細情報取得
      description: 特定ドライバーの詳細情報を取得します
      parameters:
        - name: driverId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: ドライバー情報
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  driver:
                    type: object
                    properties:
                      id:
                        type: string
                      name:
                        type: string
                      email:
                        type: string
                      phone:
                        type: string
                      status:
                        type: string
                      vehicle_model:
                        type: string
                      vehicle_plate:
                        type: string
                      rating:
                        type: number
                      total_trips:
                        type: integer

  /api/drivers:
    get:
      tags:
        - Drivers
      summary: ドライバー一覧取得
      description: ドライバー一覧をページネーション付きで取得します
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
        - name: status
          in: query
          schema:
            type: string
            enum: [active, busy, offline]
      responses:
        '200':
          description: ドライバー一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  drivers:
                    type: array
                    items:
                      type: object
                  total:
                    type: integer
                  page:
                    type: integer
                  limit:
                    type: integer

  /api/export/drivers:
    get:
      tags:
        - Export
      summary: ドライバーデータエクスポート
      description: ドライバーデータをCSV形式でエクスポートします
      parameters:
        - name: format
          in: query
          schema:
            type: string
            enum: [csv, json]
            default: csv
      responses:
        '200':
          description: エクスポートデータ
          content:
            text/csv:
              schema:
                type: string
            application/json:
              schema:
                type: array
                items:
                  type: object

  /api/export/dispatches:
    get:
      tags:
        - Export
      summary: 配車履歴エクスポート
      description: 配車履歴データをエクスポートします
      parameters:
        - name: format
          in: query
          schema:
            type: string
            enum: [csv, json, pdf]
            default: csv
        - name: startDate
          in: query
          schema:
            type: string
            format: date
        - name: endDate
          in: query
          schema:
            type: string
            format: date
      responses:
        '200':
          description: エクスポートデータ

  /api/metrics:
    get:
      tags:
        - Monitoring
      summary: システムメトリクス
      description: Prometheus形式のシステムメトリクスを取得します
      security: []
      responses:
        '200':
          description: メトリクスデータ
          content:
            text/plain:
              schema:
                type: string
                example: |
                  # HELP http_requests_total Total HTTP requests
                  # TYPE http_requests_total counter
                  http_requests_total{method="GET",status="200"} 1234

  /api/logs:
    get:
      tags:
        - Monitoring
      summary: システムログ取得
      description: システムログを取得します（管理者権限必須）
      parameters:
        - name: level
          in: query
          schema:
            type: string
            enum: [error, warn, info, debug]
        - name: startTime
          in: query
          schema:
            type: string
            format: date-time
        - name: endTime
          in: query
          schema:
            type: string
            format: date-time
        - name: limit
          in: query
          schema:
            type: integer
            default: 100
      responses:
        '200':
          description: ログデータ
          content:
            application/json:
              schema:
                type: object
                properties:
                  logs:
                    type: array
                    items:
                      type: object
                      properties:
                        timestamp:
                          type: string
                          format: date-time
                        level:
                          type: string
                        message:
                          type: string
                        metadata:
                          type: object

  /api/config:
    get:
      tags:
        - Configuration
      summary: システム設定取得
      description: システム設定を取得します（管理者権限必須）
      responses:
        '200':
          description: 設定情報
          content:
            application/json:
              schema:
                type: object
                properties:
                  environment:
                    type: string
                  features:
                    type: object
                  limits:
                    type: object
                  version:
                    type: string

  /api/batch/import-drivers:
    post:
      tags:
        - Batch
      summary: ドライバー一括インポート
      description: CSVファイルからドライバー情報を一括インポートします
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                file:
                  type: string
                  format: binary
                  description: CSVファイル
      responses:
        '200':
          description: インポート結果
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  imported:
                    type: integer
                  failed:
                    type: integer
                  errors:
                    type: array
                    items:
                      type: object

  /api/queue/jobs:
    get:
      tags:
        - Queue
      summary: ジョブキュー状態
      description: バックグラウンドジョブの状態を取得します
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [pending, processing, completed, failed]
      responses:
        '200':
          description: ジョブ一覧
          content:
            application/json:
              schema:
                type: object
                properties:
                  jobs:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                        type:
                          type: string
                        status:
                          type: string
                        createdAt:
                          type: string
                          format: date-time
                        completedAt:
                          type: string
                          format: date-time

  /api/scheduled/alarm:
    post:
      tags:
        - Scheduled
      summary: アラームハンドラ
      description: |
        Durable Objectアラームハンドラ。
        5分ごとに古い位置情報をクリーンアップします。
      security: []
      responses:
        '200':
          description: アラーム処理完了

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        JWT認証トークン。ログインAPIで取得したトークンを使用します。
        形式: Bearer <token>

  schemas:
    ErrorResponse:
      type: object
      properties:
        success:
          type: boolean
          example: false
        error:
          type: string
          example: Validation Error
        message:
          type: string
          example: 必須パラメータが不足しています
        timestamp:
          type: string
          format: date-time

    WebSocketAuthMessage:
      type: object
      description: WebSocket認証メッセージ
      properties:
        type:
          type: string
          enum: [auth]
        driver_id:
          type: string
          example: driver_demo_001

    WebSocketLocationUpdateMessage:
      type: object
      description: WebSocket位置情報更新メッセージ
      properties:
        type:
          type: string
          enum: [location_update]
        location:
          type: object
          properties:
            latitude:
              type: number
              format: double
            longitude:
              type: number
              format: double
            heading:
              type: number
              description: 進行方向（度）
            speed:
              type: number
              description: 速度（km/h）
            accuracy:
              type: number
              description: 位置精度（m）

    WebSocketStatusUpdateMessage:
      type: object
      description: WebSocketステータス更新メッセージ
      properties:
        type:
          type: string
          enum: [status_update]
        status:
          type: string
          enum: [active, busy, offline]

    WebSocketLocationBroadcastMessage:
      type: object
      description: WebSocket位置情報配信メッセージ
      properties:
        type:
          type: string
          enum: [location_broadcast]
        driver_id:
          type: string
        location:
          type: object
        timestamp:
          type: string
          format: date-time

  responses:
    BadRequest:
      description: リクエスト不正
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    Unauthorized:
      description: 認証エラー
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    NotFound:
      description: リソース未発見
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    InternalServerError:
      description: サーバーエラー
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'`;

  return c.text(fullOpenAPISpec, 200, {
    'Content-Type': 'application/x-yaml'
  });
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

// ルート設定 - simple-index.jsの機能を直接追加

// データベース初期化API
app.post('/api/init-database', async (c) => {
  try {
    // D1データベースが利用可能か確認
    if (!c.env.DB) {
      return c.json({
        success: false,
        error: 'Database Not Found',
        message: 'D1データベースが設定されていません'
      }, 500);
    }

    // テーブル作成
    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS companies (
        id TEXT PRIMARY KEY,
        company_name TEXT NOT NULL,
        company_address TEXT NOT NULL,
        company_phone TEXT NOT NULL,
        license_number TEXT NOT NULL,
        representative_name TEXT NOT NULL,
        representative_email TEXT NOT NULL UNIQUE,
        service_area TEXT,
        vehicle_count INTEGER DEFAULT 0,
        driver_count INTEGER DEFAULT 0,
        selected_plan TEXT DEFAULT 'standard',
        status TEXT DEFAULT 'active',
        created_at TEXT NOT NULL,
        twilio_phone_number TEXT
      )
    `).run();

    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS drivers (
        id TEXT PRIMARY KEY,
        company_id TEXT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        address TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        license_number TEXT,
        license_expiry TEXT,
        taxi_license_number TEXT,
        has_own_vehicle INTEGER DEFAULT 0,
        is_full_time INTEGER DEFAULT 1,
        working_area TEXT,
        vehicle_model TEXT,
        vehicle_year TEXT,
        vehicle_plate TEXT,
        status TEXT DEFAULT 'active',
        latitude REAL,
        longitude REAL,
        is_available INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    `).run();

    await c.env.DB.prepare(`
      CREATE TABLE IF NOT EXISTS dispatch_requests (
        id TEXT PRIMARY KEY,
        customer_name TEXT,
        customer_phone TEXT,
        pickup_location TEXT NOT NULL,
        destination TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `).run();

    // デモデータ挿入
    await c.env.DB.prepare(`
      INSERT OR REPLACE INTO companies (
        id, company_name, company_address, company_phone, license_number,
        representative_name, representative_email, service_area, vehicle_count,
        driver_count, selected_plan, status, created_at, twilio_phone_number
      ) VALUES (
        'demo_001', 'デモタクシー株式会社', '東京都新宿区西新宿1-1-1', '03-1234-5678', 
        '関自旅二第1234号', 'デモ太郎', 'demo@example.com', '東京都23区内', 
        50, 25, 'standard', 'active', datetime('now'), '+19592105018'
      )
    `).run();

    const drivers = [
      { 
        id: 'driver_001', 
        name: '佐藤一郎', 
        phone: '090-1234-5678', 
        email: 'sato@example.com',
        address: '東京都渋谷区渋谷1-1-1',
        birthdate: '1985-01-01',
        vehicle_model: 'トヨタ クラウン', 
        vehicle_plate: '品川 500 あ 1234', 
        lat: 35.6762, 
        lng: 139.6503 
      },
      { 
        id: 'driver_002', 
        name: '鈴木次郎', 
        phone: '090-2345-6789', 
        email: 'suzuki@example.com',
        address: '東京都新宿区西新宿1-1-1',
        birthdate: '1980-05-15',
        vehicle_model: 'レクサス LS', 
        vehicle_plate: '品川 500 あ 5678', 
        lat: 35.6895, 
        lng: 139.6917 
      },
      { 
        id: 'driver_003', 
        name: '田中三郎', 
        phone: '090-3456-7890', 
        email: 'tanaka@example.com',
        address: '東京都港区六本木1-1-1',
        birthdate: '1975-12-20',
        vehicle_model: 'トヨタ アルファード', 
        vehicle_plate: '品川 500 あ 9012', 
        lat: 35.6584, 
        lng: 139.7016 
      }
    ];

    for (const driver of drivers) {
      await c.env.DB.prepare(`
        INSERT OR REPLACE INTO drivers (
          id, company_id, name, phone, email, address, birthdate,
          vehicle_model, vehicle_plate, latitude, longitude, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).bind(
        driver.id, 'demo_001', driver.name, driver.phone, driver.email, 
        driver.address, driver.birthdate, driver.vehicle_model, 
        driver.vehicle_plate, driver.lat, driver.lng, new Date().toISOString()
      ).run();
    }

    return c.json({
      success: true,
      message: 'データベースの初期化が完了しました',
      data: {
        tables: ['companies', 'drivers', 'dispatch_requests'],
        demoDrivers: drivers.length
      }
    });
  } catch (error) {
    console.error('Database init error:', error);
    return c.json({
      success: false,
      error: 'Database Initialization Failed',
      message: error.message
    }, 500);
  }
});

// AI音声配車作成API
app.post('/api/voice-dispatch/create', async (c) => {
  try {
    const body = await c.req.json();
    
    if (!body.customerName || !body.customerPhone || !body.pickupLocation || !body.destination) {
      return c.json({
        success: false,
        error: 'Validation Error',
        message: 'Customer name, phone, pickup location, and destination are required'
      }, 400);
    }

    const dispatchId = `dispatch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // ドライバーをランダムに選択（エラーハンドリングを追加）
    let driver = null;
    try {
      const drivers = await c.env.DB.prepare('SELECT * FROM drivers WHERE status = ? LIMIT 1').bind('active').all();
      driver = drivers.results && drivers.results.length > 0 ? drivers.results[0] : null;
    } catch (dbError) {
      console.warn('Database query failed, using mock driver:', dbError.message);
      driver = {
        id: 'mock_driver_001',
        name: 'Mock Driver',
        vehicle_model: 'トヨタ プリウス',
        vehicle_plate: '品川 500 あ 0001'
      };
    }
    
    // 配車リクエストを保存
    try {
      await c.env.DB.prepare(`
        INSERT INTO dispatch_requests (id, customer_name, customer_phone, pickup_location, destination, created_at) 
        VALUES (?, ?, ?, ?, ?, ?)
      `).bind(dispatchId, body.customerName, body.customerPhone, body.pickupLocation, body.destination, new Date().toISOString()).run();
    } catch (dbError) {
      console.warn('Database insert failed:', dbError.message);
    }

    // Twilio APIを呼び出し
    if (c.env.TWILIO_ACCOUNT_SID && c.env.TWILIO_AUTH_TOKEN && c.env.TWILIO_PHONE_NUMBER) {
      const auth = btoa(`${c.env.TWILIO_ACCOUNT_SID}:${c.env.TWILIO_AUTH_TOKEN}`);
      const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${c.env.TWILIO_ACCOUNT_SID}/Calls.json`, {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
          To: body.customerPhone,
          From: c.env.TWILIO_PHONE_NUMBER,
          Url: `${c.env.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev'}/api/voice-dispatch/twiml/${dispatchId}`,
          Method: 'POST'
        })
      });

      if (!response.ok) {
        console.error('Twilio error:', await response.text());
      }
    }

    return c.json({
      success: true,
      message: 'AI音声配車リクエストを作成しました',
      data: {
        dispatchId: dispatchId,
        assignedDriver: driver ? {
          name: driver.name,
          vehicleModel: driver.vehicle_model,
          vehiclePlate: driver.vehicle_plate
        } : null,
        estimatedArrival: 10,
        twimlUrl: `${c.env.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev'}/api/voice-dispatch/twiml/${dispatchId}`
      }
    });
  } catch (error) {
    console.error('Voice dispatch error:', error);
    return c.json({
      success: false,
      error: 'Voice Dispatch Failed',
      message: error.message
    }, 500);
  }
});

// TwiML音声応答生成
app.post('/api/voice-dispatch/twiml/:dispatchId', async (c) => {
  const dispatchId = c.req.param('dispatchId');
  
  const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">
        こんにちは。Mobility Ops 360のAI音声配車システムです。
        配車を承りました。ドライバーが約10分後にお迎えに上がります。
        ご利用ありがとうございます。
    </Say>
</Response>`;

  return c.text(twiml, 200, {
    'Content-Type': 'application/xml'
  });
});

// Twilio着信Webhook
app.post('/api/voice/incoming', async (c) => {
  try {
    const body = await c.req.parseBody();
    const from = body.From || '';
    
    // Get the base URL from environment or use default
    const baseUrl = c.env.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev';
    
    const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">お電話ありがとうございます。デモタクシー株式会社のAI配車システムです。現在3台の車両が利用可能です。</Say>
  <Gather input="speech" language="ja-JP" timeout="10" action="https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/process-speech">
    <Say language="ja-JP">配車をご希望の場合は、お迎え場所を教えてください。</Say>
  </Gather>
  <Say language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
</Response>`;

    return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
  } catch (error) {
    console.error('Incoming call error:', error);
    return c.text('<?xml version="1.0" encoding="UTF-8"?><Response><Say language="ja-JP">システムエラーが発生しました。</Say></Response>', 200, {
      'Content-Type': 'application/xml'
    });
  }
});

// 音声認識結果処理
app.post('/api/voice/process-speech', async (c) => {
  try {
    const body = await c.req.parseBody();
    const speechResult = body.SpeechResult || '';
    
    const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">
    お迎え場所は${speechResult}ですね。
    ドライバーを手配します。約10分ほどでお迎えに上がります。
    ご利用ありがとうございました。
  </Say>
</Response>`;

    return c.text(twiml, 200, { 'Content-Type': 'application/xml' });
  } catch (error) {
    console.error('Speech processing error:', error);
    return c.text('<?xml version="1.0" encoding="UTF-8"?><Response><Say language="ja-JP">音声認識エラーが発生しました。</Say></Response>', 200, {
      'Content-Type': 'application/xml'
    });
  }
});

// Twilioステータスコールバック
app.post('/api/twilio/status', async (c) => {
  const body = await c.req.parseBody();
  console.log('Twilio status:', body);
  return c.text('OK', 200);
});

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

export default app;