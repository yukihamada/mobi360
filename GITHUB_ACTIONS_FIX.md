# 🔧 GitHub Actions エラー解決ガイド

## 現在の問題

### ❌ Cloudflare API Token権限エラー
```
Authentication error [code: 10000]
```

## 解決方法

### 1. 新しいCloudflare API Tokenを作成

1. [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens) にアクセス
2. **Create Token** → **Custom token**
3. 以下の権限を設定：

| Permission | Access |
|------------|--------|
| Account - Account Settings | Read |
| Account - Cloudflare Workers Scripts | Edit |
| User - User Details | Read |
| Zone - Zone | Read |
| Zone - Workers Routes | Edit |

4. **Account Resources**
   - Include → All accounts

5. **Zone Resources**
   - Include → All zones

### 2. GitHub Secretを更新

```bash
# 新しいトークンで更新
gh secret set CLOUDFLARE_API_TOKEN --repo yukihamada/mobi360 --body "YOUR_NEW_TOKEN"
```

または [GitHub Secrets](https://github.com/yukihamada/mobi360/settings/secrets/actions) で直接更新

### 3. ワークフローを再実行

```bash
# 最新のワークフローを再実行
gh run rerun --repo yukihamada/mobi360 --latest
```

## 🔍 トークンのテスト

新しいトークンが正しく動作するか確認：

```bash
# トークンの検証
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json"
```

成功レスポンス:
```json
{
  "result": {"id":"...","status":"active"},
  "success": true
}
```

## 📝 注意事項

- Wranglerの既存トークンは権限が不足している可能性があります
- Workers Scripts:Edit 権限が必須です
- トークンは一度しか表示されないので、必ずコピーしてください

## 🚀 今後の対応

1. このドキュメントに従ってトークンを再作成
2. GitHub Secretを更新
3. ワークフローが自動的に再実行されます