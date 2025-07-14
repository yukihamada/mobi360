# 🧪 AI音声配車システム テスト手順

## ✅ セットアップ完了状況

### Twilioコンソール設定済み
- **電話番号**: +1 959-210-5018
- **Webhook URL**: https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming
- **本番環境**: 稼働中

---

## 📞 テスト方法

### 1. 電話をかけてAI応答を確認

**手順**:
1. **+1 959-210-5018** に電話をかける
2. AI音声応答を聞く：
   - 「お電話ありがとうございます。デモタクシー株式会社のAI配車システムです。現在3台の車両が利用可能です。」
3. 「配車をご希望の場合は、お迎え場所を教えてください」と聞かれる
4. 音声でお迎え場所を伝える（例：「東京駅でお願いします」）
5. AIが場所を確認して配車を手配

### 2. 配車リクエストAPIテスト

**Verified Caller IDsに登録した番号でテスト**:
```bash
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice-dispatch/create \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+819012345678",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅",
    "vehicleType": "standard"
  }'
```

⚠️ 注意: `customerPhone`はTwilioのVerified Caller IDsに登録済みの番号を使用してください。

---

## 🔍 確認ポイント

### 着信時の動作
1. ✅ AI音声が日本語で応答
2. ✅ 音声認識でお迎え場所を理解
3. ✅ 配車確認のメッセージ

### API動作
1. ✅ 配車リクエストの作成
2. ✅ Twilioからの自動発信
3. ✅ TwiML音声応答の生成

---

## ⚠️ トラブルシューティング

### 電話が繋がらない場合
1. **Twilioコンソール**でWebhook URLを確認
2. **Verified Caller IDs**に発信先番号が登録されているか確認
3. **Twilio残高**が$0.50以上あるか確認

### エラーログの確認
```bash
# Cloudflare Workersのログを確認
wrangler tail --env production

# Twilioコンソールでエラーログを確認
# Console → Monitor → Logs → Errors
```

---

## 📊 テスト結果確認

### 通話ログ
Twilioコンソール → Monitor → Logs → Calls

### API応答確認
```bash
# ヘルスチェック
curl https://mobility-ops-360-api.yukihamada.workers.dev/health
```

---

## 🎯 期待される動作

1. **着信時**: AIが自動応答して配車を受付
2. **音声認識**: 日本語の住所や場所名を理解
3. **配車確認**: ドライバー情報と到着時刻を案内
4. **API連携**: 配車リクエストがデータベースに記録

---

## 💡 デモシナリオ

### シナリオ1: 一般的な配車
1. 電話: 「東京駅から羽田空港までお願いします」
2. AI: 「東京駅から羽田空港ですね。ドライバーを手配します」
3. AI: 「約10分ほどでお迎えに上がります」

### シナリオ2: 音声認識テスト
1. 電話: 「渋谷のハチ公前でお願いします」
2. AI: 「お迎え場所は渋谷のハチ公前ですね」
3. AI: 「ドライバーを手配します」

---

## 🚀 次のステップ

1. **本番電話番号の購入**
   - 日本の03番号など
   - Twilioで月額約$8

2. **Groq LLM統合**
   - より高度な自然言語理解
   - 住所の正規化

3. **リアルタイム配車**
   - GPSベースのドライバーマッチング
   - 動的料金計算

---

## 📝 フィードバック

テスト結果や改善要望：
- GitHub Issues: https://github.com/mobility360/api/issues
- Email: support@mobility360.jp