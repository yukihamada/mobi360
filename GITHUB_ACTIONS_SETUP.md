# 🚀 GitHub Actions 自動デプロイ設定ガイド

## 概要
GitHubにpushすると自動的にテストが実行され、mainブランチへのpushで本番環境に自動デプロイされます。

## 🔧 セットアップ手順

### 1. GitHubリポジトリのSecrets設定

[GitHub](https://github.com/yukihamada/mobi360/settings/secrets/actions) で以下のSecretsを追加：

| Secret名 | 値 | 説明 |
|----------|-----|------|
| `CLOUDFLARE_API_TOKEN` | Cloudflareで生成 | Workers デプロイ用 |
| `TWILIO_ACCOUNT_SID` | ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | Twilioアカウント |
| `TWILIO_AUTH_TOKEN` | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | Twilio認証トークン |
| `TWILIO_PHONE_NUMBER` | +19592105018 | Twilio電話番号 |
| `JWT_SECRET` | ランダムな文字列 | JWT署名用 |
| `API_BASE_URL` | https://mobility-ops-360-api.yukihamada.workers.dev | API URL |

### 2. Cloudflare API Token の生成

1. [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens) にアクセス
2. 「Create Token」をクリック
3. 「Custom token」を選択
4. 以下の権限を設定：
   - **Account** - Cloudflare Workers:Edit
   - **Zone** - Zone:Read
5. トークンを生成してGitHub Secretsに追加

### 3. ワークフローの動作

#### 🧪 テスト（全ブランチ）
```yaml
- コードフォーマットチェック
- ESLintによる静的解析
- ユニットテスト実行
- E2Eテスト実行
- セキュリティスキャン
```

#### 🚀 デプロイ（main/masterブランチのみ）
```yaml
1. テストを実行
2. Cloudflare Workersにデプロイ
3. ヘルスチェック
4. スモークテスト
5. 成功通知
```

#### 🔄 プルリクエスト
```yaml
- ステージング環境にデプロイ
- PRにステージングURLをコメント
```

## 📊 ワークフロー

### `.github/workflows/deploy.yml`
- メインのデプロイワークフロー
- main/masterブランチへのpushで起動
- テスト → デプロイ → 検証

### `.github/workflows/test.yml`
- テスト専用ワークフロー
- 全てのpush/PRで起動
- 複数のテストジョブを並列実行

## 🧪 ローカルでのテスト

```bash
# テスト実行
cd backend
npm test
npm run test:e2e

# リント
npm run lint

# フォーマット
npm run format:check
```

## 📈 モニタリング

### デプロイ状況の確認
1. GitHubの「Actions」タブで確認
2. 各ワークフローの実行ログを参照

### ログの確認
```bash
# 本番環境のログ
npm run logs:production

# ローカル開発環境のログ
npm run logs
```

## 🔄 ロールバック

デプロイに失敗した場合：
1. GitHub Actionsが自動的に停止
2. 前のバージョンが維持される
3. エラーログを確認して修正

## 🎯 ベストプラクティス

1. **ブランチ戦略**
   - `main`：本番環境
   - `develop`：開発環境
   - `feature/*`：機能開発

2. **コミットメッセージ**
   ```
   feat: 新機能追加
   fix: バグ修正
   docs: ドキュメント更新
   test: テスト追加
   ```

3. **プルリクエスト**
   - 必ずテストを含める
   - レビューを受ける
   - ステージングで動作確認

## 🚨 トラブルシューティング

### デプロイが失敗する
- Cloudflare API Tokenを確認
- wrangler.tomlの設定を確認
- GitHub Secretsが正しく設定されているか確認

### テストが失敗する
- ローカルでテストを実行
- 依存関係を更新
- テスト環境の設定を確認

## 📝 次のステップ

1. GitHubにpush
2. Actionsタブで進行状況を確認
3. 本番環境で動作確認

```bash
# 動作確認
curl https://mobility-ops-360-api.yukihamada.workers.dev/health
```