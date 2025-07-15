#!/bin/bash

echo "🔑 Cloudflare API Token設定ガイド"
echo "================================"
echo ""
echo "1. ブラウザで以下のURLを開いてください:"
echo "   https://dash.cloudflare.com/profile/api-tokens"
echo ""
echo "2. 'Create Token' → 'Custom token' を選択"
echo ""
echo "3. 以下の設定をしてください:"
echo ""
echo "Token name: mobi360-github-actions"
echo ""
echo "Permissions:"
echo "- Account → Cloudflare Workers Scripts → Edit"
echo "- Account → Account Settings → Read"  
echo "- Zone → Zone → Read"
echo "- User → User Details → Read"
echo ""
echo "Account Resources:"
echo "- Include → All accounts"
echo ""
echo "Zone Resources:"
echo "- Include → All zones"
echo ""
echo "4. 'Continue to summary' → 'Create Token'"
echo ""
echo "5. 生成されたトークンをコピー"
echo ""
read -p "生成したトークンを貼り付けてください: " CF_TOKEN

if [ -z "$CF_TOKEN" ]; then
    echo "❌ トークンが入力されていません"
    exit 1
fi

echo ""
echo "🧪 トークンを検証中..."

VERIFY_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $CF_TOKEN" \
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
echo "$CF_TOKEN" | gh secret set CLOUDFLARE_API_TOKEN --repo yukihamada/mobi360

echo ""
echo "✅ 設定完了！"
echo ""
echo "🚀 ワークフローを再実行します..."

# 最新の失敗したワークフローを取得
LATEST_RUN=$(gh run list --repo yukihamada/mobi360 --limit 1 --json databaseId,status,conclusion | jq -r '.[0]')
RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId')
CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')

if [ "$CONCLUSION" = "failure" ]; then
    echo "失敗したワークフロー #$RUN_ID を再実行..."
    gh run rerun $RUN_ID --repo yukihamada/mobi360
else
    echo "最新のワークフローは成功しています"
fi

echo ""
echo "📊 進行状況を確認:"
echo "https://github.com/yukihamada/mobi360/actions"