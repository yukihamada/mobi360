# 🎉 APIドキュメント公開完了！

## 📚 オンラインAPIドキュメント

### Swagger UI（インタラクティブ）
🔗 **https://mobility-ops-360-api.yukihamada.workers.dev/docs**

- ✅ ブラウザから直接APIをテスト可能
- ✅ リクエスト/レスポンスの詳細確認
- ✅ 認証トークンを設定してライブテスト
- ✅ 日本語対応の美しいUI

### OpenAPI仕様書
🔗 **https://mobility-ops-360-api.yukihamada.workers.dev/api/openapi.yaml**

- OpenAPI 3.0.3形式
- Postman/Insomniaにインポート可能
- コード生成ツール対応

---

## 🚀 主な機能

### 1. インタラクティブテスト
ドキュメントページから直接APIを実行：
1. `/docs`にアクセス
2. エンドポイントを選択
3. 「Try it out」をクリック
4. パラメータを入力
5. 「Execute」で実行

### 2. 認証設定
Bearer Token認証の設定方法：
1. 右上の「Authorize」ボタンをクリック
2. トークンを入力（Bearer プレフィックスは自動）
3. 「Authorize」をクリック

### 3. クイックリンク
- 🏥 **ヘルスチェック** - システム稼働確認
- 🔐 **認証** - ログイン・トークン取得
- 🎙️ **AI音声配車** - 自動音声での配車受付
- ⚡ **リアルタイム配車** - 最速マッチング

---

## 📱 テストアカウント

```json
{
  "email": "demo@example.com",
  "password": "pass1234",
  "userType": "company"
}
```

---

## 🧪 APIテスト例

### 1. ログイン
```bash
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "pass1234",
    "userType": "company"
  }'
```

### 2. AI配車リクエスト
```bash
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice-dispatch/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+819012345678",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅"
  }'
```

---

## 🔗 関連リンク

- **APIドキュメント（Web）**: https://mobility-ops-360-api.yukihamada.workers.dev/docs
- **OpenAPI仕様書**: https://mobility-ops-360-api.yukihamada.workers.dev/api/openapi.yaml
- **ヘルスチェック**: https://mobility-ops-360-api.yukihamada.workers.dev/health
- **GitHub**: https://github.com/mobility360/api

---

## 💡 活用方法

### 開発者向け
1. OpenAPI仕様書をダウンロード
2. お使いのAPIクライアントにインポート
3. コード生成ツールでSDK作成

### ビジネス向け
1. `/docs`で機能を確認
2. デモアカウントでテスト
3. 実装計画の策定

---

## 📞 サポート

- Email: support@mobility360.jp
- Slack: #mobility360-api
- GitHub Issues: https://github.com/mobility360/api/issues