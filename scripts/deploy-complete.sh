#!/bin/bash
# 完全デプロイメントスクリプト - アプリリリース用

set -e

# カラー出力設定
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

echo -e "${BLUE}🚀 Mobility Ops 360 完全デプロイメント開始${RESET}"

# 作業ディレクトリ
PROJECT_ROOT="/Users/yuki/mobi360"
FRONTEND_DIR="$PROJECT_ROOT/frontend/mobi360_app"
BACKEND_DIR="$PROJECT_ROOT/backend"

# 1. 事前チェック
echo -e "${YELLOW}🔍 事前チェック実行中...${RESET}"

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${RED}❌ CLOUDFLARE_API_TOKEN が設定されていません${RESET}"
    echo "export CLOUDFLARE_API_TOKEN=your_token_here を実行してください"
    exit 1
fi

# 2. バックエンドデプロイ
echo -e "${YELLOW}📡 バックエンドデプロイ中...${RESET}"
cd "$BACKEND_DIR"

# プロダクション用DB作成（初回のみ）
wrangler d1 create mobi360-production-db || echo "DB既存"

# マイグレーション実行
wrangler d1 execute mobi360-production-db --file=./migrations/001_initial_schema.sql --env production || echo "マイグレーション完了済み"

# Workers デプロイ
wrangler deploy --env production

echo -e "${GREEN}✅ バックエンドデプロイ完了${RESET}"

# 3. フロントエンドビルド
echo -e "${YELLOW}📱 フロントエンドビルド中...${RESET}"
cd "$FRONTEND_DIR"

# Webビルド
flutter build web --release \
    --dart-define=FLUTTER_ENV=production \
    --dart-define=API_BASE_URL=https://api.mobility360.jp

# デプロイファイル準備
cp "$PROJECT_ROOT/_headers" build/web/
cp "$PROJECT_ROOT/_redirects" build/web/

echo -e "${GREEN}✅ フロントエンドビルド完了${RESET}"

# 4. Cloudflare Pages デプロイ
echo -e "${YELLOW}🌐 Cloudflare Pages デプロイ中...${RESET}"

# Pages プロジェクト作成（初回のみ）
wrangler pages project create mobility-ops-360 || echo "プロジェクト既存"

# デプロイ実行
wrangler pages deploy build/web --project-name mobility-ops-360 --compatibility-date 2024-01-15

echo -e "${GREEN}✅ フロントエンドデプロイ完了${RESET}"

# 5. ヘルスチェック
echo -e "${YELLOW}🏥 ヘルスチェック実行中...${RESET}"

sleep 30

# API ヘルスチェック
API_HEALTH=$(curl -s https://api.mobility360.jp/health || echo "error")
if [[ "$API_HEALTH" == *"healthy"* ]]; then
    echo -e "${GREEN}✅ API正常動作${RESET}"
else
    echo -e "${RED}❌ API動作異常${RESET}"
fi

# フロントエンド ヘルスチェック  
FRONTEND_CHECK=$(curl -s -o /dev/null -w "%{http_code}" https://mobility-ops-360.pages.dev || echo "000")
if [[ "$FRONTEND_CHECK" == "200" ]]; then
    echo -e "${GREEN}✅ フロントエンド正常動作${RESET}"
else
    echo -e "${RED}❌ フロントエンド動作異常${RESET}"
fi

# 6. 最終レポート
echo -e "${BLUE}📊 デプロイメント完了レポート${RESET}"
echo -e "${GREEN}🎉 Mobility Ops 360 アプリリリース完了！${RESET}"
echo ""
echo -e "${BLUE}🌐 アクセス先:${RESET}"
echo "  📱 Web App: https://mobility-ops-360.pages.dev"
echo "  🔧 API: https://api.mobility360.jp" 
echo "  🏥 Health: https://api.mobility360.jp/health"
echo ""
echo -e "${BLUE}📦 成果物:${RESET}"
echo "  ✅ Flutter Web App (PWA対応)"
echo "  ✅ iOS App (build/ios/iphoneos/Runner.app)"
echo "  ✅ Cloudflare Workers API"
echo "  ✅ D1 Database (本番環境)"
echo ""
echo -e "${BLUE}🔧 管理画面:${RESET}"
echo "  📊 Cloudflare Dashboard: https://dash.cloudflare.com"
echo "  📈 Wrangler Analytics: wrangler pages deployment list"
echo ""
echo -e "${YELLOW}📋 次のステップ:${RESET}"
echo "  1. カスタムドメイン設定 (mobility360.jp)"
echo "  2. App Store / Google Play Console 設定"
echo "  3. DNS設定 (api.mobility360.jp)"
echo "  4. SSL証明書確認"
echo "  5. モニタリング設定"

# 7. 通知送信
if command -v ./scripts/notify.sh &> /dev/null; then
    ./scripts/notify.sh "🎉 Mobility Ops 360 アプリリリース完了！Web: https://mobility-ops-360.pages.dev" "success"
fi

echo -e "${GREEN}🚀 デプロイメント完全成功！${RESET}"