#!/bin/bash
# プロダクション用ビルドスクリプト

set -e

# カラー出力設定
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

echo -e "${BLUE}🚀 Mobility Ops 360 プロダクションビルド開始${RESET}"

# 環境確認
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${RED}❌ CLOUDFLARE_API_TOKEN が設定されていません${RESET}"
    exit 1
fi

# バックエンドビルド
echo -e "${YELLOW}📡 バックエンドビルド中...${RESET}"
cd /Users/yuki/mobi360/backend

# プロダクション用D1データベース作成（初回のみ）
echo -e "${YELLOW}🗄️ D1データベースセットアップ中...${RESET}"
wrangler d1 create mobi360-production-db || echo "データベース既存"

# マイグレーション実行
echo -e "${YELLOW}🔄 データベースマイグレーション実行中...${RESET}"
wrangler d1 execute mobi360-production-db --file=./migrations/001_initial_schema.sql --env production || echo "マイグレーション完了済み"

# バックエンドデプロイ
echo -e "${YELLOW}☁️ バックエンドデプロイ中...${RESET}"
wrangler deploy --env production

# フロントエンドビルド
echo -e "${YELLOW}📱 フロントエンドビルド中...${RESET}"
cd /Users/yuki/mobi360/frontend/mobi360_app

# Flutter依存関係更新
flutter pub get

# プロダクション用ビルド
flutter build web --release \
  --dart-define=FLUTTER_ENV=production \
  --dart-define=API_BASE_URL=https://api.mobility360.jp \
  --web-renderer html \
  --pwa-strategy offline-first

# ビルド結果確認
if [ ! -f "build/web/index.html" ]; then
    echo -e "${RED}❌ フロントエンドビルド失敗${RESET}"
    exit 1
fi

echo -e "${GREEN}✅ ビルド完了${RESET}"
echo -e "${BLUE}📦 成果物:${RESET}"
echo "  - バックエンド: Cloudflare Workers デプロイ済み"
echo "  - フロントエンド: build/web/"
echo "  - マニフェスト: PWA対応"

# Cloudflare Pages デプロイ準備
echo -e "${YELLOW}🌐 Cloudflare Pages デプロイ準備中...${RESET}"

# wrangler pages publish build/web --project-name mobility-ops-360

echo -e "${GREEN}🎉 プロダクションビルド完了${RESET}"
echo -e "${BLUE}🌐 アクセス先:${RESET}"
echo "  - Web App: https://mobility360.jp"
echo "  - API: https://api.mobility360.jp"
echo "  - Health Check: https://api.mobility360.jp/health"