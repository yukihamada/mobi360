# 🚀 Mobility Ops 360 アプリケーション一覧

## 📱 公開されているWebアプリ

### 1. API ドキュメント（Swagger UI）
- **URL**: https://mobility-ops-360-api.yukihamada.workers.dev/docs
- **説明**: 全64エンドポイントのインタラクティブなAPIドキュメント
- **機能**: APIのテスト実行が可能

### 2. SDK ドキュメント
- **URL**: https://mobility-ops-360-api.yukihamada.workers.dev/sdk/docs/
- **説明**: TypeScript SDKの使用方法とサンプルコード

### 3. ヘルスチェック
- **URL**: https://mobility-ops-360-api.yukihamada.workers.dev/health
- **説明**: システムの稼働状況を確認

## 🛠 ローカル開発アプリ

### 1. Flutter Webアプリ
```bash
cd frontend/mobi360_app
flutter run -d chrome
```
- ドライバー向けアプリ
- 管理者ダッシュボード
- リアルタイム配車状況

### 2. TypeScript SDK テスト
```bash
cd sdk
npm run dev
```

## 🔌 API エンドポイント例

### 認証
```bash
# 会社登録
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/v1/auth/register/company \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "テストタクシー",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### AI音声配車
```bash
# 配車リクエスト作成
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/v1/ai-voice-dispatch/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "customerName": "山田太郎",
    "customerPhone": "+81901234567",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅"
  }'
```

## 📞 電話テスト
- **番号**: +1 (959) 210-5018
- **説明**: AI音声配車システムのデモ