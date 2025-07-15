# 🔑 Cloudflare API Token 生成ガイド

## 📋 手順

### 1. Cloudflareダッシュボードにアクセス
[https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)

### 2. Create Token をクリック
![Create Token Button]

### 3. Custom token を選択
一番下の「Create Custom Token」を選択

### 4. トークンの設定

#### Token name
```
mobi360-github-actions
```

#### Permissions
以下の権限を追加：

| Resource | Permission |
|----------|------------|
| Account - Cloudflare Workers | Edit |
| Zone - Zone | Read |

#### Zone Resources
- Include: All zones

### 5. Continue to summary → Create Token

### 6. トークンをコピー
生成されたトークンをコピー（一度しか表示されません！）

## 🔐 セキュリティ注意事項

- このトークンは秘密情報です
- GitHubのSecretsにのみ保存してください
- コードにハードコーディングしないでください
- 定期的にローテーションすることを推奨

## 🧪 トークンのテスト

```bash
# トークンが有効か確認
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     -H "Content-Type:application/json"
```

成功すると以下のレスポンスが返ります：
```json
{
  "result": {"id":"...","status":"active"},
  "success": true
}
```