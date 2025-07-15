#!/bin/bash

# Twilio Webhook テストスクリプト
# このスクリプトはTwilioのwebhookをローカルでテストするためのものです

API_URL="https://mobility-ops-360-api.yukihamada.workers.dev"
PHONE_NUMBER="+19592105018"

echo "🧪 Twilio Webhook テストスクリプト"
echo "=================================="
echo ""

# 1. Health check
echo "1️⃣ APIヘルスチェック..."
curl -s "$API_URL/health" | jq . || echo "❌ APIに接続できません"
echo ""

# 2. Test incoming call webhook
echo "2️⃣ 着信Webhookテスト..."
echo "レスポンス:"
curl -X POST "$API_URL/api/voice/incoming" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "From=%2B81901234567&To=$PHONE_NUMBER&CallSid=CAtest$(date +%s)" \
  -s | xmllint --format - 2>/dev/null || echo "❌ XMLパースエラー"
echo ""

# 3. Test speech processing webhook
echo "3️⃣ 音声認識Webhookテスト..."
curl -X POST "$API_URL/api/voice/process-speech" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "SpeechResult=東京駅から渋谷駅まで&Confidence=0.95&CallSid=CAtest$(date +%s)" \
  -s | xmllint --format - 2>/dev/null || echo "❌ XMLパースエラー"
echo ""

# 4. Test status callback
echo "4️⃣ ステータスコールバックテスト..."
curl -X POST "$API_URL/api/twilio/status" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "CallSid=CAtest$(date +%s)&CallStatus=completed&From=%2B81901234567&To=$PHONE_NUMBER" \
  -s -w "\nHTTPステータス: %{http_code}\n"
echo ""

# 5. Create test dispatch and get TwiML
echo "5️⃣ AI音声配車テスト..."
DISPATCH_RESPONSE=$(curl -X POST "$API_URL/api/v1/ai-voice-dispatch/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+81901234567",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅",
    "vehicleType": "standard"
  }' -s)

echo "配車作成レスポンス:"
echo "$DISPATCH_RESPONSE" | jq . 2>/dev/null || echo "$DISPATCH_RESPONSE"

# Extract dispatch ID if available
DISPATCH_ID=$(echo "$DISPATCH_RESPONSE" | jq -r '.data.dispatchId' 2>/dev/null)

if [ ! -z "$DISPATCH_ID" ] && [ "$DISPATCH_ID" != "null" ]; then
  echo ""
  echo "6️⃣ TwiMLレスポンステスト (Dispatch ID: $DISPATCH_ID)..."
  curl -X POST "$API_URL/api/v1/ai-voice-dispatch/twiml/$DISPATCH_ID" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "CallSid=CAtest$(date +%s)" \
    -s | xmllint --format - 2>/dev/null || echo "❌ XMLパースエラー"
fi

echo ""
echo "✅ テスト完了"
echo ""
echo "📝 次のステップ:"
echo "1. Twilioコンソール (https://console.twilio.com) にログイン"
echo "2. Phone Numbers → $PHONE_NUMBER を選択"
echo "3. Voice Configuration で以下を設定:"
echo "   - A call comes in: Webhook"
echo "   - URL: $API_URL/api/voice/incoming"
echo "   - HTTP Method: POST"
echo "4. Save configuration をクリック"