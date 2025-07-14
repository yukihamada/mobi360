# Twilio AI音声配車システム セットアップガイド

## 🚀 クイックスタート

### 1. Twilioアカウントの作成

1. [Twilio Console](https://www.twilio.com/console)にアクセス
2. 無料アカウントを作成（初回$15分のクレジット付与）
3. 電話番号認証を完了

### 2. 認証情報の取得

Twilioコンソールから以下を取得：
- **Account SID**: `AC...` で始まる文字列
- **Auth Token**: 認証トークン（秘密情報）

### 3. 電話番号の購入

1. Twilioコンソール → Phone Numbers → Buy a Number
2. 日本の番号（+81）または米国番号（+1）を選択
3. Voice対応の番号を購入（月額約$1〜）

### 4. 環境変数の設定

`.env`ファイルを作成（`.env.example`を参考）：

```bash
# Twilioの認証情報
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+19592105018  # AI音声配車デモ番号（米国）

# API設定
API_BASE_URL=https://your-project.workers.dev
```

### 5. Cloudflare Workersの環境変数設定

```bash
# Wrangler CLIで環境変数を設定
wrangler secret put TWILIO_ACCOUNT_SID
wrangler secret put TWILIO_AUTH_TOKEN
wrangler secret put TWILIO_PHONE_NUMBER
wrangler secret put API_BASE_URL
```

### 6. デプロイ

```bash
# 依存関係のインストール
cd backend
npm install

# Cloudflare Workersにデプロイ
npm run deploy
```

### 7. Twilioのコールバック設定

1. Twilioコンソール → Phone Numbers → 購入した番号を選択
2. Voice & Fax セクションで設定：
   - **A CALL COMES IN**: Webhook
   - **URL**: `https://your-project.workers.dev/api/v1/ai-voice-dispatch/twiml/{dispatchId}`
   - **HTTP Method**: POST

### 8. 動作確認

```bash
# テスト用の配車リクエストを作成
curl -X POST https://your-project.workers.dev/api/v1/ai-voice-dispatch/create \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+81xxxxxxxxxx",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅",
    "vehicleType": "standard"
  }'
```

## 📞 システムの動作フロー

1. **配車リクエスト作成** → APIが配車IDを生成
2. **Twilio API呼び出し** → 顧客に自動電話
3. **AI音声応答** → 「お迎え場所は東京駅、目的地は渋谷駅でよろしいですか？」
4. **音声認識** → 顧客の「はい/いいえ」を理解
5. **配車確定** → ドライバーに通知（実装予定）

## 🔧 トラブルシューティング

### エラー: "Twilio credentials not configured"
→ 環境変数が正しく設定されているか確認

### エラー: "Invalid phone number"
→ 電話番号の形式を確認（国番号を含む形式: +81xx-xxxx-xxxx）

### 通話が繋がらない
→ Twilioの残高確認、電話番号の有効性確認

## 📝 注意事項

- **本番環境では必ず環境変数を使用**（ハードコーディング禁止）
- **Auth Tokenは絶対に公開しない**
- **通話料金が発生**するため、テスト時は注意
- **日本の電話番号**を使用する場合は、Twilioでの本人確認が必要

## 🚨 セキュリティ

- Webhook URLには認証を実装することを推奨
- Rate Limitingの実装を検討
- ログには個人情報を含めない

## 💰 料金目安

- 電話番号: 月額 $1〜$5
- 発信通話: 約 $0.0075/分（日本）
- 着信通話: 約 $0.0085/分（日本）
- 音声認識: 約 $0.02/分

## 🔗 参考リンク

- [Twilio Docs](https://www.twilio.com/docs)
- [TwiML Reference](https://www.twilio.com/docs/voice/twiml)
- [Twilio Console](https://www.twilio.com/console)