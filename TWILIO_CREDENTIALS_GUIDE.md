# Twilio認証情報取得ガイド

## 📝 1. Twilioアカウント作成

### ステップ1: サインアップ
1. [https://www.twilio.com/try-twilio](https://www.twilio.com/try-twilio) にアクセス
2. 以下の情報を入力：
   - 名前（ローマ字）
   - メールアドレス
   - パスワード（14文字以上、大文字小文字数字記号を含む）

### ステップ2: 電話番号認証
1. 携帯電話番号を入力（例: +81 90-1234-5678）
2. SMSで届く認証コードを入力

### ステップ3: アンケート回答
- 「What do you want to do first?」→「Make a voice call」を選択
- 「What's your goal?」→「Alert customers」など適当に選択
- 「Preferred language」→「Node.js」を選択

## 🔑 2. Account SIDとAuth Tokenの取得

### コンソールにログイン後：
1. **Twilioコンソール**（https://console.twilio.com）にアクセス
2. ダッシュボードに自動的に表示される：

```
Account Info
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Account SID: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            （34文字の英数字）
            
Auth Token:  ••••••••••••••••••••••••••••••••
            「Show」をクリックで表示
```

### 取得方法：
- **Account SID**: そのままコピー
- **Auth Token**: 「Show」をクリック → 表示された32文字をコピー

## 📞 3. 電話番号の購入

### ステップ1: Phone Numbers メニューへ
1. 左側メニュー → 「Phone Numbers」→「Manage」→「Buy a number」
2. または直接: https://console.twilio.com/us1/develop/phone-numbers/manage/search

### ステップ2: 番号の検索
1. **Country**: 
   - 「United States」を選択（無料トライアルは米国番号のみ）
   - 日本番号は有料アカウント必要
   
2. **Capabilities**: 
   - ✅ Voice（必須）
   - ✅ SMS（オプション）
   
3. 「Search」をクリック

### ステップ3: 番号の選択と購入
1. リストから好きな番号を選択（例: +1 240-792-7324）
2. 「Buy」ボタンをクリック
3. 確認画面で「Buy This Number」をクリック

## 💰 4. 無料トライアルの制限

### 初回クレジット
- **$15.50**の無料クレジット付与
- 電話番号購入で$1消費 → 残り$14.50

### 通話料金（目安）
- 米国内通話: $0.0085/分
- 日本への国際通話: $0.075/分
- 約180分の米国内通話が可能

### 制限事項
- ✅ 認証済み番号のみに発信可能
- ✅ Twilioロゴの透かし音声が入る
- ❌ 日本の電話番号は購入不可
- ❌ 本番利用は不可

## 🚀 5. 認証情報の設定

### `.env`ファイルを作成：
```bash
# 実際の値に置き換える
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=abcdef1234567890abcdef1234567890
TWILIO_PHONE_NUMBER=+12407927324
```

### セキュリティ注意事項：
- ⚠️ **Auth Tokenは絶対に公開しない**
- ⚠️ `.env`ファイルは`.gitignore`に追加
- ⚠️ 本番環境では環境変数を使用

## 🔧 6. 発信可能番号の登録（重要）

無料トライアルでは、事前登録した番号のみに発信可能：

1. Twilioコンソール → 「Phone Numbers」→「Verified Caller IDs」
2. 「Add a new Caller ID」をクリック
3. 発信先の電話番号を入力（例: +81 90-xxxx-xxxx）
4. SMSまたは音声で認証コードを受信
5. 認証コードを入力して完了

## 📋 7. 確認チェックリスト

- [ ] Twilioアカウント作成完了
- [ ] Account SID取得（ACで始まる34文字）
- [ ] Auth Token取得（32文字）
- [ ] 電話番号購入（+1で始まる番号）
- [ ] 発信先番号の認証完了
- [ ] `.env`ファイルに設定記入

## 🆘 トラブルシューティング

### 「Invalid credentials」エラー
→ Account SIDとAuth Tokenが正しくコピーされているか確認

### 電話がかからない
→ 発信先番号がVerified Caller IDsに登録されているか確認

### 残高不足
→ Billing → Balanceで残高確認（$0.50以下だと発信不可）

## 🔗 参考リンク
- [Twilioコンソール](https://console.twilio.com)
- [料金計算ツール](https://www.twilio.com/pricing)
- [無料トライアルFAQ](https://support.twilio.com/hc/en-us/articles/223136107)