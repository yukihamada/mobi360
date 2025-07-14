# 🚀 AI音声配車システム デプロイガイド

## 📋 前提条件

✅ Twilio認証情報を`claude.env`に設定済み：
```bash
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=+19592105018
```

## 🔧 ステップ1: 環境変数の設定

```bash
cd backend

# Cloudflare Workersに環境変数を設定
wrangler secret put TWILIO_ACCOUNT_SID
# プロンプトで入力: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

wrangler secret put TWILIO_AUTH_TOKEN
# プロンプトで入力: your-twilio-auth-token

wrangler secret put TWILIO_PHONE_NUMBER
# プロンプトで入力: +19592105018
```

## 🚀 ステップ2: デプロイ

```bash
# 開発環境にデプロイ（テスト用）
npm run deploy

# 本番環境にデプロイ
npm run deploy:production
```

デプロイ後、以下のようなURLが表示されます：
```
✅ Deployed to https://mobi360-api.YOUR-SUBDOMAIN.workers.dev
```

## 📱 ステップ3: API_BASE_URLの設定

デプロイ後のURLをAPI_BASE_URLとして設定：

```bash
wrangler secret put API_BASE_URL
# プロンプトで入力: https://mobi360-api.YOUR-SUBDOMAIN.workers.dev
```

## 🔔 ステップ4: Twilioのコールバック設定

1. [Twilioコンソール](https://console.twilio.com/us1/develop/phone-numbers/manage/incoming)にログイン
2. 購入した番号（+1 959-210-5018）をクリック
3. **Voice Configuration**セクションで設定：

```
A CALL COMES IN:
  Webhook: https://mobi360-api.YOUR-SUBDOMAIN.workers.dev/api/v1/ai-voice-dispatch/twiml/test123
  HTTP Method: POST

CALL STATUS CHANGES:
  Webhook: https://mobi360-api.YOUR-SUBDOMAIN.workers.dev/api/v1/ai-voice-dispatch/status/test123
  HTTP Method: POST
```

4. 「Save configuration」をクリック

## 🧪 ステップ5: 動作テスト

### 1. APIヘルスチェック
```bash
curl https://mobi360-api.YOUR-SUBDOMAIN.workers.dev/health
```

### 2. 配車リクエスト作成
```bash
curl -X POST https://mobi360-api.YOUR-SUBDOMAIN.workers.dev/api/v1/ai-voice-dispatch/create \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+81xxxxxxxxxx",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅",
    "vehicleType": "standard"
  }'
```

⚠️ **注意**: `customerPhone`は、Twilioの**Verified Caller IDs**に登録した番号を使用してください。

### 3. 着信テスト
Twilioコンソールで電話番号に直接電話をかけて、音声応答が聞こえるか確認。

## 🐛 トラブルシューティング

### エラー: "Twilio credentials not configured"
```bash
# 環境変数が正しく設定されているか確認
wrangler secret list
```

### エラー: "Invalid phone number"
- 電話番号の形式を確認（+を含む国際形式）
- Verified Caller IDsに登録されているか確認

### ログの確認
```bash
# リアルタイムログを確認
npm run logs
```

## 📊 デプロイ状況の確認

```bash
# Workers一覧
wrangler deployments list

# 現在のデプロイメント詳細
wrangler deployment view
```

## 🔄 更新時の手順

1. コードを変更
2. `npm run deploy`で再デプロイ
3. Twilioのコールバックは自動的に新しいバージョンを使用

## 🎉 完了！

これで、AI音声配車システムが稼働しています。
+1 959-210-5018 に電話をかけると、AIが応答します。

### 次のステップ：
- [ ] 実際の顧客電話番号をVerified Caller IDsに追加
- [ ] データベースにドライバー情報を登録
- [ ] 本番環境用のドメイン設定
- [ ] 通話ログの分析ダッシュボード構築