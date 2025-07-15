#!/usr/bin/env node

// Twilioテスト通話スクリプト
// このスクリプトはTwilioを使ってテスト通話を発信します

const https = require('https');

// Twilio認証情報（環境変数から取得するか、ここに直接入力）
const ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID || 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
const AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN || 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
const TWILIO_PHONE_NUMBER = '+19592105018';

// 通話先の電話番号（コマンドライン引数から取得）
const TO_NUMBER = process.argv[2];

if (!TO_NUMBER) {
  console.log('❌ 使用方法: node make-test-call.js +81901234567');
  console.log('   （電話番号は国番号付きで指定してください）');
  process.exit(1);
}

// Basic認証用のBase64エンコード
const auth = Buffer.from(`${ACCOUNT_SID}:${AUTH_TOKEN}`).toString('base64');

// TwiMLのURL（AI音声配車システムのwebhook）
const twimlUrl = 'https://mobility-ops-360-api.yukihamada.workers.dev/api/voice/incoming';

// リクエストデータ
const postData = new URLSearchParams({
  'To': TO_NUMBER,
  'From': TWILIO_PHONE_NUMBER,
  'Url': twimlUrl,
  'Method': 'POST'
}).toString();

// HTTPSリクエストのオプション
const options = {
  hostname: 'api.twilio.com',
  port: 443,
  path: `/2010-04-01/Accounts/${ACCOUNT_SID}/Calls.json`,
  method: 'POST',
  headers: {
    'Authorization': `Basic ${auth}`,
    'Content-Type': 'application/x-www-form-urlencoded',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('📞 Mobility Ops 360 テスト通話');
console.log('================================');
console.log(`発信元: ${TWILIO_PHONE_NUMBER}`);
console.log(`発信先: ${TO_NUMBER}`);
console.log('');

// リクエスト送信
const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      
      if (res.statusCode === 201) {
        console.log('✅ 通話を開始しました！');
        console.log('');
        console.log('📊 通話情報:');
        console.log(`- Call SID: ${response.sid}`);
        console.log(`- ステータス: ${response.status}`);
        console.log(`- 料金: ${response.price || '計算中'} ${response.price_unit || ''}`);
        console.log('');
        console.log('🎯 次のステップ:');
        console.log('1. 着信を待つ');
        console.log('2. AIの音声案内を聞く');
        console.log('3. 「東京駅から渋谷駅まで」などと話してテスト');
      } else {
        console.log('❌ エラーが発生しました:');
        console.log(`ステータスコード: ${res.statusCode}`);
        console.log(`エラー: ${response.message || response.error || '不明なエラー'}`);
        
        if (response.code === 20003) {
          console.log('\n💡 ヒント: 認証エラーです。Twilioの認証情報を確認してください。');
        } else if (response.code === 21211) {
          console.log('\n💡 ヒント: 電話番号の形式が正しくありません。+81... の形式で指定してください。');
        }
      }
    } catch (e) {
      console.log('❌ レスポンスの解析エラー:', e.message);
      console.log('レスポンス:', data);
    }
  });
});

req.on('error', (e) => {
  console.error('❌ リクエストエラー:', e.message);
});

// リクエストデータを送信
req.write(postData);
req.end();