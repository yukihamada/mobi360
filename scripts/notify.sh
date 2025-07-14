#!/bin/bash
# Google Chat通知スクリプト - CLAUDE.md準拠

set -e

# カラー出力設定
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
RESET='\033[0m'

# 引数チェック
if [ $# -lt 2 ]; then
    echo -e "${RED}❌ Usage: $0 <message> <type> [webhook_url]${RESET}"
    echo "Types: info, success, warning, error"
    exit 1
fi

MESSAGE="$1"
TYPE="$2"
WEBHOOK_URL="${3:-$GOOGLE_CHAT_WEBHOOK}"

# アイコンと色の設定
case $TYPE in
    "info")
        ICON="ℹ️"
        COLOR="#2196F3"
        ;;
    "success")
        ICON="✅"
        COLOR="#4CAF50"
        ;;
    "warning")
        ICON="⚠️"
        COLOR="#FF9800"
        ;;
    "error")
        ICON="❌"
        COLOR="#F44336"
        ;;
    *)
        ICON="📢"
        COLOR="#666EEA"
        ;;
esac

# JSONメッセージ構築
JSON_MESSAGE=$(cat <<EOF
{
  "cards": [
    {
      "header": {
        "title": "🚖 Mobility Ops 360",
        "subtitle": "Development Notification"
      },
      "sections": [
        {
          "widgets": [
            {
              "textParagraph": {
                "text": "<font color=\"$COLOR\">$ICON $MESSAGE</font>"
              }
            },
            {
              "textParagraph": {
                "text": "<b>Timestamp:</b> $(date '+%Y-%m-%d %H:%M:%S')<br><b>Environment:</b> ${ENVIRONMENT:-development}"
              }
            }
          ]
        }
      ]
    }
  ]
}
EOF
)

# 通知送信
if [ -n "$WEBHOOK_URL" ] && [ "$WEBHOOK_URL" != "https://chat.googleapis.com/v1/spaces/AAAA_YOUR_SPACE/messages?key=YOUR_KEY" ]; then
    echo -e "${BLUE}📢 Google Chat通知送信中...${RESET}"
    
    RESPONSE=$(curl -s -w "%{http_code}" -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$JSON_MESSAGE")
    
    HTTP_CODE="${RESPONSE: -3}"
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ 通知送信成功${RESET}"
    else
        echo -e "${RED}❌ 通知送信失敗 (HTTP: $HTTP_CODE)${RESET}"
        echo -e "${YELLOW}Response: ${RESPONSE%???}${RESET}"
    fi
else
    echo -e "${YELLOW}⚠️  Google Chat Webhook未設定 - コンソール出力のみ${RESET}"
    echo -e "${BLUE}Message:${RESET} $ICON $MESSAGE"
    echo -e "${BLUE}Type:${RESET} $TYPE"
    echo -e "${BLUE}Timestamp:${RESET} $(date '+%Y-%m-%d %H:%M:%S')"
fi

# ログファイルに記録
LOG_DIR="/Users/yuki/mobi360/logs"
mkdir -p "$LOG_DIR"
echo "$(date '+%Y-%m-%d %H:%M:%S') [$TYPE] $MESSAGE" >> "$LOG_DIR/notifications.log"

echo -e "${GREEN}✅ 通知処理完了${RESET}"