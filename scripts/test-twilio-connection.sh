#!/bin/bash

# Twilio接続テストスクリプト

echo "🔍 Twilio接続テスト"
echo "===================="
echo ""

# 1. API動作確認
echo "1️⃣ API動作確認..."
API_STATUS=$(curl -s https://mobility-ops-360-api.yukihamada.workers.dev/health | jq -r '.status' 2>/dev/null)
if [ "$API_STATUS" = "healthy" ]; then
    echo "✅ API正常稼働中"
else
    echo "❌ APIに接続できません"
    exit 1
fi
echo ""

# 2. Webhook応答確認
echo "2️⃣ Webhook応答確認..."
echo "リクエスト送信中..."
TWIML_RESPONSE=$(curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "From=%2B81901234567&To=%2B19592105018&CallSid=CAtest$(date +%s)" \
  -s)

if echo "$TWIML_RESPONSE" | grep -q "<Response>"; then
    echo "✅ TwiMLレスポンス正常"
    echo ""
    echo "応答内容:"
    echo "$TWIML_RESPONSE" | xmllint --format - 2>/dev/null | head -20
else
    echo "❌ TwiMLレスポンスエラー"
    echo "$TWIML_RESPONSE"
fi
echo ""

# 3. Twilioアカウント確認
echo "3️⃣ Twilioアカウント確認..."
# Note: Replace with your actual Twilio credentials
ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
AUTH_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
ACCOUNT_CHECK=$(curl -s -u "$ACCOUNT_SID:$AUTH_TOKEN" \
  "https://api.twilio.com/2010-04-01/Accounts/$ACCOUNT_SID.json")

if echo "$ACCOUNT_CHECK" | jq -r '.status' 2>/dev/null | grep -q "active"; then
    echo "✅ Twilioアカウントアクティブ"
    BALANCE=$(echo "$ACCOUNT_CHECK" | jq -r '.balance' 2>/dev/null)
    echo "   残高: $BALANCE"
else
    echo "❌ Twilioアカウントエラー"
fi
echo ""

# 4. 電話番号確認
echo "4️⃣ 電話番号確認..."
PHONE_CHECK=$(curl -s -u "$ACCOUNT_SID:$AUTH_TOKEN" \
  "https://api.twilio.com/2010-04-01/Accounts/$ACCOUNT_SID/IncomingPhoneNumbers.json")

if echo "$PHONE_CHECK" | jq -r '.incoming_phone_numbers[].phone_number' 2>/dev/null | grep -q "+19592105018"; then
    echo "✅ 電話番号 +1 (959) 210-5018 確認"
    
    # Voice URLの確認
    VOICE_URL=$(echo "$PHONE_CHECK" | jq -r '.incoming_phone_numbers[] | select(.phone_number=="+19592105018") | .voice_url' 2>/dev/null)
    if [ -z "$VOICE_URL" ] || [ "$VOICE_URL" = "null" ]; then
        echo "❌ Voice Webhook URLが設定されていません！"
        echo ""
        echo "📝 Twilioコンソールで設定してください:"
        echo "   URL: https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming"
    else
        echo "   現在のWebhook URL: $VOICE_URL"
        if [ "$VOICE_URL" != "https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming" ]; then
            echo "⚠️  Webhook URLが正しくありません"
            echo "   正しいURL: https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming"
        else
            echo "✅ Webhook URL正しく設定されています"
        fi
    fi
else
    echo "❌ 電話番号が見つかりません"
fi

echo ""
echo "📞 テスト通話を発信するには:"
echo "node scripts/make-test-call.js +81901234567"
echo "（あなたの電話番号を国番号付きで指定）"