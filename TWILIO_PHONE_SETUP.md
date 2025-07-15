# 📞 Twilio電話番号 +1 (959) 210-5018 設定ガイド

## 🚨 現在の問題
電話が繋がらない原因は、**Twilioの認証情報がCloudflare Workersに設定されていない**ためです。

## ✅ 解決手順

### 1. Twilioシークレットの設定（必須）

簡単設定スクリプトを用意しました：

```bash
# スクリプトを実行
./scripts/setup-twilio-secrets.sh
```

または手動で設定：

```bash
cd backend

# Twilioコンソールから取得した情報を設定
wrangler secret put TWILIO_ACCOUNT_SID --env production
# 入力: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

wrangler secret put TWILIO_AUTH_TOKEN --env production
# 入力: 32文字のトークン

wrangler secret put TWILIO_PHONE_NUMBER --env production
# 入力: +19592105018

wrangler secret put JWT_SECRET --env production
# 入力: ランダムな文字列（または自動生成）
```

### 2. APIの再デプロイ

```bash
cd backend
npm run deploy
```

### 3. Twilioコンソールでの設定

1. [Twilioコンソール](https://console.twilio.com)にログイン
2. **Phone Numbers** → **Manage** → **Active Numbers**
3. **+1 959-210-5018** をクリック
4. **Voice & Fax** セクションで設定：

| 設定項目 | 値 |
|---------|-----|
| A CALL COMES IN | Webhook |
| URL | `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming` |
| HTTP Method | POST |
| STATUS CALLBACK URL | `https://mobility-ops-360-api.yukihamada.workers.dev/api/twilio/status` |

### 4. 動作確認

```bash
# APIヘルスチェック
curl https://mobility-ops-360-api.yukihamada.workers.dev/api/v1/health

# 設定されたシークレットの確認
cd backend
wrangler secret list --env production
```

## 🧪 テスト手順

1. **+1 (959) 210-5018** に電話
2. AI音声が応答：「こんにちは、Mobility 360 AI配車システムです」
3. 配車情報を伝える
4. AIが確認して配車を手配

## ❓ トラブルシューティング

### "通話できません"と表示される場合

1. **シークレットが設定されているか確認**
   ```bash
   wrangler secret list --env production
   ```

2. **APIが正常に動作しているか確認**
   ```bash
   curl -I https://mobility-ops-360-api.yukihamada.workers.dev/api/v1/health
   ```

3. **Twilioのログを確認**
   - Twilioコンソール → Monitor → Logs → Calls

### よくあるエラー

| エラー | 原因 | 解決方法 |
|--------|------|----------|
| Authentication Error | シークレット未設定 | setup-twilio-secrets.sh を実行 |
| 404 Not Found | Webhook URL間違い | URLを確認して修正 |
| 500 Internal Error | APIのエラー | ログを確認 |

## 📱 国際電話料金について

- 日本から +1 (959) 210-5018 への通話は国際電話料金がかかります
- 目安：1分あたり30円〜100円（キャリアによる）
- 日本の050番号への移行も検討中

## 🔗 関連リンク

- [Twilioコンソール](https://console.twilio.com)
- [APIドキュメント](https://mobility-ops-360-api.yukihamada.workers.dev/docs)
- [システムステータス](https://mobility-ops-360-api.yukihamada.workers.dev/api/v1/health)