import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/app_state_provider.dart';

class DriverAppScreen extends StatefulWidget {
  const DriverAppScreen({super.key});

  @override
  State<DriverAppScreen> createState() => _DriverAppScreenState();
}

class _DriverAppScreenState extends State<DriverAppScreen> {
  String _driverStatus = 'offline'; // offline, available, busy
  Position? _currentLocation;
  Map<String, dynamic>? _currentRide;
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLocationUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeDriver();
  }

  Future<void> _initializeDriver() async {
    await _getCurrentLocation();
    _loadPendingRequests();
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
      });

      // 位置情報を定期的に更新
      if (_driverStatus == 'available') {
        _startLocationUpdates();
      }
    } catch (e) {
      print('位置情報取得エラー: $e');
    }
  }

  void _startLocationUpdates() {
    if (_isLocationUpdating) return;
    
    setState(() {
      _isLocationUpdating = true;
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      setState(() {
        _currentLocation = position;
      });
      _updateLocationToServer(position);
    });
  }

  Future<void> _updateLocationToServer(Position position) async {
    try {
      // サーバーに位置情報を送信
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      // await appState.updateDriverLocation(
      //   driverId: 'driver_001',
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      //   heading: position.heading,
      //   speed: position.speed,
      //   accuracy: position.accuracy,
      // );
    } catch (e) {
      print('位置情報更新エラー: $e');
    }
  }

  void _loadPendingRequests() {
    // サンプルデータ
    setState(() {
      _pendingRequests = [
        {
          'id': 'req_001',
          'customer_name': '田中太郎',
          'pickup_location': '新宿駅東口',
          'destination': '渋谷駅',
          'distance': '5.2km',
          'estimated_fare': '1,850円',
          'estimated_duration': '15分',
          'pickup_time': '14:45',
        },
        {
          'id': 'req_002',
          'customer_name': '佐藤花子',
          'pickup_location': '池袋駅西口',
          'destination': '上野駅',
          'distance': '7.8km',
          'estimated_fare': '2,340円',
          'estimated_duration': '22分',
          'pickup_time': '15:00',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('🚗 ドライバーアプリ'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildStatusIndicator(),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _showDriverProfile();
              } else if (value == 'earnings') {
                _showEarnings();
              } else if (value == 'settings') {
                _showSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('プロフィール'),
              ),
              const PopupMenuItem(
                value: 'earnings',
                child: Text('収入詳細'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('設定'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ドライバーステータス
            _buildDriverStatus(),
            
            const SizedBox(height: 16),
            
            // 現在の乗車情報
            if (_currentRide != null)
              _buildCurrentRide(),
            
            // 配車リクエスト一覧
            if (_driverStatus == 'available' && _currentRide == null)
              _buildPendingRequests(),
            
            // 本日の収入サマリー
            _buildEarningsSummary(),
            
            const SizedBox(height: 16),
            
            // アクションボタン
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;
    
    switch (_driverStatus) {
      case 'available':
        statusColor = Colors.green;
        statusText = '営業中';
        break;
      case 'busy':
        statusColor = Colors.orange;
        statusText = '乗車中';
        break;
      default:
        statusColor = Colors.red;
        statusText = 'オフライン';
    }

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDriverStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ドライバーステータス',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    'オフライン',
                    'offline',
                    Colors.grey,
                    Icons.power_settings_new,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusButton(
                    '営業中',
                    'available',
                    Colors.green,
                    Icons.local_taxi,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusButton(
                    '乗車中',
                    'busy',
                    Colors.orange,
                    Icons.person,
                  ),
                ),
              ],
            ),
            
            if (_currentLocation != null) ...[
              const SizedBox(height: 16),
              Text(
                '現在地: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '精度: ${_currentLocation!.accuracy.toStringAsFixed(1)}m',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String status, Color color, IconData icon) {
    final isSelected = _driverStatus == status;
    
    return ElevatedButton(
      onPressed: () => _updateDriverStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRide() {
    final ride = _currentRide!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '現在の乗車',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text('お客様: ${ride['customer_name']}'),
            Text('お迎え: ${ride['pickup_location']}'),
            Text('目的地: ${ride['destination']}'),
            Text('予想料金: ${ride['estimated_fare']}'),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _completeRide(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('完了', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _callCustomer(ride['customer_phone']),
                    child: const Text('お客様に電話'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '配車リクエスト',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_pendingRequests.isEmpty)
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
              ..._pendingRequests.map((request) => _buildRequestCard(request)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                request['customer_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                request['pickup_time'],
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Expanded(child: Text(request['pickup_location'])),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              const Icon(Icons.flag, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Expanded(child: Text(request['destination'])),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${request['distance']} • ${request['estimated_duration']}'),
              Text(
                request['estimated_fare'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                  ),
                  child: const Text('受諾', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineRequest(request['id']),
                  child: const Text('辞退'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本日の収入',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildEarningMetric('総売上', '¥23,450'),
                ),
                Expanded(
                  child: _buildEarningMetric('乗車回数', '12回'),
                ),
                Expanded(
                  child: _buildEarningMetric('稼働時間', '8.5h'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showNavigation(),
                icon: const Icon(Icons.navigation),
                label: const Text('ナビゲーション'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showSupport(),
                icon: const Icon(Icons.support_agent),
                label: const Text('サポート'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showReports(),
                icon: const Icon(Icons.assessment),
                label: const Text('レポート'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _emergencyCall(),
                icon: const Icon(Icons.emergency, color: Colors.red),
                label: const Text('緊急連絡'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateDriverStatus(String status) {
    setState(() {
      _driverStatus = status;
    });

    if (status == 'available') {
      _startLocationUpdates();
    } else {
      setState(() {
        _isLocationUpdating = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ステータスを「${_getStatusText(status)}」に変更しました'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return '営業中';
      case 'busy':
        return '乗車中';
      default:
        return 'オフライン';
    }
  }

  void _acceptRequest(Map<String, dynamic> request) {
    setState(() {
      _currentRide = request;
      _driverStatus = 'busy';
      _pendingRequests.removeWhere((r) => r['id'] == request['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['customer_name']}様の配車を受諾しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _declineRequest(String requestId) {
    setState(() {
      _pendingRequests.removeWhere((r) => r['id'] == requestId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('配車リクエストを辞退しました'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _completeRide() {
    final ride = _currentRide!;
    
    setState(() {
      _currentRide = null;
      _driverStatus = 'available';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ride['customer_name']}様の乗車が完了しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _callCustomer(String? phoneNumber) {
    if (phoneNumber != null) {
      // 電話アプリを起動
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$phoneNumber に発信しています...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showDriverProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ドライバープロフィール'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('氏名: 田中太郎'),
            Text('免許番号: 123456789012'),
            Text('車両: トヨタ プリウス'),
            Text('ナンバー: 品川500あ12-34'),
            Text('評価: ⭐⭐⭐⭐⭐ 4.8'),
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

  void _showEarnings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('収入詳細'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日: ¥23,450'),
            Text('今週: ¥145,230'),
            Text('今月: ¥523,780'),
            Text('総収入: ¥2,345,600'),
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

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('設定'),
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('通知設定'),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('位置情報設定'),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text('プライバシー'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Maps アプリに切り替えています...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('サポート'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('サポートデスク: 0120-123-456'),
            Text('営業時間: 24時間365日'),
            Text('メール: support@mobility360.jp'),
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

  void _showReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('レポート'),
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('収入レポート機能（実装予定）'),
          ),
        ),
      ),
    );
  }

  void _emergencyCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('緊急連絡'),
          ],
        ),
        content: const Text('警察（110）に連絡しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('110番に発信しています...'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('発信', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}