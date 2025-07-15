#!/bin/bash

# Twilio Secrets Setup Script for Mobility Ops 360
# This script helps configure Twilio secrets for Cloudflare Workers

echo "🚀 Mobility Ops 360 - Twilioシークレット設定スクリプト"
echo "=================================================="
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLIがインストールされていません"
    echo "npm install -g wrangler でインストールしてください"
    exit 1
fi

# Move to backend directory
cd "$(dirname "$0")/../backend" || exit 1

echo "📝 Twilioの認証情報を入力してください"
echo "（Twilioコンソールから取得: https://console.twilio.com）"
echo ""

# Get Twilio Account SID
read -p "1️⃣ TWILIO_ACCOUNT_SID (ACで始まる文字列): " TWILIO_ACCOUNT_SID
if [[ ! $TWILIO_ACCOUNT_SID =~ ^AC[a-z0-9]{32}$ ]]; then
    echo "❌ 無効なAccount SID形式です"
    exit 1
fi

# Get Twilio Auth Token
read -s -p "2️⃣ TWILIO_AUTH_TOKEN (表示されません): " TWILIO_AUTH_TOKEN
echo ""
if [[ ${#TWILIO_AUTH_TOKEN} -ne 32 ]]; then
    echo "❌ 無効なAuth Token形式です（32文字である必要があります）"
    exit 1
fi

# Get Twilio Phone Number
read -p "3️⃣ TWILIO_PHONE_NUMBER (+19592105018): " TWILIO_PHONE_NUMBER
TWILIO_PHONE_NUMBER=${TWILIO_PHONE_NUMBER:-+19592105018}

# Generate JWT Secret if not provided
read -p "4️⃣ JWT_SECRET (Enterで自動生成): " JWT_SECRET
if [ -z "$JWT_SECRET" ]; then
    JWT_SECRET=$(openssl rand -base64 32)
    echo "✅ JWT_SECRETを自動生成しました"
fi

echo ""
echo "📤 Cloudflare Workersにシークレットを設定中..."
echo ""

# Set secrets for production environment
echo "🔐 本番環境 (production) に設定中..."
echo "$TWILIO_ACCOUNT_SID" | wrangler secret put TWILIO_ACCOUNT_SID --env production
echo "$TWILIO_AUTH_TOKEN" | wrangler secret put TWILIO_AUTH_TOKEN --env production
echo "$TWILIO_PHONE_NUMBER" | wrangler secret put TWILIO_PHONE_NUMBER --env production
echo "$JWT_SECRET" | wrangler secret put JWT_SECRET --env production

echo ""
echo "✅ シークレットの設定が完了しました！"
echo ""
echo "📞 次のステップ:"
echo "1. APIをデプロイ: npm run deploy"
echo "2. Twilioコンソールでwebhook URLを設定:"
echo "   https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming"
echo ""
echo "🔍 設定の確認: wrangler secret list --env production"