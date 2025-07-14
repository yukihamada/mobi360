# Mobility Ops 360 API仕様書

## ベースURL
- 開発環境: `http://localhost:56523`
- 本番環境: `https://api.mobility360.jp`

## 認証
- JWT Bearer Token認証
- APIキー認証（外部連携用）

---

## 1. ヘルスチェック・システム

### GET /health
システムの稼働状況を確認

**レスポンス**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-10T14:30:00Z",
  "environment": "development",
  "version": "1.0.0"
}
```

---

## 2. 認証・登録

### POST /auth/register/company
タクシー会社の新規登録

**リクエスト**
```json
{
  "companyName": "デモタクシー株式会社",
  "companyAddress": "東京都新宿区西新宿1-1-1",
  "companyPhone": "03-1234-5678",
  "licenseNumber": "関自旅二第1234号",
  "representativeName": "代表太郎",
  "representativeEmail": "demo@example.com",
  "serviceArea": "東京都23区内",
  "vehicleCount": "50",
  "driverCount": "25",
  "selectedPlan": "standard"
}
```

**レスポンス**
```json
{
  "success": true,
  "message": "会社登録が完了しました",
  "data": {
    "companyId": "company_1234567890_abcdefghi",
    "userType": "company"
  }
}
```

### POST /auth/register/driver
ドライバーの新規登録

**リクエスト**
```json
{
  "name": "ドライバー太郎",
  "phone": "090-1234-5678",
  "email": "driver@example.com",
  "address": "東京都渋谷区渋谷1-1-1",
  "birthdate": "1985-01-01",
  "licenseNumber": "123456789012",
  "licenseExpiry": "2028-01-01",
  "taxiLicenseNumber": "第12345号",
  "hasOwnVehicle": true,
  "isFullTime": true,
  "workingArea": "東京都23区内",
  "vehicleModel": "トヨタ プリウス",
  "vehicleYear": "2020",
  "vehiclePlate": "品川500あ12-34",
  "insuranceNumber": "ABC123456",
  "bankName": "三菱UFJ銀行",
  "branchName": "新宿支店",
  "accountNumber": "1234567",
  "accountHolder": "ドライバー太郎"
}
```

**レスポンス**
```json
{
  "success": true,
  "message": "ドライバー登録が完了しました",
  "data": {
    "driverId": "driver_1234567890_abcdefghi",
    "userType": "driver"
  }
}
```

---

## 3. AI音声配車システム

### POST /api/voice-dispatch/create
AI音声配車リクエストの作成

**リクエスト**
```json
{
  "customerName": "田中太郎",
  "customerPhone": "090-1234-5678",
  "pickupLocation": "新宿駅東口",
  "destination": "渋谷駅",
  "vehicleType": "standard"
}
```

**レスポンス**
```json
{
  "success": true,
  "message": "AI音声配車リクエストを作成しました",
  "data": {
    "dispatchId": "dispatch_1234567890_abcdefghi",
    "assignedDriver": {
      "name": "佐藤ドライバー",
      "vehicleModel": "トヨタ プリウス",
      "vehiclePlate": "品川500あ12-34"
    },
    "estimatedArrival": 10,
    "twimlUrl": "/api/voice-dispatch/twiml/dispatch_1234567890_abcdefghi"
  }
}
```

### POST /api/voice-dispatch/twiml/:dispatchId
TwiML音声応答の生成

**レスポンス (XML)**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">
        こんにちは、田中太郎様。
        Mobility Ops 360のAI音声配車システムです。
        新宿駅東口から渋谷駅への配車をご依頼いただき、ありがとうございます。
        担当ドライバーは佐藤ドライバーです。
        車両はトヨタ プリウス、ナンバープレートは品川500あ12-34です。
        到着予定時刻は約10分後となります。
        この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。
    </Say>
    <Gather input="speech" speechTimeout="auto" language="ja-JP" 
            action="/api/voice-dispatch/process/dispatch_1234567890_abcdefghi">
        <Say voice="Polly.Mizuki" language="ja-JP">お返事をお聞かせください。</Say>
    </Gather>
    <Say voice="Polly.Mizuki" language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
    <Hangup/>
</Response>
```

### POST /api/voice-dispatch/process/:dispatchId
音声入力の処理

**リクエスト (Twilio Webhook)**
```json
{
  "SpeechResult": "はい、お願いします",
  "Confidence": "0.95"
}
```

**レスポンス (XML)**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">
        ありがとうございます。配車を確定いたします。
        佐藤ドライバーが約10分後にお迎えにあがります。
        車両はトヨタ プリウス、ナンバープレートは品川500あ12-34です。
        お待ちください。失礼いたします。
    </Say>
    <Hangup/>
</Response>
```

### POST /api/voice-dispatch/confirm/:dispatchId
配車の確定

**レスポンス**
```json
{
  "success": true,
  "dispatchId": "dispatch_1234567890_abcdefghi",
  "status": "confirmed",
  "message": "AI音声配車が確定しました"
}
```

### GET /api/voice-dispatch/:dispatchId
配車状況の取得

**レスポンス**
```json
{
  "success": true,
  "dispatch": {
    "id": "dispatch_1234567890_abcdefghi",
    "customer_name": "田中太郎",
    "customer_phone": "090-1234-5678",
    "pickup_location": "新宿駅東口",
    "destination": "渋谷駅",
    "status": "confirmed",
    "driver_name": "佐藤ドライバー",
    "vehicle_model": "トヨタ プリウス",
    "vehicle_plate": "品川500あ12-34",
    "estimated_arrival": 10,
    "created_at": "2024-01-10T14:30:00Z"
  }
}
```

### GET /api/voice-dispatch/list
配車リクエスト一覧の取得

**レスポンス**
```json
{
  "success": true,
  "dispatches": [
    {
      "id": "dispatch_1234567890_abcdefghi",
      "customer_name": "田中太郎",
      "pickup_location": "新宿駅東口",
      "destination": "渋谷駅",
      "status": "confirmed",
      "driver_name": "佐藤ドライバー",
      "created_at": "2024-01-10T14:30:00Z"
    }
  ]
}
```

---

## 4. ドライバープール管理

### POST /driver-pool/search
近隣ドライバーの検索

**リクエスト**
```json
{
  "latitude": 35.6762,
  "longitude": 139.6503,
  "radius": 5.0,
  "vehicle_type": "standard"
}
```

**レスポンス**
```json
{
  "success": true,
  "drivers": [
    {
      "id": "driver_001",
      "name": "佐藤ドライバー",
      "latitude": 35.6785,
      "longitude": 139.6532,
      "distance": 0.8,
      "status": "available",
      "vehicle_model": "トヨタ プリウス",
      "rating": 4.8
    }
  ]
}
```

### POST /driver-pool/match
最適ドライバーマッチング

**リクエスト**
```json
{
  "dispatch_request": {
    "pickup_latitude": 35.6762,
    "pickup_longitude": 139.6503,
    "vehicle_type": "standard"
  },
  "available_drivers": [
    {
      "id": "driver_001",
      "latitude": 35.6785,
      "longitude": 139.6532,
      "status": "available"
    }
  ]
}
```

**レスポンス**
```json
{
  "success": true,
  "matched_driver": {
    "id": "driver_001",
    "name": "佐藤ドライバー",
    "matching_score": 95,
    "distance": 0.8,
    "estimated_arrival": 8
  }
}
```

### POST /driver-pool/:driverId/location
ドライバー位置情報の更新

**リクエスト**
```json
{
  "latitude": 35.6762,
  "longitude": 139.6503,
  "heading": 45.0,
  "speed": 30.5,
  "accuracy": 5.0
}
```

**レスポンス**
```json
{
  "success": true,
  "message": "位置情報を更新しました"
}
```

### POST /driver-pool/:driverId/status
ドライバーステータスの更新

**リクエスト**
```json
{
  "status": "available"
}
```

**レスポンス**
```json
{
  "success": true,
  "message": "ステータスを更新しました"
}
```

---

## 5. ダッシュボード・分析

### GET /api/dashboard/stats
ダッシュボード統計データの取得

**レスポンス**
```json
{
  "success": true,
  "data": {
    "companies": 45,
    "drivers": 123,
    "todayDispatches": 89,
    "activeDrivers": 67,
    "costReduction": 75.0,
    "driverSufficiency": 95.0,
    "profitIncrease": 12.0,
    "systemUptime": 99.9
  }
}
```

### GET /api/dashboard/recent-registrations
最近の登録データの取得

**レスポンス**
```json
{
  "success": true,
  "data": {
    "companies": [
      {
        "id": "company_001",
        "company_name": "デモタクシー株式会社",
        "status": "active",
        "created_at": "2024-01-10T14:30:00Z"
      }
    ],
    "drivers": [
      {
        "id": "driver_001",
        "name": "ドライバー太郎",
        "status": "active",
        "created_at": "2024-01-10T14:30:00Z"
      }
    ]
  }
}
```

---

## エラーレスポンス

すべてのAPIエンドポイントは、エラー時に以下の形式でレスポンスを返します：

**4xx クライアントエラー**
```json
{
  "success": false,
  "error": "Validation Error",
  "message": "Company name and email are required"
}
```

**5xx サーバーエラー**
```json
{
  "success": false,
  "error": "Internal Server Error",
  "message": "Database connection failed",
  "timestamp": "2024-01-10T14:30:00Z"
}
```

**404 Not Found**
```json
{
  "success": false,
  "error": "Not Found",
  "message": "The requested endpoint was not found",
  "path": "/invalid-endpoint"
}
```

---

## ステータスコード

- `200` OK - 成功
- `201` Created - 作成成功
- `400` Bad Request - リクエストエラー
- `401` Unauthorized - 認証エラー
- `403` Forbidden - 権限エラー
- `404` Not Found - リソースが見つからない
- `500` Internal Server Error - サーバーエラー

---

## レート制限

- 一般API: 1000リクエスト/時間
- 音声配車API: 500リクエスト/時間
- 位置情報更新: 3600リクエスト/時間（1秒1回）

---

## WebSocket接続（リアルタイム機能）

### /ws/driver/:driverId
ドライバー用リアルタイム通信

**メッセージ例**
```json
{
  "type": "dispatch_request",
  "data": {
    "dispatch_id": "dispatch_001",
    "customer_name": "田中太郎",
    "pickup_location": "新宿駅"
  }
}
```

### /ws/dispatch/:dispatchId
配車追跡用リアルタイム通信

**メッセージ例**
```json
{
  "type": "driver_location_update",
  "data": {
    "latitude": 35.6762,
    "longitude": 139.6503,
    "estimated_arrival": 8
  }
}
```