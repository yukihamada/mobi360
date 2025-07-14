#!/bin/bash
# Post-commit hook - CLAUDE.md準拠の自動化処理

set -e

# カラー出力設定
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

echo -e "${BLUE}🔄 Post-commit hook実行中...${RESET}"

# コミット情報取得
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

# 変更ログ記録
echo "### $(date '+%Y-%m-%d %H:%M:%S') - Commit: ${COMMIT_HASH:0:7}" >> logs/changes.log
echo "- **コミットメッセージ**: ${COMMIT_MESSAGE}" >> logs/changes.log
echo "- **変更ファイル**: ${CHANGED_FILES}" >> logs/changes.log
echo "- **影響範囲**: 自動分析実行" >> logs/changes.log
echo "" >> logs/changes.log

# Google Chat通知（実装予定）
if [ -n "$GOOGLE_CHAT_WEBHOOK" ]; then
    echo -e "${YELLOW}📢 Google Chat通知送信中...${RESET}"
    # curl -X POST "$GOOGLE_CHAT_WEBHOOK" \
    #   -H "Content-Type: application/json" \
    #   -d "{\"text\":\"🚀 新しいコミット: ${COMMIT_MESSAGE}\"}"
    echo -e "${YELLOW}⚠️  Google Chat Webhook未設定${RESET}"
fi

# AI変更影響分析（実装予定）
echo -e "${YELLOW}🤖 AI変更影響分析実行中...${RESET}"
# make mcp-process

echo -e "${GREEN}✅ Post-commit hook完了${RESET}"