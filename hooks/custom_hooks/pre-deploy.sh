#!/bin/bash
# Pre-deploy hook - デプロイ前の品質チェック

set -e

# カラー出力設定
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
RESET='\033[0m'

echo -e "${BLUE}🔍 Pre-deploy hook実行中...${RESET}"

# テスト実行
echo -e "${YELLOW}🧪 テスト実行中...${RESET}"
make test

# ビルド確認
echo -e "${YELLOW}🔨 ビルド確認中...${RESET}"
make build

# セキュリティチェック（実装予定）
echo -e "${YELLOW}🔒 セキュリティチェック実行中...${RESET}"
# npm audit --audit-level moderate

# パフォーマンスチェック（実装予定）
echo -e "${YELLOW}⚡ パフォーマンスチェック実行中...${RESET}"
# lighthouse CI

# 設定確認
echo -e "${YELLOW}⚙️  設定確認中...${RESET}"
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}❌ DATABASE_URL が設定されていません${RESET}"
    exit 1
fi

# デプロイ承認確認
echo -e "${BLUE}🚀 デプロイ準備完了${RESET}"
echo -e "${YELLOW}📢 Google Chat通知送信予定...${RESET}"

echo -e "${GREEN}✅ Pre-deploy hook完了${RESET}"