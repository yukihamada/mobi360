# Mobility Ops 360 API Documentation

**Version**: 1.0.0  
**Base URL**: https://api.mobility360.jp  
**Current Environment**: https://mobi360-api.yukihamada.workers.dev

## 🚀 概要

Mobility Ops 360は、タクシー業界向けのAI配車システムAPIです。音声認識、リアルタイム配車、ドライバーマッチング、料金最適化など、包括的な機能を提供します。

### 主な機能
- 🎙️ **AI音声配車**: Twilio統合による自動音声応答
- 🚗 **リアルタイムマッチング**: 最適なドライバーを数百ms以内で検索
- 📍 **位置情報追跡**: ドライバーの現在地をリアルタイム更新
- 💰 **動的料金計算**: 距離・時間・需要に基づく料金最適化
- 🔐 **セキュア認証**: JWT + Bearer Token

---

## 🔑 認証

### Bearer Token認証
```
Authorization: Bearer <token>
```

### トークン取得
```bash
POST /auth/login
Content-Type: application/json

{
  "email": "demo@example.com",
  "password": "pass1234",
  "userType": "company"
}
```

---

## 📋 エンドポイント一覧

### 🏥 ヘルスチェック

#### GET /health
システムの稼働状況を確認

**レスポンス例**:
```json
{
  "status": "healthy",
  "timestamp": "2025-07-13T14:37:52.882Z",
  "environment": "production",
  "version": "1.0.0"
}
```

---

### 🔐 認証・登録

#### POST /auth/register/company
タクシー会社の新規登録

**リクエスト**:
```json
{
  "companyName": "東京タクシー株式会社",
  "companyAddress": "東京都渋谷区渋谷1-1-1",
  "companyPhone": "03-1234-5678",
  "licenseNumber": "TAXI-2024-001",
  "representativeName": "田中太郎",
  "representativeEmail": "tanaka@tokyo-taxi.com",
  "serviceArea": "東京23区",
  "vehicleCount": 50,
  "driverCount": 100,
  "selectedPlan": "premium"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "会社登録が完了しました",
  "data": {
    "companyId": "company_1234567890_abc123",
    "userType": "company"
  }
}
```

#### POST /auth/register/driver
ドライバーの新規登録

**リクエスト**:
```json
{
  "name": "山田太郎",
  "phone": "090-1234-5678",
  "email": "yamada@example.com",
  "address": "東京都新宿区新宿1-1-1",
  "birthdate": "1980-01-01",
  "licenseNumber": "DL-123456",
  "licenseExpiry": "2030-12-31",
  "taxiLicenseNumber": "TX-789012",
  "hasOwnVehicle": true,
  "isFullTime": true,
  "workingArea": "新宿・渋谷・池袋",
  "vehicleModel": "トヨタ クラウン",
  "vehicleYear": "2022",
  "vehiclePlate": "品川 500 あ 1234",
  "insuranceNumber": "INS-456789",
  "bankName": "みずほ銀行",
  "branchName": "新宿支店",
  "accountNumber": "1234567",
  "accountHolder": "ヤマダ タロウ"
}
```

#### POST /auth/login
ログイン認証

**リクエスト**:
```json
{
  "email": "demo@example.com",
  "password": "pass1234",
  "userType": "company"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "ログインに成功しました",
  "data": {
    "user": {
      "id": "company_demo_001",
      "name": "デモタクシー株式会社",
      "email": "demo@example.com",
      "type": "company",
      "phoneNumber": "+12407927324",
      "companyPhone": "03-1234-5678",
      "aiRoutingEnabled": true
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### GET /auth/verify
トークン検証

**ヘッダー**:
```
Authorization: Bearer <token>
```

---

### 🎙️ AI音声配車

#### POST /api/voice-dispatch/create
AI音声配車リクエストの作成

**リクエスト**:
```json
{
  "customerName": "鈴木花子",
  "customerPhone": "+819012345678",
  "pickupLocation": "東京駅八重洲口",
  "destination": "羽田空港第1ターミナル",
  "vehicleType": "standard",
  "notes": "スーツケース2個あります"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "AI音声配車リクエストを作成しました",
  "data": {
    "dispatchId": "dispatch_1234567890_xyz789",
    "assignedDriver": {
      "name": "佐藤一郎",
      "vehicleModel": "トヨタ クラウン",
      "vehiclePlate": "品川 500 あ 1234"
    },
    "estimatedArrival": 10,
    "twimlUrl": "/api/voice-dispatch/twiml/dispatch_1234567890_xyz789"
  }
}
```

#### POST /api/voice-dispatch/twiml/:dispatchId
TwiML音声応答の生成（Twilioコールバック用）

**レスポンス** (XML):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">
        こんにちは、鈴木花子様。
        Mobility Ops 360のAI音声配車システムです。
        東京駅八重洲口から羽田空港第1ターミナルへの配車をご依頼いただき、ありがとうございます。
        担当ドライバーは佐藤一郎です。車両はトヨタ クラウン、ナンバープレートは品川 500 あ 1234です。
        到着予定時刻は約10分後となります。
        この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。
    </Say>
    <Gather input="speech" speechTimeout="auto" language="ja-JP" 
            action="/api/voice-dispatch/process/dispatch_1234567890_xyz789">
        <Say voice="Polly.Mizuki" language="ja-JP">お返事をお聞かせください。</Say>
    </Gather>
    <Say voice="Polly.Mizuki" language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
    <Hangup/>
</Response>
```

#### POST /api/voice-dispatch/process/:dispatchId
音声入力の処理（Twilioコールバック用）

**リクエスト** (form-data):
```
SpeechResult: はい、お願いします
Confidence: 0.95
CallSid: CA1234567890abcdef
From: +819012345678
To: +12407927324
```

#### POST /api/voice-dispatch/confirm/:dispatchId
配車の確定

**レスポンス**:
```json
{
  "success": true,
  "dispatchId": "dispatch_1234567890_xyz789",
  "status": "confirmed",
  "message": "AI音声配車が確定しました"
}
```

#### GET /api/voice-dispatch/:dispatchId
配車状況の取得

#### GET /api/voice-dispatch/list
配車リクエスト一覧（管理画面用）

---

### 📞 音声着信処理

#### POST /api/voice/incoming
Twilio着信時のWebhook（自動配車振り分け）

**Twilioからのリクエスト** (form-data):
```
From: +819012345678
To: +12407927324
CallSid: CA1234567890abcdef
```

**レスポンス** (XML):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">
    お電話ありがとうございます。デモタクシー株式会社のAI配車システムです。
    現在3台の車両が利用可能です。
  </Say>
  <Gather input="speech" language="ja-JP" timeout="10" action="/api/voice/process-speech">
    <Say language="ja-JP">配車をご希望の場合は、お迎え場所を教えてください。</Say>
  </Gather>
  <Say language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
</Response>
```

#### POST /api/voice/process-speech
音声認識結果の処理（Groq LLM統合）

---

### 🚗 リアルタイム配車

#### POST /api/realtime-dispatch
超高速リアルタイム配車（数百ms以内）

**リクエスト**:
```json
{
  "customerName": "高橋次郎",
  "customerPhone": "+819087654321",
  "pickupLocation": "新宿駅南口",
  "destination": "東京スカイツリー",
  "pickupLatitude": 35.689506,
  "pickupLongitude": 139.700464,
  "vehicleType": "premium",
  "priority": "high"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "リアルタイム配車が完了しました（156ms）",
  "data": {
    "dispatchId": "dispatch_1234567890_abc456",
    "assignedDriver": {
      "id": "driver_demo_002",
      "name": "鈴木次郎",
      "vehicleModel": "レクサス LS",
      "vehiclePlate": "品川 500 あ 5678",
      "phone": "090-2345-6789",
      "estimatedArrival": 8,
      "distance": 2.3,
      "matchingScore": 195
    },
    "estimatedArrival": 8,
    "estimatedFare": 1960,
    "processingTime": 156
  }
}
```

---

### 📍 ドライバー管理

#### POST /api/drivers/location
ドライバー位置情報の更新

**リクエスト**:
```json
{
  "driverId": "driver_demo_001",
  "latitude": 35.6762,
  "longitude": 139.6503,
  "status": "active"
}
```

#### GET /api/nearby-drivers
近くの利用可能ドライバー検索

**パラメータ**:
- `latitude`: 緯度（必須）
- `longitude`: 経度（必須）
- `radius`: 検索半径（km、デフォルト: 5）

**リクエスト例**:
```
GET /api/nearby-drivers?latitude=35.6762&longitude=139.6503&radius=3
```

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "searchLocation": {
      "latitude": 35.6762,
      "longitude": 139.6503
    },
    "searchRadius": 3,
    "drivers": [
      {
        "id": "driver_demo_001",
        "name": "佐藤一郎",
        "latitude": 35.6762,
        "longitude": 139.6503,
        "vehicle_model": "トヨタ クラウン",
        "vehicle_plate": "品川 500 あ 1234",
        "status": "active",
        "is_available": 1,
        "phone": "090-1234-5678",
        "average_rating": 4.8,
        "total_trips": 127,
        "location_freshness": "real_time",
        "distance": 0.0,
        "estimatedArrival": 3
      }
    ],
    "count": 1
  }
}
```

---

### 📊 ダッシュボード

#### GET /api/dashboard/stats
統計情報の取得

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "companies": 15,
    "drivers": 347,
    "todayDispatches": 892,
    "activeDrivers": 256,
    "costReduction": 75.0,
    "driverSufficiency": 95.0,
    "profitIncrease": 12.0,
    "systemUptime": 99.9
  }
}
```

#### GET /api/dashboard/recent-registrations
最近の登録情報

---

### 📱 Twilio管理

#### GET /api/twilio/search-numbers
利用可能な電話番号の検索

**パラメータ**:
- `type`: Local/Mobile/TollFree（デフォルト: Local）
- `areaCode`: 市外局番
- `limit`: 検索結果数（デフォルト: 10）

#### POST /api/twilio/configure-number
既存電話番号のWebhook設定

**リクエスト**:
```json
{
  "phoneNumber": "+12407927324",
  "companyId": "company_demo_001"
}
```

#### POST /api/twilio/purchase-number
新規電話番号の購入

#### POST /api/twilio/status
Twilioステータスコールバック

---

### 🗄️ データベース管理

#### POST /api/init-database
データベースの初期化（開発用）

**レスポンス**:
```json
{
  "success": true,
  "message": "データベースの初期化が完了しました",
  "data": {
    "tables": [
      "companies",
      "drivers",
      "dispatch_requests",
      "voice_dispatch_logs",
      "driver_ratings",
      "driver_performance",
      "twilio_logs"
    ],
    "demoCompany": "company_demo_001",
    "demoDrivers": 3,
    "loginCredentials": {
      "email": "demo@example.com",
      "password": "pass1234",
      "userType": "company"
    }
  }
}
```

---

## 🚨 エラーハンドリング

### エラーレスポンス形式
```json
{
  "success": false,
  "error": "Error Type",
  "message": "詳細なエラーメッセージ",
  "timestamp": "2025-07-13T14:37:52.882Z"
}
```

### HTTPステータスコード
- `200 OK`: 成功
- `201 Created`: リソース作成成功
- `400 Bad Request`: リクエスト不正
- `401 Unauthorized`: 認証エラー
- `404 Not Found`: リソース未発見
- `500 Internal Server Error`: サーバーエラー

### 一般的なエラー

#### 認証エラー
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "認証トークンが必要です"
}
```

#### バリデーションエラー
```json
{
  "success": false,
  "error": "Validation Error",
  "message": "Customer name, phone, pickup location, and destination are required"
}
```

#### Twilio設定エラー
```json
{
  "success": false,
  "error": "Configuration Error",
  "message": "Twilio credentials not configured"
}
```

---

## 🔄 レート制限

- **認証なしエンドポイント**: 100リクエスト/分
- **認証ありエンドポイント**: 1000リクエスト/分
- **Twilio Webhook**: 無制限

---

## 🛡️ セキュリティ

### CORS設定
```
Access-Control-Allow-Origin: http://localhost:3000, https://mobi360.app
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
```

### 推奨事項
1. **HTTPS必須**: すべての通信はHTTPS経由
2. **トークン有効期限**: 24時間
3. **IP制限**: 本番環境では信頼できるIPのみ許可
4. **ログ監視**: 異常なアクセスパターンの検知

---

## 📞 Twilioインテグレーション

### Webhook設定
1. Twilioコンソールで電話番号を選択
2. Voice Configurationで以下を設定：
   - **A CALL COMES IN**: 
     - URL: `https://api.mobility360.jp/api/voice/incoming`
     - Method: POST
   - **CALL STATUS CHANGES**:
     - URL: `https://api.mobility360.jp/api/twilio/status`
     - Method: POST

### 音声フロー
1. 顧客が電話 → Twilioが着信Webhookを送信
2. AI音声応答でお迎え場所を確認
3. Groq LLMで自然言語処理
4. 最適ドライバーをリアルタイムマッチング
5. 配車確定と顧客への通知

---

## 🚀 クイックスタート

### 1. 初期設定
```bash
# データベース初期化
curl -X POST https://api.mobility360.jp/api/init-database

# ログイン
curl -X POST https://api.mobility360.jp/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "pass1234",
    "userType": "company"
  }'
```

### 2. AI配車テスト
```bash
# 配車リクエスト作成
curl -X POST https://api.mobility360.jp/api/voice-dispatch/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+819012345678",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅",
    "vehicleType": "standard"
  }'
```

### 3. リアルタイム位置更新
```bash
# ドライバー位置更新
curl -X POST https://api.mobility360.jp/api/drivers/location \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "driverId": "driver_demo_001",
    "latitude": 35.6762,
    "longitude": 139.6503,
    "status": "active"
  }'
```

---

## 📱 SDK/ライブラリ

### JavaScript/TypeScript
```javascript
const MobilityOps360 = require('@mobility360/sdk');

const client = new MobilityOps360({
  apiKey: 'your-api-key',
  baseUrl: 'https://api.mobility360.jp'
});

// 配車リクエスト
const dispatch = await client.dispatch.create({
  customerName: '田中太郎',
  customerPhone: '+819012345678',
  pickupLocation: '東京駅',
  destination: '羽田空港'
});
```

### Flutter/Dart
```dart
import 'package:mobility360/mobility360.dart';

final client = MobilityOps360Client(
  apiKey: 'your-api-key',
  baseUrl: 'https://api.mobility360.jp',
);

// 近くのドライバー検索
final drivers = await client.drivers.nearby(
  latitude: 35.6762,
  longitude: 139.6503,
  radius: 5,
);
```

---

## 📞 サポート

### 技術サポート
- Email: support@mobility360.jp
- Slack: #mobility360-api
- GitHub Issues: https://github.com/mobility360/api/issues

### 営業時間
- 平日: 9:00-18:00 JST
- 緊急対応: 24/7（プレミアムプランのみ）

---

## 🔄 更新履歴

### v1.0.0 (2025-07-13)
- 初回リリース
- AI音声配車機能
- リアルタイムドライバーマッチング
- Twilio統合
- Groq LLM自然言語処理

### ロードマップ
- v1.1.0: 多言語対応（英語・中国語）
- v1.2.0: 決済システム統合（Stripe）
- v1.3.0: 需要予測AI
- v2.0.0: GraphQL API対応