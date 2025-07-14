import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/app_state_provider.dart';

class CustomerDispatchScreen extends StatefulWidget {
  const CustomerDispatchScreen({super.key});

  @override
  State<CustomerDispatchScreen> createState() => _CustomerDispatchScreenState();
}

class _CustomerDispatchScreenState extends State<CustomerDispatchScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  
  String _selectedVehicleType = 'standard';
  bool _isLoading = false;
  Position? _currentLocation;
  Map<String, dynamic>? _currentDispatch;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentLocation = position;
        _pickupController.text = '現在地 (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})';
      });
    } catch (e) {
      print('位置情報取得エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('🚖 配車依頼'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showDispatchHistory(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在の配車状況
            if (_currentDispatch != null)
              _buildCurrentDispatch(),
            
            // 配車依頼フォーム
            _buildDispatchForm(),
            
            const SizedBox(height: 24),
            
            // 料金目安
            _buildFareEstimate(),
            
            const SizedBox(height: 24),
            
            // 配車依頼ボタン
            _buildDispatchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDispatch() {
    final dispatch = _currentDispatch!;
    final status = dispatch['status'];
    final statusColor = status == 'confirmed' ? Colors.green : 
                       status == 'in_progress' ? Colors.blue : Colors.orange;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.taxi_alert, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  '配車状況',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text('配車ID: ${dispatch['id']}'),
            const SizedBox(height: 8),
            
            if (dispatch['driver_name'] != null) ...[
              Text('ドライバー: ${dispatch['driver_name']}'),
              Text('車両: ${dispatch['vehicle_model']}'),
              Text('ナンバー: ${dispatch['vehicle_plate']}'),
              const SizedBox(height: 8),
            ],
            
            Text('お迎え場所: ${dispatch['pickup_location']}'),
            Text('目的地: ${dispatch['destination']}'),
            Text('到着予定: ${dispatch['estimated_arrival']}分'),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _cancelDispatch(dispatch['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('キャンセル', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _trackDispatch(dispatch['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('追跡', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
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
              '配車依頼',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'お名前',
                hintText: '例：田中太郎',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                hintText: '例：090-1234-5678',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _pickupController,
              decoration: InputDecoration(
                labelText: 'お迎え場所',
                hintText: '現在地または住所を入力',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: '目的地',
                hintText: '例：東京駅',
                prefixIcon: Icon(Icons.flag),
              ),
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
                DropdownMenuItem(value: 'large', child: Text('大型車')),
                DropdownMenuItem(value: 'wheelchair', child: Text('車椅子対応')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareEstimate() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '料金目安',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('初乗り料金'),
                Text('¥${_getBaseFare()}'),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('距離料金'),
                Text('¥${_getDistanceFare()}'),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('時間料金'),
                Text('¥${_getTimeFare()}'),
              ],
            ),
            
            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合計目安',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥${_getTotalFare()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _requestDispatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                '配車を依頼する',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _requestDispatch() async {
    if (_nameController.text.isEmpty || 
        _phoneController.text.isEmpty ||
        _pickupController.text.isEmpty ||
        _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべての項目を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final result = await appState.createVoiceDispatch(
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        pickupLocation: _pickupController.text,
        destination: _destinationController.text,
        vehicleType: _selectedVehicleType,
      );

      if (result != null) {
        setState(() {
          _currentDispatch = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配車依頼を送信しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('配車依頼エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getBaseFare() {
    switch (_selectedVehicleType) {
      case 'premium':
        return '500';
      case 'large':
        return '600';
      case 'wheelchair':
        return '400';
      default:
        return '420';
    }
  }

  String _getDistanceFare() {
    return '300';
  }

  String _getTimeFare() {
    return '200';
  }

  String _getTotalFare() {
    final base = int.parse(_getBaseFare());
    final distance = int.parse(_getDistanceFare());
    final time = int.parse(_getTimeFare());
    return (base + distance + time).toString();
  }

  Future<void> _cancelDispatch(String dispatchId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配車キャンセル'),
        content: const Text('配車をキャンセルしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('はい'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _currentDispatch = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配車をキャンセルしました'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _trackDispatch(String dispatchId) {
    // 配車追跡画面へ遷移
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('配車追跡'),
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('リアルタイム追跡機能（実装予定）'),
          ),
        ),
      ),
    );
  }

  void _showDispatchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配車履歴'),
        content: const SingleChildScrollView(
          child: Column(
            children: [
              Text('2024-01-10 14:30 - 新宿駅→渋谷駅'),
              Text('2024-01-09 09:15 - 自宅→羽田空港'),
              Text('2024-01-08 18:45 - 会社→品川駅'),
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