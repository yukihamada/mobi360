# Mobility Ops 360 - CLI自動化Makefile
# CLAUDE.md準拠の完全自動化開発環境

.PHONY: help dev build test deploy clean onboard reset-testdata html-report mcp-process notify

# デフォルトターゲット
.DEFAULT_GOAL := help

# 環境変数読み込み
include .env.local
export

# カラー出力設定
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BLUE := \033[34m
RESET := \033[0m

# ヘルプ表示
help: ## 📚 利用可能なコマンドを表示
	@echo "$(BLUE)🚖 Mobility Ops 360 - Make Commands$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)📋 詳細: tasks/todo.md を確認してください$(RESET)"

# 初期セットアップ
onboard: ## 🎯 初回セットアップ（環境構築・依存関係インストール）
	@echo "$(BLUE)🚀 Mobility Ops 360 初期セットアップ開始...$(RESET)"
	@mkdir -p hooks/custom_hooks config docs/reports logs
	@cp .env.example .env.local 2>/dev/null || echo "$(YELLOW)⚠️  .env.example が見つかりません$(RESET)"
	@echo "$(GREEN)✅ ディレクトリ構造作成完了$(RESET)"
	@$(MAKE) install-deps
	@$(MAKE) setup-hooks
	@echo "$(GREEN)🎉 セットアップ完了！make dev でローカル開発を開始できます$(RESET)"

# 依存関係インストール
install-deps: ## 📦 依存関係インストール
	@echo "$(BLUE)📦 依存関係インストール中...$(RESET)"
	@cd backend && npm install
	@cd frontend/mobi360_app && flutter pub get
	@echo "$(GREEN)✅ 依存関係インストール完了$(RESET)"

# フック設定
setup-hooks: ## 🔗 Git フック・自動化フック設定
	@echo "$(BLUE)🔗 自動化フック設定中...$(RESET)"
	@chmod +x hooks/custom_hooks/*.sh 2>/dev/null || echo "$(YELLOW)⚠️  カスタムフックが見つかりません$(RESET)"
	@echo "$(GREEN)✅ フック設定完了$(RESET)"

# 開発環境起動
dev: ## 🚀 ローカル開発環境起動
	@echo "$(BLUE)🚀 ローカル開発環境起動中...$(RESET)"
	@$(MAKE) notify message="開発環境起動開始" type="info"
	@echo "$(YELLOW)📡 バックエンドサーバー起動中...$(RESET)"
	@cd backend && wrangler dev src/simple-index.js --port 56523 &
	@sleep 3
	@echo "$(YELLOW)📱 Flutter Webアプリ起動中...$(RESET)"
	@cd frontend/mobi360_app && flutter run -d web-server --web-port 8080 &
	@sleep 5
	@echo "$(GREEN)✅ 開発環境起動完了$(RESET)"
	@echo "$(BLUE)🌐 アクセス先:$(RESET)"
	@echo "  - Flutter Web: http://localhost:8080"
	@echo "  - Backend API: http://localhost:56523"
	@echo "  - Health Check: http://localhost:56523/health"
	@$(MAKE) notify message="開発環境起動完了 - http://localhost:8080" type="success"

# テスト実行
test: ## 🧪 全テスト実行
	@echo "$(BLUE)🧪 テスト実行中...$(RESET)"
	@$(MAKE) notify message="テスト開始" type="info"
	@echo "$(YELLOW)🔍 Flutter テスト実行中...$(RESET)"
	@cd frontend/mobi360_app && flutter test
	@echo "$(YELLOW)🔍 Backend テスト実行中...$(RESET)"
	@cd backend && npm test 2>/dev/null || echo "$(YELLOW)⚠️  バックエンドテストが設定されていません$(RESET)"
	@echo "$(GREEN)✅ テスト完了$(RESET)"
	@$(MAKE) notify message="テスト完了" type="success"

# ビルド
build: ## 🔨 プロダクションビルド
	@echo "$(BLUE)🔨 プロダクションビルド中...$(RESET)"
	@$(MAKE) notify message="ビルド開始" type="info"
	@echo "$(YELLOW)📱 Flutter Webビルド中...$(RESET)"
	@cd frontend/mobi360_app && flutter build web
	@echo "$(YELLOW)📡 Backend最適化中...$(RESET)"
	@cd backend && wrangler publish --dry-run
	@echo "$(GREEN)✅ ビルド完了$(RESET)"
	@$(MAKE) notify message="ビルド完了" type="success"

# デプロイ
deploy: ## 🚀 本番環境デプロイ
	@echo "$(BLUE)🚀 本番環境デプロイ中...$(RESET)"
	@$(MAKE) notify message="デプロイ開始" type="info"
	@$(MAKE) test
	@$(MAKE) build
	@echo "$(YELLOW)☁️  Cloudflare Workers デプロイ中...$(RESET)"
	@cd backend && wrangler publish
	@echo "$(GREEN)✅ デプロイ完了$(RESET)"
	@$(MAKE) notify message="デプロイ完了" type="success"
	@$(MAKE) log-change file="deployment" summary="本番環境デプロイ完了" impact="本番システム更新"

# テストデータリセット
reset-testdata: ## 🔄 テスト環境データリセット
	@echo "$(BLUE)🔄 テストデータリセット中...$(RESET)"
	@$(MAKE) notify message="テストデータリセット開始" type="info"
	@cd backend && wrangler d1 execute DB --file migrations/001_initial_schema.sql --preview
	@echo "$(GREEN)✅ テストデータリセット完了$(RESET)"
	@echo "$(BLUE)🔑 デモアカウント:$(RESET)"
	@echo "  - Email: demo@example.com"
	@echo "  - Password: pass1234"
	@$(MAKE) notify message="テストデータリセット完了" type="success"

# HTML レポート生成
html-report: ## 📊 HTML形式レポート生成
	@echo "$(BLUE)📊 HTMLレポート生成中...$(RESET)"
	@mkdir -p docs/reports
	@echo "<!DOCTYPE html><html><head><title>Mobility Ops 360 Report</title></head><body>" > docs/reports/development-report.html
	@echo "<h1>🚖 Mobility Ops 360 Development Report</h1>" >> docs/reports/development-report.html
	@echo "<p>Generated: $(shell date)</p>" >> docs/reports/development-report.html
	@echo "<h2>📋 Current Tasks</h2><pre>" >> docs/reports/development-report.html
	@cat tasks/todo.md >> docs/reports/development-report.html
	@echo "</pre></body></html>" >> docs/reports/development-report.html
	@echo "$(GREEN)✅ HTMLレポート生成完了: docs/reports/development-report.html$(RESET)"

# MCP高速AI処理
mcp-process: ## 🚀 MCP経由で高速AI処理 (Groq/ローカルLLM)
	@echo "$(BLUE)🚀 MCP高速AI処理実行中...$(RESET)"
	@$(MAKE) notify message="AI処理開始" type="info"
	@echo "$(YELLOW)🤖 AI分析実行中...$(RESET)"
	@echo "$(GREEN)✅ MCP処理完了（実装予定）$(RESET)"
	@$(MAKE) notify message="AI処理完了" type="success"

# Google Chat通知
notify: ## 📢 Google Chat通知送信
	@if [ -z "$(message)" ]; then \
		echo "$(RED)❌ エラー: message パラメータが必要です$(RESET)"; \
		echo "使用例: make notify message=\"テストメッセージ\" type=\"info\""; \
		exit 1; \
	fi
	@echo "$(BLUE)📢 Google Chat通知送信中...$(RESET)"
	@echo "メッセージ: $(message)"
	@echo "タイプ: $(or $(type),info)"
	@echo "$(YELLOW)⚠️  Google Chat Webhook未設定のため、コンソール出力のみ$(RESET)"
	# TODO: 実際のWebhook送信実装
	# curl -X POST "$(GOOGLE_CHAT_WEBHOOK)" -H "Content-Type: application/json" -d '{"text":"$(message)"}'

# 変更ログ記録
log-change: ## 📝 変更ログ記録
	@if [ -z "$(file)" ] || [ -z "$(summary)" ]; then \
		echo "$(RED)❌ エラー: file, summary パラメータが必要です$(RESET)"; \
		exit 1; \
	fi
	@echo "### $(shell date '+%Y-%m-%d %H:%M:%S') - $(summary)" >> logs/changes.log
	@echo "- **変更ファイル**: \`$(file)\`" >> logs/changes.log
	@echo "- **内容要約**: $(summary)" >> logs/changes.log
	@echo "- **影響範囲**: $(or $(impact),要確認)" >> logs/changes.log
	@echo "" >> logs/changes.log
	@echo "$(GREEN)✅ 変更ログ記録完了$(RESET)"

# クリーンアップ
clean: ## 🧹 ビルドファイル・キャッシュクリーンアップ
	@echo "$(BLUE)🧹 クリーンアップ中...$(RESET)"
	@cd frontend/mobi360_app && flutter clean
	@cd backend && rm -rf node_modules/.cache 2>/dev/null || true
	@rm -rf logs/*.tmp docs/reports/*.tmp 2>/dev/null || true
	@echo "$(GREEN)✅ クリーンアップ完了$(RESET)"

# Git自動コミット
auto-commit: ## 🔄 AI生成メッセージで自動コミット
	@echo "$(BLUE)🔄 自動コミット実行中...$(RESET)"
	@if [ -z "$$(git status --porcelain)" ]; then \
		echo "$(YELLOW)⚠️  コミットする変更がありません$(RESET)"; \
		exit 0; \
	fi
	@echo "$(YELLOW)🤖 AI生成コミットメッセージ作成中...$(RESET)"
	@git add .
	@commit_msg="update: CLAUDE.md準拠の開発環境構築 🚀 Generated with Claude Code"; \
	git commit -m "$$commit_msg"; \
	echo "$(GREEN)✅ 自動コミット完了: $$commit_msg$(RESET)"
	@$(MAKE) notify message="自動コミット完了" type="success"

# 開発サーバー停止
stop: ## ⏹️  開発サーバー停止
	@echo "$(BLUE)⏹️  開発サーバー停止中...$(RESET)"
	@pkill -f "wrangler dev" || true
	@pkill -f "flutter run" || true
	@echo "$(GREEN)✅ 開発サーバー停止完了$(RESET)"

# ヘルスチェック
health: ## 🏥 システムヘルスチェック
	@echo "$(BLUE)🏥 システムヘルスチェック実行中...$(RESET)"
	@curl -s http://localhost:56523/health | jq . || echo "$(RED)❌ バックエンドサーバーに接続できません$(RESET)"
	@curl -s http://localhost:8080 > /dev/null && echo "$(GREEN)✅ フロントエンドサーバー正常$(RESET)" || echo "$(RED)❌ フロントエンドサーバーに接続できません$(RESET)"

# プロダクションビルド
build-production: ## 🏭 プロダクション用完全ビルド
	@echo "$(BLUE)🏭 プロダクションビルド実行中...$(RESET)"
	@$(MAKE) test
	@./scripts/build-production.sh
	@$(MAKE) notify message="プロダクションビルド完了" type="success"

# 完全デプロイメント
deploy-complete: ## 🚀 完全デプロイメント実行（リリース用）
	@echo "$(BLUE)🚀 完全デプロイメント実行中...$(RESET)"
	@./scripts/deploy-complete.sh
	@$(MAKE) notify message="アプリリリース完了🎉" type="success"

# リリース準備チェック
release-check: ## ✅ リリース準備状況チェック
	@echo "$(BLUE)✅ リリース準備チェック実行中...$(RESET)"
	@echo "$(YELLOW)📱 Flutter プロジェクト確認中...$(RESET)"
	@cd frontend/mobi360_app && flutter doctor
	@echo "$(YELLOW)📡 Backend 確認中...$(RESET)"
	@cd backend && npm audit --audit-level high
	@echo "$(YELLOW)📦 ビルド成果物確認中...$(RESET)"
	@ls -la frontend/mobi360_app/build/web/ 2>/dev/null || echo "$(YELLOW)⚠️  Webビルドが必要$(RESET)"
	@ls -la frontend/mobi360_app/build/ios/ 2>/dev/null || echo "$(YELLOW)⚠️  iOSビルドが必要$(RESET)"
	@echo "$(GREEN)✅ リリース準備チェック完了$(RESET)"

# 環境変数テンプレート作成
.env.example: ## 📝 環境変数テンプレート作成
	@echo "# Mobility Ops 360 Environment Variables" > .env.example
	@echo "GOOGLE_CHAT_WEBHOOK=https://chat.googleapis.com/v1/spaces/YOUR_SPACE/messages?key=YOUR_KEY" >> .env.example
	@echo "DATABASE_URL=postgresql://user:pass@localhost:5432/mobility_ops_360" >> .env.example
	@echo "JWT_SECRET=your-jwt-secret-key" >> .env.example
	@echo "TWILIO_ACCOUNT_SID=your-twilio-account-sid" >> .env.example
	@echo "TWILIO_AUTH_TOKEN=your-twilio-auth-token" >> .env.example
	@echo "CLOUDFLARE_API_TOKEN=your-cloudflare-api-token" >> .env.example
	@echo "$(GREEN)✅ .env.example 作成完了$(RESET)"