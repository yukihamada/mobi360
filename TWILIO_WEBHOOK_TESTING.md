# Twilio Webhook Testing Guide

## Fixed Issues

### 1. TwiML Response URLs ✅
- **Issue**: TwiML responses used relative paths like `action="/api/voice/process-speech"`
- **Fix**: Updated to use absolute URLs: `action="https://api.mobility360.jp/api/voice/process-speech"`

### 2. Database Binding Mismatch ✅
- **Issue**: Code referenced `c.env.D1_MOBI360_DB` but wrangler.toml used `DB` binding
- **Fix**: Updated all database references to use `c.env.DB`

### 3. Webhook URL Configuration ✅
- **Issue**: Webhook URLs in ai-voice-dispatch.js and voice-handler.js used hardcoded URLs
- **Fix**: Updated to use `${baseUrl}` with environment fallback

### 4. Environment Variables ✅
- **Issue**: Missing proper fallback URLs
- **Fix**: Added fallback to `https://mobility-ops-360-api.yukihamada.workers.dev`

## Current Working Endpoints

### Production API Base URL
```
https://mobility-ops-360-api.yukihamada.workers.dev
```

### Working Webhook Endpoints

#### 1. Incoming Call Webhook
**URL**: `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming`
**Method**: POST
**Content-Type**: application/x-www-form-urlencoded

**Test Command**:
```bash
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "From=+1234567890&To=+19592105018&CallSid=test123"
```

**Expected Response**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="ja-JP">お電話ありがとうございます。デモタクシー株式会社のAI配車システムです。現在3台の車両が利用可能です。</Say>
  <Gather input="speech" language="ja-JP" timeout="10" action="https://api.mobility360.jp/api/voice/process-speech">
    <Say language="ja-JP">配車をご希望の場合は、お迎え場所を教えてください。</Say>
  </Gather>
  <Say language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
</Response>
```

#### 2. Voice Dispatch Creation
**URL**: `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice-dispatch/create`
**Method**: POST
**Content-Type**: application/json

**Test Command**:
```bash
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice-dispatch/create \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "テスト太郎",
    "customerPhone": "+19592105018",
    "pickupLocation": "東京駅",
    "destination": "渋谷駅",
    "vehicleType": "standard"
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "message": "AI音声配車リクエストを作成しました",
  "data": {
    "dispatchId": "dispatch_1752504850333_74ewozc2c",
    "assignedDriver": {
      "name": "ドライバー太郎",
      "vehicleModel": null,
      "vehiclePlate": null
    },
    "estimatedArrival": 10,
    "twimlUrl": "https://api.mobility360.jp/api/voice-dispatch/twiml/dispatch_1752504850333_74ewozc2c"
  }
}
```

#### 3. TwiML Response Generation
**URL**: `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice-dispatch/twiml/{dispatchId}`
**Method**: POST

**Test Command**:
```bash
curl -X POST https://mobility-ops-360-api.yukihamada.workers.dev/api/voice-dispatch/twiml/dispatch_1752504850333_74ewozc2c
```

**Expected Response**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">
        こんにちは。Mobility Ops 360のAI音声配車システムです。
        配車を承りました。ドライバーが約10分後にお迎えに上がります。
        ご利用ありがとうございます。
    </Say>
</Response>
```

#### 4. Status Callback
**URL**: `https://mobility-ops-360-api.yukihamada.workers.dev/api/twilio/status`
**Method**: POST

## Twilio Console Configuration

### Required Phone Number Settings
In the Twilio Console → Phone Numbers → Manage → +1 959-210-5018:

#### Voice Configuration:
- **A CALL COMES IN**: Webhook
- **URL**: `https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming`
- **HTTP Method**: POST

#### Status Callbacks:
- **CALL STATUS CHANGES**: Webhook
- **URL**: `https://mobility-ops-360-api.yukihamada.workers.dev/api/twilio/status`
- **HTTP Method**: POST

### Environment Variables Required
These should be set in Cloudflare Workers secrets:
- `TWILIO_ACCOUNT_SID`: Your Twilio Account SID
- `TWILIO_AUTH_TOKEN`: Your Twilio Auth Token
- `TWILIO_PHONE_NUMBER`: +19592105018
- `API_BASE_URL`: https://api.mobility360.jp

### Test Incoming Calls
1. Set up Twilio phone number webhooks as described above
2. Call +1 959-210-5018 from a verified phone number
3. You should hear: "お電話ありがとうございます。デモタクシー株式会社のAI配車システムです..."

## Debugging
If calls aren't working:
1. Check Twilio Console → Monitor → Call Logs
2. Look for webhook errors in the call logs
3. Check Cloudflare Workers logs: `wrangler tail --env production`
4. Verify webhook URLs are absolute (not relative)

## Next Steps
1. Add proper Twilio credentials to Cloudflare Workers secrets
2. Update Twilio phone number webhook configuration
3. Test end-to-end phone call functionality
4. Add proper error handling and logging