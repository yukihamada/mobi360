import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class VoiceDispatchScreen extends StatefulWidget {
  const VoiceDispatchScreen({super.key});

  @override
  State<VoiceDispatchScreen> createState() => _VoiceDispatchScreenState();
}

class _VoiceDispatchScreenState extends State<VoiceDispatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  
  String _selectedVehicleType = 'standard';
  bool _isLoading = false;
  List<Map<String, dynamic>> _recentDispatches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentDispatches();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _pickupLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentDispatches() async {
    // 最近の配車リクエスト一覧を取得（今回は模擬データ）
    setState(() {
      _recentDispatches = [
        {
          'id': 'dispatch_001',
          'customer_name': '田中太郎',
          'pickup_location': '新宿駅',
          'destination': '渋谷駅',
          'status': 'confirmed',
          'created_at': '2024-01-10 14:30:00',
          'driver_name': '佐藤ドライバー',
        },
        {
          'id': 'dispatch_002',
          'customer_name': '山田花子',
          'pickup_location': '東京駅',
          'destination': '品川駅',
          'status': 'pending',
          'created_at': '2024-01-10 14:45:00',
          'driver_name': null,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('🎤 AI音声配車システム'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecentDispatches,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 配車リクエスト作成フォーム
              _buildDispatchForm(),
              
              const SizedBox(height: 24),
              
              // 音声配車デモ
              _buildVoiceDemo(),
              
              const SizedBox(height: 24),
              
              // 最近の配車リクエスト
              _buildRecentDispatches(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDispatchForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新規配車リクエスト',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'お客様名',
                      hintText: '例：田中太郎',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'お客様名を入力してください';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _customerPhoneController,
                    decoration: const InputDecoration(
                      labelText: '電話番号',
                      hintText: '例：090-1234-5678',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '電話番号を入力してください';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _pickupLocationController,
                    decoration: const InputDecoration(
                      labelText: 'お迎え場所',
                      hintText: '例：新宿駅東口',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'お迎え場所を入力してください';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: '目的地',
                      hintText: '例：渋谷駅',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '目的地を入力してください';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    decoration: const InputDecoration(
                      labelText: '車両タイプ',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'standard', child: Text('スタンダード')),
                      DropdownMenuItem(value: 'premium', child: Text('プレミアム')),
                      DropdownMenuItem(value: 'wheelchair', child: Text('車椅子対応')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleType = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createVoiceDispatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'AI音声配車を開始',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
  }

  Widget _buildVoiceDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎤 音声配車デモ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '音声応答シミュレーション',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  _buildConversationBubble(
                    'AI', 
                    'こんにちは、Mobility Ops 360のAI音声配車システムです。新宿駅から渋谷駅への配車をご依頼いただき、ありがとうございます。',
                    isAI: true,
                  ),
                  
                  _buildConversationBubble(
                    'お客様', 
                    '何分くらいで来ますか？',
                    isAI: false,
                  ),
                  
                  _buildConversationBubble(
                    'AI', 
                    '到着予定時刻は約10分後となります。担当ドライバーは佐藤です。車両はトヨタプリウス、ナンバープレートは品川500あ12-34です。',
                    isAI: true,
                  ),
                  
                  _buildConversationBubble(
                    'お客様', 
                    'はい、お願いします。',
                    isAI: false,
                  ),
                  
                  _buildConversationBubble(
                    'AI', 
                    'ありがとうございます。配車を確定いたします。佐藤ドライバーが約10分後にお迎えにあがります。お待ちください。',
                    isAI: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TwiMLテスト機能
                      _showTwiMLTest();
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('TwiMLテスト'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 音声ログ表示
                      _showVoiceLogs();
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('音声ログ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationBubble(String speaker, String message, {required bool isAI}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isAI ? const Color(0xFF667EEA) : Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAI ? Icons.smart_toy : Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isAI ? const Color(0xFF667EEA) : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAI ? Colors.grey.shade100 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDispatches() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近の配車リクエスト',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_recentDispatches.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '配車リクエストがありません',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ..._recentDispatches.map((dispatch) => _buildDispatchCard(dispatch)),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard(Map<String, dynamic> dispatch) {
    final status = dispatch['status'];
    final statusColor = status == 'confirmed' ? Colors.green : 
                       status == 'pending' ? Colors.orange : Colors.red;
    final statusText = status == 'confirmed' ? '配車確定' : 
                       status == 'pending' ? '処理中' : 'キャンセル';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dispatch['customer_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(dispatch['pickup_location']),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 16),
              const Icon(Icons.flag, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(dispatch['destination']),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                dispatch['created_at'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (dispatch['driver_name'] != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  dispatch['driver_name'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createVoiceDispatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // AI音声配車リクエストを作成
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final result = await appState.createVoiceDispatch(
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        pickupLocation: _pickupLocationController.text,
        destination: _destinationController.text,
        vehicleType: _selectedVehicleType,
      );

      if (mounted) {
        if (result != null) {
          _showDispatchSuccess(result);
          _clearForm();
          _loadRecentDispatches(); // リストを更新
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI音声配車の作成に失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _customerNameController.clear();
    _customerPhoneController.clear();
    _pickupLocationController.clear();
    _destinationController.clear();
    setState(() {
      _selectedVehicleType = 'standard';
    });
  }

  void _showDispatchSuccess(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('AI音声配車開始'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('配車ID: ${result['dispatchId']}'),
            const SizedBox(height: 8),
            Text('推定到着時間: ${result['estimatedArrival']}分'),
            if (result['assignedDriver'] != null) ...[
              const SizedBox(height: 8),
              Text('担当ドライバー: ${result['assignedDriver']['name']}'),
              Text('車両: ${result['assignedDriver']['vehicleModel']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TwiMLテスト画面を表示
              _showTwiMLTest();
            },
            child: const Text('音声応答を確認'),
          ),
        ],
      ),
    );
  }

  void _showTwiMLTest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TwiML音声応答テスト'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TwiML応答例:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '<?xml version="1.0" encoding="UTF-8"?>\n'
                '<Response>\n'
                '  <Say voice="Polly.Mizuki" language="ja-JP">\n'
                '    こんにちは、田中太郎様。\n'
                '    新宿駅から渋谷駅への配車を\n'
                '    ご依頼いただき、ありがとうございます。\n'
                '  </Say>\n'
                '</Response>',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
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

  void _showVoiceLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('音声通話ログ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('最近の音声通話:'),
              SizedBox(height: 16),
              
              Text('14:30 - 090-1234-5678'),
              Text('応答: "新宿駅から渋谷駅"'),
              Text('ステータス: 配車確定'),
              
              Divider(),
              
              Text('14:45 - 080-9876-5432'),
              Text('応答: "東京駅から品川駅"'),
              Text('ステータス: 処理中'),
            ],
          ),
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