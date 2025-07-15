#!/bin/bash

# Cloudflare API Token自動生成スクリプト

echo "🔑 Cloudflare API Token 自動生成"
echo "================================"
echo ""

# Cloudflareの認証情報を環境変数から取得または入力
if [ -z "$CLOUDFLARE_EMAIL" ]; then
    read -p "Cloudflareアカウントのメールアドレス: " CLOUDFLARE_EMAIL
fi

if [ -z "$CLOUDFLARE_API_KEY" ]; then
    echo ""
    echo "CloudflareのGlobal API Keyが必要です："
    echo "1. https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Global API Key セクションの「View」をクリック"
    echo ""
    read -s -p "Global API Key: " CLOUDFLARE_API_KEY
    echo ""
fi

# アカウント情報を取得
echo ""
echo "📊 アカウント情報を取得中..."
ACCOUNT_INFO=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
     -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
     -H "Content-Type: application/json")

ACCOUNT_ID=$(echo "$ACCOUNT_INFO" | jq -r '.result[0].id')
ACCOUNT_NAME=$(echo "$ACCOUNT_INFO" | jq -r '.result[0].name')

if [ "$ACCOUNT_ID" = "null" ] || [ -z "$ACCOUNT_ID" ]; then
    echo "❌ アカウント情報の取得に失敗しました"
    echo "$ACCOUNT_INFO" | jq .
    exit 1
fi

echo "✅ アカウント: $ACCOUNT_NAME ($ACCOUNT_ID)"
echo ""

# API Token を作成
echo "🔨 API Token を作成中..."

TOKEN_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/user/tokens" \
     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
     -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
     -H "Content-Type: application/json" \
     --data "{
       \"name\": \"mobi360-github-actions-$(date +%Y%m%d%H%M%S)\",
       \"policies\": [
         {
           \"effect\": \"allow\",
           \"resources\": {
             \"com.cloudflare.api.account.*\": \"*\"
           },
           \"permission_groups\": [
             {
               \"id\": \"c8fed203ed3043cba015a93ad1616f1f\",
               \"name\": \"Workers Scripts:Edit\"
             }
           ]
         },
         {
           \"effect\": \"allow\",
           \"resources\": {
             \"com.cloudflare.api.account.zone.*\": \"*\"
           },
           \"permission_groups\": [
             {
               \"id\": \"82e64a83756745bbbb1c9c2701bf816b\",
               \"name\": \"Zone:Read\"
             }
           ]
         }
       ]
     }")

# トークンを抽出
TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.result.value')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo "❌ トークンの作成に失敗しました"
    echo "$TOKEN_RESPONSE" | jq .
    exit 1
fi

echo "✅ API Token を作成しました！"
echo ""

# トークンを検証
echo "🧪 トークンを検証中..."
VERIFY_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json")

if echo "$VERIFY_RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
    echo "✅ トークンの検証に成功しました"
else
    echo "❌ トークンの検証に失敗しました"
    echo "$VERIFY_RESPONSE" | jq .
    exit 1
fi

echo ""
echo "📤 GitHub Secret に設定中..."
gh secret set CLOUDFLARE_API_TOKEN --repo yukihamada/mobi360 --body "$TOKEN"

echo ""
echo "✅ 設定完了！"
echo ""
echo "設定されたトークン情報:"
echo "- 名前: mobi360-github-actions-$(date +%Y%m%d%H%M%S)"
echo "- 権限: Workers Scripts:Edit, Zone:Read"
echo ""
echo "🚀 GitHub Actions が使用できるようになりました"
echo ""
echo "テストするには:"
echo "git commit --allow-empty -m 'test: trigger deployment' && git push"