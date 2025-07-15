# 🔍 Twilio電話接続デバッグガイド

## 現在の状況

### ✅ 正常に動作している部分:
1. **API稼働中**: https://mobility-ops-360-api.yukihamada.workers.dev
2. **Twilioシークレット設定済み**: ACCOUNT_SID, AUTH_TOKEN, PHONE_NUMBER
3. **Webhookエンドポイント正常**: 
   - `/api/voice/incoming` - TwiMLレスポンス正常
   - `/api/voice/process-speech` - 音声認識処理正常
   - `/api/twilio/status` - ステータスコールバック正常

### ❌ 問題の可能性:
1. **Twilioコンソールでのwebhook URL未設定**
2. **電話番号の設定ミス**
3. **Twilioアカウントの制限**

## 🧪 デバッグ手順

### 1. Twilioコンソールでの確認

1. [Twilioコンソール](https://console.twilio.com/us1/develop/phone-numbers/manage/incoming)にアクセス
2. **+1 959-210-5018** が表示されているか確認
3. 番号をクリックして設定画面へ

### 2. Voice Configuration設定

**必須設定項目:**

| 項目 | 設定値 |
|------|--------|
| **A call comes in** | Webhook |
| **URL** | `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming` |
| **HTTP Method** | POST |
| **Status Callback URL** | `https://mobility-ops-360-api.yukihamada.workers.dev/api/twilio/status` |
| **Status Callback Method** | POST |

### 3. ログの確認方法

#### Cloudflare Workersのログ:
```bash
# リアルタイムログ表示
npx wrangler tail --env production

# 別ターミナルで電話をかけてログを確認
```

#### Twilioのログ:
1. [Twilioコンソール](https://console.twilio.com) → **Monitor** → **Logs** → **Calls**
2. 最新の通話記録を確認
3. エラーメッセージをチェック

### 4. よくあるエラーと解決方法

| エラー | 原因 | 解決方法 |
|--------|------|----------|
| **21401 - Invalid Phone Number** | 電話番号の形式エラー | 国番号付きで設定 (+1...) |
| **21210 - Phone number not verified** | 番号の確認未完了 | Twilioで番号確認を完了 |
| **11200 - HTTP retrieval failure** | Webhook URLエラー | URLが正しいか確認 |
| **11750 - TwiML response body too large** | レスポンスサイズ超過 | TwiMLを簡略化 |
| **20003 - Permission denied** | 権限エラー | アカウント設定を確認 |

### 5. テストコマンド

```bash
# Webhookエンドポイントのテスト
./scripts/test-twilio-webhook.sh

# 手動でwebhookをテスト
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "From=%2B81901234567&To=%2B19592105018&CallSid=CAtest123"
```

### 6. Twilioアカウントのチェックリスト

- [ ] アカウントがアクティブか
- [ ] 残高があるか（トライアルの場合は$15以上）
- [ ] 電話番号が有効か
- [ ] Geographic Permissionsで日本への発信が許可されているか
- [ ] Voice機能が有効か

### 7. 高度なデバッグ

#### Twilioのデバッガー使用:
1. Twilioコンソール → **Monitor** → **Debugger**
2. エラーアラートを確認
3. Webhook Validatorでテスト

#### ngrokを使ったローカルテスト:
```bash
# ローカルでAPIを起動
npm run dev

# ngrokでトンネル作成
ngrok http 8787

# TwilioのwebhookをngrokのURLに変更してテスト
```

## 📞 動作確認の流れ

1. **設定完了後のテスト**:
   - +1 (959) 210-5018 に電話
   - 「お電話ありがとうございます...」と聞こえれば成功

2. **音声入力テスト**:
   - 「東京駅から渋谷駅まで」と話す
   - AIが復唱して配車手配の案内が流れれば成功

## 🆘 それでも繋がらない場合

1. **Twilioサポートに連絡**:
   - support@twilio.com
   - アカウントIDと電話番号を伝える

2. **一時的な代替案**:
   - 新しい電話番号を購入してテスト
   - 別のTwilioアカウントでテスト

## 📊 監視とメトリクス

```bash
# APIの状態確認
watch -n 5 'curl -s https://mobility-ops-360-api.yukihamada.workers.dev/health | jq .'

# Twilioの通話統計
# Twilioコンソール → Monitor → Insights → Voice Insights
```