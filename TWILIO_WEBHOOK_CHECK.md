# 🔍 Twilio Webhook設定チェックリスト

## 現在の状況
- ✅ 電話番号: **+1 (959) 210-5018**
- ✅ Twilioシークレット設定済み
- ✅ API稼働中: https://mobility-ops-360-api.yukihamada.workers.dev

## 📱 Twilioコンソールで確認すること

### 1. 電話番号の設定画面
[Twilioコンソール](https://console.twilio.com/us1/develop/phone-numbers/manage/incoming) → **+1 (959) 210-5018**

### 2. Voice Configurationの確認

以下の設定になっているか確認してください：

| 設定項目 | 正しい値 | 
|---------|----------|
| **A call comes in** | Webhook |
| **URL** | `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming` |
| **HTTP Method** | POST |
| **Primary Handler fails** | （任意） |
| **Status Callback URL** | `https://mobility-ops-360-api.yukihamada.workers.dev/api/twilio/status` |
| **Status Callback Method** | POST |

### 3. よくある設定ミス

❌ **間違い例**:
- URL末尾のスラッシュ: `/api/voice/incoming/` 
- HTTPSではなくHTTP: `http://...`
- 古いURL: 別のプロジェクトのURL

✅ **正しいURL**:
```
https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming
```

## 🧪 設定後のテスト

1. **Saveボタンを押す**（重要！）
2. **+1 (959) 210-5018** に電話
3. 「お電話ありがとうございます...」と聞こえれば成功

## 📊 動作しない場合の確認

### Twilioコンソールで:
1. **Monitor** → **Logs** → **Calls**
2. 最新の通話記録を確認
3. エラーメッセージをチェック

### よくあるエラー:
- **11200**: Webhook URLへの接続失敗
- **11750**: TwiMLレスポンスエラー
- **21401**: 電話番号エラー

## 🎯 スクリーンショットで確認

Twilioコンソールの設定画面のスクリーンショットを撮って、以下を確認：
1. Voice Configurationセクション
2. Webhook URLが正しく入力されている
3. HTTP MethodがPOSTになっている
4. Saveボタンを押した後の画面

これらが正しく設定されていれば、電話は必ず繋がります。