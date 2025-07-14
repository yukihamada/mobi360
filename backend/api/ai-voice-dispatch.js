import { Hono } from 'hono';
import { z } from 'zod';
// Twilio SDKは使用しない（直接HTTP APIを使用）

const app = new Hono();

// バリデーションスキーマ
const dispatchRequestSchema = z.object({
  customerName: z.string().min(1),
  customerPhone: z.string().regex(/^\+?[1-9]\d{1,14}$/),
  pickupLocation: z.string().min(1),
  destination: z.string().min(1),
  requestedTime: z.string().optional(),
  vehicleType: z.enum(['standard', 'premium', 'wheelchair']).default('standard'),
  notes: z.string().optional()
});

const voiceInputSchema = z.object({
  SpeechResult: z.string().optional(),
  Confidence: z.number().optional(),
  CallSid: z.string(),
  From: z.string(),
  To: z.string()
});

/**
 * 新しい配車リクエストを作成し、AI音声通話を開始
 */
app.post('/create', async (c) => {
  try {
    const body = await c.req.json();
    const dispatchData = dispatchRequestSchema.parse(body);
    
    // 配車リクエストをデータベースに保存
    const dispatchId = crypto.randomUUID();
    const dispatch = {
      id: dispatchId,
      ...dispatchData,
      status: 'pending',
      createdAt: new Date().toISOString(),
      estimatedArrival: 15, // 15分後の到着予定
      vehicleNumber: 'TK-' + Math.floor(Math.random() * 1000).toString().padStart(3, '0'),
      driverName: 'ドライバー田中' // 実際はマッチングシステムから取得
    };

    // D1データベースに保存
    await c.env.D1_MOBI360_DB.prepare(`
      INSERT INTO dispatch_requests (
        id, customer_name, customer_phone, pickup_location, destination,
        vehicle_type, status, created_at, estimated_arrival, vehicle_number, driver_name
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(
      dispatch.id,
      dispatch.customerName,
      dispatch.customerPhone,
      dispatch.pickupLocation,
      dispatch.destination,
      dispatch.vehicleType,
      dispatch.status,
      dispatch.createdAt,
      dispatch.estimatedArrival,
      dispatch.vehicleNumber,
      dispatch.driverName
    ).run();

    // AI音声通話を開始（Twilio統合）
    const callResult = await initiateVoiceCall(dispatch.customerPhone, dispatchId, c.env);

    if (callResult.success) {
      // 通話開始成功
      await c.env.D1_MOBI360_DB.prepare(`
        UPDATE dispatch_requests 
        SET call_sid = ?, status = 'calling' 
        WHERE id = ?
      `).bind(callResult.callSid, dispatchId).run();

      return c.json({
        success: true,
        dispatchId: dispatchId,
        callSid: callResult.callSid,
        status: 'calling',
        message: 'AI音声通話を開始しました'
      });
    } else {
      // 通話開始失敗
      return c.json({
        success: false,
        dispatchId: dispatchId,
        error: callResult.error,
        message: 'AI音声通話の開始に失敗しました'
      }, 500);
    }
  } catch (error) {
    console.error('AI Voice Dispatch Error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: 'AI音声配車の処理中にエラーが発生しました'
    }, 500);
  }
});

/**
 * TwiMLレスポンスを生成（音声応答）
 */
app.post('/twiml/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    
    // 配車データを取得
    const dispatch = await c.env.D1_MOBI360_DB.prepare(`
      SELECT * FROM dispatch_requests WHERE id = ?
    `).bind(dispatchId).first();

    if (!dispatch) {
      return c.text('<?xml version="1.0" encoding="UTF-8"?><Response><Say voice="alice" language="ja-JP">申し訳ございません。配車情報が見つかりません。</Say></Response>', 200, {
        'Content-Type': 'application/xml'
      });
    }

    const twiml = generateTwiMLResponse(dispatch);

    return c.text(twiml, 200, {
      'Content-Type': 'application/xml'
    });
  } catch (error) {
    console.error('TwiML Generation Error:', error);
    return c.text('<?xml version="1.0" encoding="UTF-8"?><Response><Say voice="alice" language="ja-JP">システムエラーが発生しました。しばらく経ってから再度お試しください。</Say></Response>', 200, {
      'Content-Type': 'application/xml'
    });
  }
});

/**
 * 顧客の音声入力を処理
 */
app.post('/process/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    const body = await c.req.parseBody();
    const voiceInput = voiceInputSchema.parse(body);

    // 配車データを取得
    const dispatch = await c.env.D1_MOBI360_DB.prepare(`
      SELECT * FROM dispatch_requests WHERE id = ?
    `).bind(dispatchId).first();

    if (!dispatch) {
      return c.text('<?xml version="1.0" encoding="UTF-8"?><Response><Say voice="alice" language="ja-JP">申し訳ございません。配車情報が見つかりません。</Say></Response>', 200, {
        'Content-Type': 'application/xml'
      });
    }

    const twiml = generateTwiMLResponse(dispatch, voiceInput.SpeechResult);

    // 音声入力をログに記録
    await c.env.D1_MOBI360_DB.prepare(`
      INSERT INTO voice_interactions (
        dispatch_id, speech_result, confidence, call_sid, created_at
      ) VALUES (?, ?, ?, ?, ?)
    `).bind(
      dispatchId,
      voiceInput.SpeechResult,
      voiceInput.Confidence,
      voiceInput.CallSid,
      new Date().toISOString()
    ).run();

    return c.text(twiml, 200, {
      'Content-Type': 'application/xml'
    });
  } catch (error) {
    console.error('Voice Processing Error:', error);
    return c.text('<?xml version="1.0" encoding="UTF-8"?><Response><Say voice="alice" language="ja-JP">音声処理中にエラーが発生しました。</Say></Response>', 200, {
      'Content-Type': 'application/xml'
    });
  }
});

/**
 * 配車確定処理
 */
app.post('/confirm/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    
    // 配車を確定状態に更新
    await c.env.D1_MOBI360_DB.prepare(`
      UPDATE dispatch_requests 
      SET status = 'confirmed', confirmed_at = ? 
      WHERE id = ?
    `).bind(new Date().toISOString(), dispatchId).run();

    // 配車確定をドライバーに通知（将来実装）
    // await c.env.DISPATCH_JOBS.send({
    //   type: 'dispatch_confirmed',
    //   dispatchId: dispatchId,
    //   timestamp: new Date().toISOString()
    // });

    return c.json({
      success: true,
      dispatchId: dispatchId,
      status: 'confirmed',
      message: '配車が確定しました'
    });
  } catch (error) {
    console.error('Dispatch Confirmation Error:', error);
    return c.json({
      success: false,
      error: error.message,
      message: '配車確定処理中にエラーが発生しました'
    }, 500);
  }
});

/**
 * 通話ステータスを処理
 */
app.post('/status/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    const body = await c.req.parseBody();
    
    const statusUpdate = await handleCallStatus(
      body.CallSid,
      body.CallStatus,
      dispatchId,
      c.env
    );

    // 通話ステータスをデータベースに更新
    await c.env.D1_MOBI360_DB.prepare(`
      UPDATE dispatch_requests 
      SET call_status = ?, call_updated_at = ? 
      WHERE id = ?
    `).bind(
      body.CallStatus,
      new Date().toISOString(),
      dispatchId
    ).run();

    return c.json({
      success: true,
      statusUpdate: statusUpdate
    });
  } catch (error) {
    console.error('Call Status Error:', error);
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

/**
 * 配車リクエストの詳細を取得
 */
app.get('/:dispatchId', async (c) => {
  try {
    const dispatchId = c.req.param('dispatchId');
    
    const dispatch = await c.env.D1_MOBI360_DB.prepare(`
      SELECT * FROM dispatch_requests WHERE id = ?
    `).bind(dispatchId).first();

    if (!dispatch) {
      return c.json({
        success: false,
        error: 'Dispatch not found'
      }, 404);
    }

    return c.json({
      success: true,
      dispatch: dispatch
    });
  } catch (error) {
    console.error('Get Dispatch Error:', error);
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// ユーティリティ関数

// Twilio音声通話を開始
async function initiateVoiceCall(phoneNumber, dispatchId, env) {
  try {
    // 実際のTwilio API呼び出し（要実装）
    const twilioAccountSid = env.TWILIO_ACCOUNT_SID;
    const twilioAuthToken = env.TWILIO_AUTH_TOKEN;
    const twilioPhoneNumber = env.TWILIO_PHONE_NUMBER;

    if (!twilioAccountSid || !twilioAuthToken || !twilioPhoneNumber) {
      return {
        success: false,
        error: 'Twilio credentials not configured'
      };
    }

    // Twilio API呼び出し（HTTP API直接）
    const auth = btoa(`${twilioAccountSid}:${twilioAuthToken}`);
    const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${twilioAccountSid}/Calls.json`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        To: phoneNumber,
        From: twilioPhoneNumber,
        Url: `${env.API_BASE_URL}/api/v1/ai-voice-dispatch/twiml/${dispatchId}`,
        Method: 'POST',
        StatusCallback: `${env.API_BASE_URL}/api/v1/ai-voice-dispatch/status/${dispatchId}`,
        StatusCallbackMethod: 'POST'
      })
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Twilio API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    return {
      success: true,
      callSid: data.sid
    };
  } catch (error) {
    console.error('Twilio call initiation error:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

// TwiMLレスポンスを生成
function generateTwiMLResponse(dispatch, speechResult = null) {
  const message = speechResult ? 
    processVoiceInput(speechResult, dispatch) : 
    generateInitialMessage(dispatch);

  return `<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="Polly.Mizuki" language="ja-JP">${message}</Say>
    <Gather input="speech" speechTimeout="auto" language="ja-JP" action="/api/v1/ai-voice-dispatch/process/${dispatch.id}">
        <Say voice="Polly.Mizuki" language="ja-JP">お返事をお聞かせください。</Say>
    </Gather>
    <Say voice="Polly.Mizuki" language="ja-JP">お返事が聞こえませんでした。失礼いたします。</Say>
    <Hangup/>
</Response>`;
}

// 初期メッセージを生成
function generateInitialMessage(dispatch) {
  return `こんにちは。${dispatch.customer_name || 'お客'}様、Mobility Ops 360のAI音声配車システムです。
${dispatch.pickup_location}から${dispatch.destination}へのタクシーをご用意いたします。
到着予定時刻は約${dispatch.estimated_arrival}分後となります。
車両番号は${dispatch.vehicle_number}、担当ドライバーは${dispatch.driver_name}です。
この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。`;
}

// 音声入力を処理
function processVoiceInput(speechResult, dispatch) {
  const input = speechResult.toLowerCase();
  
  if (input.includes('はい') || input.includes('オッケー') || input.includes('ok')) {
    return `ありがとうございます。配車を確定いたします。
車両番号${dispatch.vehicle_number}のタクシーが${dispatch.estimated_arrival}分後に到着予定です。
ドライバーの${dispatch.driver_name}よりお迎えにあがります。お待ちください。`;
  } else if (input.includes('いいえ') || input.includes('キャンセル') || input.includes('いらない')) {
    return `承知いたしました。配車をキャンセルいたします。
またのご利用をお待ちしております。失礼いたします。`;
  } else if (input.includes('時間') || input.includes('いつ')) {
    return `到着予定時刻は約${dispatch.estimated_arrival}分後となります。
この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。`;
  } else if (input.includes('車両') || input.includes('ナンバー')) {
    return `車両番号は${dispatch.vehicle_number}です。
担当ドライバーは${dispatch.driver_name}です。
この内容でよろしいでしょうか？「はい」または「いいえ」でお答えください。`;
  } else {
    return `申し訳ございません。もう一度お聞かせください。
「はい」で配車確定、「いいえ」でキャンセルとなります。`;
  }
}

// 通話ステータスを処理
async function handleCallStatus(callSid, callStatus, dispatchId, env) {
  console.log(`Call ${callSid} status: ${callStatus} for dispatch ${dispatchId}`);
  
  const statusMap = {
    'ringing': '呼び出し中',
    'in-progress': '通話中',
    'completed': '通話完了',
    'busy': '話し中',
    'failed': '通話失敗',
    'no-answer': '応答なし'
  };

  return {
    callSid: callSid,
    status: callStatus,
    statusJapanese: statusMap[callStatus] || callStatus,
    timestamp: new Date().toISOString()
  };
}

export { app as aiVoiceDispatchRoutes };