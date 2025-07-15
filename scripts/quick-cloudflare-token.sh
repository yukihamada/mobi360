#!/bin/bash

# 簡易版：既存のWranglerトークンを使用

echo "🔍 既存のCloudflare認証情報を確認中..."

# Wranglerの設定ファイルを確認
WRANGLER_CONFIG="$HOME/.wrangler/config/default.toml"

if [ -f "$WRANGLER_CONFIG" ]; then
    echo "✅ Wrangler設定ファイルが見つかりました"
    
    # oauth_tokenを抽出
    OAUTH_TOKEN=$(grep "oauth_token" "$WRANGLER_CONFIG" | cut -d'"' -f2)
    
    if [ ! -z "$OAUTH_TOKEN" ]; then
        echo "🔑 既存のトークンを使用します"
        
        # GitHub Secretに設定
        echo "$OAUTH_TOKEN" | gh secret set CLOUDFLARE_API_TOKEN --repo yukihamada/mobi360
        
        echo ""
        echo "✅ GitHub Secret CLOUDFLARE_API_TOKEN を設定しました！"
        echo ""
        echo "🚀 デプロイをトリガーするには:"
        echo "git commit --allow-empty -m 'chore: trigger deployment' && git push"
    else
        echo "❌ oauth_tokenが見つかりません"
        echo "wrangler login を実行してください"
    fi
else
    echo "❌ Wrangler設定ファイルが見つかりません"
    echo ""
    echo "以下を実行してください:"
    echo "1. wrangler login"
    echo "2. このスクリプトを再実行"
fi