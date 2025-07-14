import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class VoiceDispatchCard extends StatefulWidget {
  const VoiceDispatchCard({super.key});

  @override
  State<VoiceDispatchCard> createState() => _VoiceDispatchCardState();
}

class _VoiceDispatchCardState extends State<VoiceDispatchCard> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // サンプルデータを設定
    _customerNameController.text = '田中太郎';
    _customerPhoneController.text = '+81-90-1234-5678';
    _pickupLocationController.text = '東京駅';
    _destinationController.text = '羽田空港';
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _pickupLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF093FB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Color(0xFFF093FB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI音声配車システム',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 入力フォーム
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              labelText: '顧客名',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _customerPhoneController,
                            decoration: const InputDecoration(
                              labelText: '電話番号',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pickupLocationController,
                            decoration: const InputDecoration(
                              labelText: '乗車地点',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            decoration: const InputDecoration(
                              labelText: '目的地',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // ボタン
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: appState.isLoading 
                            ? null 
                            : () => _createVoiceDispatch(context, appState),
                        icon: appState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.call),
                        label: Text(appState.isLoading ? '配車中...' : '音声配車テスト'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF093FB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDispatchStatus(context),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('状況確認'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // システム説明
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'AI音声システムが顧客に自動で電話をかけ、配車確認を行います。',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createVoiceDispatch(BuildContext context, AppStateProvider appState) async {
    if (_customerNameController.text.isEmpty ||
        _customerPhoneController.text.isEmpty ||
        _pickupLocationController.text.isEmpty ||
        _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべての項目を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await appState.createVoiceDispatch(
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      pickupLocation: _pickupLocationController.text,
      destination: _destinationController.text,
    );

    if (result != null && result['success'] == true) {
      _showDispatchResult(context, result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音声配車の作成に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDispatchResult(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('配車リクエスト作成完了'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('配車ID: ${result['dispatchId'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('通話ID: ${result['callSid'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('ステータス: ${result['status'] ?? 'N/A'}'),
            const SizedBox(height: 12),
            const Text(
              'AI音声システムが顧客に電話をかけています...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDispatchStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配車状況'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• AI音声配車システム: 稼働中'),
            SizedBox(height: 8),
            Text('• 待機中のドライバー: 25人'),
            SizedBox(height: 8),
            Text('• 平均応答時間: 2.3秒'),
            SizedBox(height: 8),
            Text('• 配車成功率: 98.5%'),
            SizedBox(height: 12),
            Text(
              'システムは正常に動作しています。',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}