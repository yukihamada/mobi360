# 🚨 Twilio 502エラーの解決

## 問題
Twilioが音声認識結果を送信する際に502エラーが発生:
```
Got HTTP 502 response to https://api.mobility360.jp/api/voice/process-speech
```

## 原因
- Twilioは `https://api.mobility360.jp` にアクセスしようとしている
- 実際のAPIは `https://mobility-ops-360-api.yukihamada.workers.dev` で動作
- `api.mobility360.jp` のドメインが設定されていない

## 解決方法

### オプション1: Twilioコンソールで正しいURLに変更（推奨）

1. [Twilioコンソール](https://console.twilio.com)にログイン
2. Phone Numbers → **+1 (959) 210-5018** を選択
3. Voice Configurationで以下に変更:
   ```
   URL: https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming
   ```

### オプション2: カスタムドメインの設定

1. Cloudflareダッシュボードで`mobility360.jp`ドメインを管理
2. `api.mobility360.jp`のCNAMEレコードを追加:
   ```
   Type: CNAME
   Name: api
   Target: mobility-ops-360-api.yukihamada.workers.dev
   Proxy: ON (オレンジ色の雲)
   ```

3. Cloudflare Workersのカスタムドメイン設定:
   ```bash
   wrangler domains add api.mobility360.jp --env production
   ```

### オプション3: コード内のURLを修正（即時対応）

`backend/src/index.js`の2882行目を修正:
```javascript
// 変更前
action="https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/process-speech"

// 変更後（自己参照URLを使用）
action="/api/voice/process-speech"
```

## 推奨される対応

最も簡単な解決策は**オプション1**です。Twilioコンソールで直接URLを変更してください。

## テスト方法

1. 設定変更後、+1 (959) 210-5018 に電話
2. 「三田から千駄ヶ谷まで」と話す
3. AIが復唱して配車手配することを確認