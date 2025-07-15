#!/bin/bash

# Cloudflare API Token作成スクリプト

echo "🔑 Cloudflare API Token 作成スクリプト"
echo "======================================"
echo ""

# Cloudflareの認証情報を取得
WRANGLER_CONFIG="$HOME/.wrangler/config/default.toml"

if [ ! -f "$WRANGLER_CONFIG" ]; then
    echo "❌ Wrangler設定が見つかりません。wrangler loginを実行してください。"
    exit 1
fi

# 既存のoauth_tokenを取得（これを使ってAPI Tokenを作成）
OAUTH_TOKEN=$(grep "oauth_token" "$WRANGLER_CONFIG" | cut -d'"' -f2)

if [ -z "$OAUTH_TOKEN" ]; then
    echo "❌ OAuth tokenが見つかりません"
    exit 1
fi

echo "📊 ユーザー情報を取得中..."

# ユーザー情報を取得
USER_INFO=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user" \
     -H "Authorization: Bearer $OAUTH_TOKEN" \
     -H "Content-Type: application/json")

USER_ID=$(echo "$USER_INFO" | jq -r '.result.id')
EMAIL=$(echo "$USER_INFO" | jq -r '.result.email')

if [ "$USER_ID" = "null" ]; then
    echo "❌ ユーザー情報の取得に失敗しました"
    echo "$USER_INFO" | jq .
    exit 1
fi

echo "✅ ユーザー: $EMAIL"
echo ""

# アカウント情報を取得
echo "📊 アカウント情報を取得中..."
ACCOUNTS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
     -H "Authorization: Bearer $OAUTH_TOKEN" \
     -H "Content-Type: application/json")

ACCOUNT_ID=$(echo "$ACCOUNTS" | jq -r '.result[0].id')

if [ "$ACCOUNT_ID" = "null" ]; then
    echo "❌ アカウント情報の取得に失敗しました"
    exit 1
fi

echo "✅ アカウントID: $ACCOUNT_ID"
echo ""

# 新しいAPI Tokenを作成
echo "🔨 GitHub Actions用のAPI Tokenを作成中..."

TOKEN_NAME="mobi360-github-actions-$(date +%Y%m%d%H%M%S)"

# API Token作成のリクエスト
TOKEN_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/user/tokens" \
     -H "Authorization: Bearer $OAUTH_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "name": "'$TOKEN_NAME'",
       "policies": [
         {
           "effect": "allow",
           "resources": {
             "com.cloudflare.api.account.'"$ACCOUNT_ID"'": "*"
           },
           "permission_groups": [
             {
               "id": "f7f0eda5697f475c90846e879bab8666",
               "name": "Account Settings:Read"
             },
             {
               "id": "e086da7e2179491d91ee5f35b3ca210a",
               "name": "Workers Scripts:Edit"
             }
           ]
         },
         {
           "effect": "allow",
           "resources": {
             "com.cloudflare.api.account.zone.*": "*"
           },
           "permission_groups": [
             {
               "id": "82e64a83756745bbbb1c9c2701bf816b",
               "name": "Zone:Read"
             }
           ]
         },
         {
           "effect": "allow",
           "resources": {
             "com.cloudflare.api.user.'"$USER_ID"'": "*"
           },
           "permission_groups": [
             {
               "id": "c1fde68c7bcc44588cbb6ddbc16d6480",
               "name": "User Details:Read"
             }
           ]
         }
       ]
     }')

# トークンを抽出
NEW_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.result.value')

if [ "$NEW_TOKEN" = "null" ] || [ -z "$NEW_TOKEN" ]; then
    echo "❌ トークンの作成に失敗しました"
    echo "$TOKEN_RESPONSE" | jq .
    exit 1
fi

echo "✅ API Tokenを作成しました: $TOKEN_NAME"
echo ""

# トークンを検証
echo "🧪 トークンを検証中..."
VERIFY_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $NEW_TOKEN" \
     -H "Content-Type: application/json")

if echo "$VERIFY_RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
    echo "✅ トークンの検証に成功しました"
else
    echo "❌ トークンの検証に失敗しました"
    echo "$VERIFY_RESPONSE" | jq .
    exit 1
fi

echo ""
echo "📤 GitHub Secretを更新中..."
echo "$NEW_TOKEN" | gh secret set CLOUDFLARE_API_TOKEN --repo yukihamada/mobi360

echo ""
echo "✅ 完了！"
echo ""
echo "🚀 ワークフローを再実行します..."
gh run rerun --repo yukihamada/mobi360 --latest --failed

echo ""
echo "📊 進行状況を確認:"
echo "https://github.com/yukihamada/mobi360/actions"