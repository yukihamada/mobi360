import { Twilio } from 'twilio';

export class VoiceHandler {
  constructor(env) {
    this.twilio = new Twilio(env.TWILIO_ACCOUNT_SID, env.TWILIO_AUTH_TOKEN);
    this.phoneNumber = env.TWILIO_PHONE_NUMBER;
    this.env = env;
  }

  /**
   * 音声通話を開始し、AIアシスタントに接続
   * @param {string} customerPhone - 顧客の電話番号
   * @param {string} dispatchId - 配車リクエストID
   */
  async initiateCall(customerPhone, dispatchId) {
    try {
      const baseUrl = this.env?.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev';
      const call = await this.twilio.calls.create({
        url: `${baseUrl}/api/v1/ai-voice-dispatch/twiml/${dispatchId}`,
        to: customerPhone,
        from: this.phoneNumber,
        method: 'POST',
        statusCallback: `${baseUrl}/api/v1/ai-voice-dispatch/status/${dispatchId}`,
        statusCallbackMethod: 'POST',
        statusCallbackEvent: ['initiated', 'answered', 'completed']
      });

      return {
        success: true,
        callSid: call.sid,
        status: call.status,
        dispatchId
      };
    } catch (error) {
      console.error('Failed to initiate call:', error);
      return {
        success: false,
        error: error.message,
        dispatchId
      };
    }
  }

  /**
   * TwiMLレスポンスを生成（AI音声応答）
   * @param {Object} dispatchData - 配車データ
   * @param {string} customerInput - 顧客の音声入力
   */
  generateTwiML(dispatchData, customerInput = null) {
    const twiml = new this.twilio.twiml.VoiceResponse();

    if (!customerInput) {
      // 初回の挨拶と情報確認
      twiml.say({
        voice: 'alice',
        language: 'ja-JP'
      }, `こんにちは、モビ360配車サービスです。
      ${dispatchData.customerName}様から配車のご依頼をいただきました。
      お迎え場所は${dispatchData.pickupLocation}、
      お送り先は${dispatchData.destination}でよろしいでしょうか？
      はいかいいえでお答えください。`);
      
      const baseUrl = this.env?.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev';
      twiml.gather({
        input: 'speech',
        speechTimeout: 3,
        language: 'ja-JP',
        action: `${baseUrl}/api/v1/ai-voice-dispatch/process/${dispatchData.id}`,
        method: 'POST'
      });
    } else {
      // 顧客の応答に基づく処理
      const confirmation = this.parseCustomerResponse(customerInput);
      
      if (confirmation.confirmed) {
        twiml.say({
          voice: 'alice',
          language: 'ja-JP'
        }, `ありがとうございます。配車を確定いたします。
        お迎えの車両は${dispatchData.estimatedArrival}分後に到着予定です。
        車両番号は${dispatchData.vehicleNumber}、
        ドライバーは${dispatchData.driverName}です。
        お気をつけてお出かけください。`);
        
        // 配車確定の処理をキューに追加
        const baseUrl = this.env?.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev';
        twiml.enqueue({
          action: `${baseUrl}/api/v1/ai-voice-dispatch/confirm/${dispatchData.id}`,
          method: 'POST'
        });
      } else {
        twiml.say({
          voice: 'alice',
          language: 'ja-JP'
        }, `申し訳ございません。詳細を再度確認させていただきます。
        カスタマーサービスにお繋ぎいたします。`);
        
        // 人間のオペレーターに転送
        const baseUrl = this.env?.API_BASE_URL || 'https://mobility-ops-360-api.yukihamada.workers.dev';
        twiml.dial({
          action: `${baseUrl}/api/v1/ai-voice-dispatch/transfer/${dispatchData.id}`,
          method: 'POST'
        }, '+81-3-1234-5678'); // オペレーター番号
      }
    }

    return twiml.toString();
  }

  /**
   * 顧客の音声入力を解析
   * @param {string} input - 音声入力テキスト
   */
  parseCustomerResponse(input) {
    const lowerInput = input.toLowerCase();
    const positiveWords = ['はい', 'yes', 'お願いします', 'ok', '正しい', '間違いない'];
    const negativeWords = ['いいえ', 'no', '違う', '間違い', 'ちがう'];
    
    const isPositive = positiveWords.some(word => lowerInput.includes(word));
    const isNegative = negativeWords.some(word => lowerInput.includes(word));
    
    return {
      confirmed: isPositive && !isNegative,
      input: input,
      confidence: isPositive ? 0.9 : (isNegative ? 0.1 : 0.5)
    };
  }

  /**
   * 通話ステータスを処理
   * @param {string} callSid - 通話SID
   * @param {string} callStatus - 通話ステータス
   * @param {string} dispatchId - 配車ID
   */
  async handleCallStatus(callSid, callStatus, dispatchId) {
    const statusUpdate = {
      callSid,
      status: callStatus,
      timestamp: new Date().toISOString(),
      dispatchId
    };

    // ステータスに応じた処理
    switch (callStatus) {
      case 'completed':
        console.log(`Call completed for dispatch ${dispatchId}`);
        break;
      case 'failed':
        console.error(`Call failed for dispatch ${dispatchId}`);
        // 失敗時の代替処理（SMS送信など）
        await this.sendFallbackSMS(dispatchId);
        break;
      case 'busy':
        console.log(`Customer busy for dispatch ${dispatchId}`);
        // 後で再試行
        await this.scheduleRetry(dispatchId);
        break;
      default:
        console.log(`Call status update: ${callStatus} for dispatch ${dispatchId}`);
    }

    return statusUpdate;
  }

  /**
   * 通話失敗時のSMSフォールバック
   * @param {string} dispatchId - 配車ID
   */
  async sendFallbackSMS(dispatchId) {
    // Implementation for SMS fallback
    // This would integrate with the notification service
    console.log(`Sending fallback SMS for dispatch ${dispatchId}`);
  }

  /**
   * 通話リトライをスケジュール
   * @param {string} dispatchId - 配車ID
   */
  async scheduleRetry(dispatchId) {
    // Implementation for retry scheduling
    // This would use Cloudflare Queues or Durable Objects
    console.log(`Scheduling retry for dispatch ${dispatchId}`);
  }
}