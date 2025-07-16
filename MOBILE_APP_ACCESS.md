# 📱 Mobility Ops 360 モバイルアプリアクセス

## 🌐 Webアプリ（現在起動中）

Flutter Webアプリが起動しています:
- **ローカルURL**: http://localhost:54224
- **機能**: 
  - オンボーディング画面
  - 会社登録
  - ドライバー登録
  - ダッシュボード
  - AI音声配車管理
  - リアルタイムドライバー追跡

## 📱 iPhoneでアクセスする方法

### 1. 同じWi-Fiネットワーク上でアクセス
```bash
# MacのIPアドレスを確認
ifconfig | grep "inet " | grep -v 127.0.0.1
```
例: http://192.168.1.10:54224

### 2. ngrokでトンネル作成（推奨）
```bash
# ngrokインストール（未インストールの場合）
brew install ngrok

# トンネル作成
ngrok http 54224
```
生成されたURLをiPhoneで開く

### 3. iOSシミュレーターで実行
```bash
# シミュレーターを開く
open -a Simulator

# デバイスを選択
xcrun simctl list devices

# Flutter実行
flutter run -d "iPhone 15"
```

## 🚀 アプリの機能

### オンボーディング画面
- AI音声配車の紹介
- ドライバープール説明
- セキュアゲートキーパー

### 管理者向け
- 会社登録
- ドライバー管理
- 配車状況モニタリング
- 売上分析

### ドライバー向け
- ドライバー登録
- リアルタイム配車通知
- 位置情報共有
- 収益管理

## 🔧 デバッグツール

Flutter DevTools:
http://127.0.0.1:9100?uri=http://127.0.0.1:54086/nypusStNlMM=

## 📲 モバイルアプリ化

### PWA（Progressive Web App）
- ホーム画面に追加可能
- オフライン対応
- プッシュ通知

### ネイティブアプリ
```bash
# iOS
flutter build ios

# Android
flutter build apk
```