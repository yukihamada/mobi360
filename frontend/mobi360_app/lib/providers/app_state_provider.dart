import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

enum ConnectionStatus { online, offline, connecting }

enum DriverStatus { available, busy, offline }

class AppStateProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();

  // 接続状態
  ConnectionStatus _connectionStatus = ConnectionStatus.offline;
  ConnectionStatus get connectionStatus => _connectionStatus;

  // 位置情報
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // ドライバー情報
  String? _driverId;
  String? get driverId => _driverId;

  DriverStatus _driverStatus = DriverStatus.offline;
  DriverStatus get driverStatus => _driverStatus;

  // KPIメトリクス
  double _costReduction = 75.0;
  double get costReduction => _costReduction;

  double _driverSufficiency = 95.0;
  double get driverSufficiency => _driverSufficiency;

  double _profitIncrease = 12.0;
  double get profitIncrease => _profitIncrease;

  double _systemUptime = 99.9;
  double get systemUptime => _systemUptime;

  // 近くのドライバー
  List<Map<String, dynamic>> _nearbyDrivers = [];
  List<Map<String, dynamic>> get nearbyDrivers => _nearbyDrivers;

  // エラー情報
  String? _lastError;
  String? get lastError => _lastError;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<Position>? _positionSubscription;

  AppStateProvider() {
    _initializeApp();
  }

  /// アプリを初期化
  Future<void> _initializeApp() async {
    _setLoading(true);
    await _checkConnection();
    await _initializeLocation();
    _setLoading(false);
  }

  /// 接続状態をチェック
  Future<void> _checkConnection() async {
    try {
      _connectionStatus = ConnectionStatus.connecting;
      notifyListeners();

      await _apiService.healthCheck();
      _connectionStatus = ConnectionStatus.online;
      _clearError();
    } catch (e) {
      _connectionStatus = ConnectionStatus.offline;
      _setError('サーバーとの接続に失敗しました');
    }
    notifyListeners();
  }

  /// 位置情報を初期化
  Future<void> _initializeLocation() async {
    try {
      // 現在位置を取得
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        _currentPosition = position;
        notifyListeners();

        // リアルタイム位置追跡を開始
        await _startLocationTracking();
      }
    } catch (e) {
      _setError('位置情報の取得に失敗しました: $e');
    }
  }

  /// リアルタイム位置追跡を開始
  Future<void> _startLocationTracking() async {
    try {
      await _locationService.startLocationTracking();
      
      _positionSubscription = _locationService.positionStream.listen(
        (Position position) {
          _currentPosition = position;
          notifyListeners();

          // ドライバーの場合は位置情報をサーバーに送信
          if (_driverId != null && _driverStatus != DriverStatus.offline) {
            _updateServerLocation(position);
          }
        },
        onError: (error) {
          _setError('位置追跡エラー: $error');
        },
      );
    } catch (e) {
      _setError('位置追跡の開始に失敗しました: $e');
    }
  }

  /// サーバーに位置情報を送信
  Future<void> _updateServerLocation(Position position) async {
    if (_driverId == null) return;

    try {
      await _apiService.updateDriverLocation(
        driverId: _driverId!,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
        accuracy: position.accuracy,
      );
    } catch (e) {
      // 位置更新の失敗は警告レベル（アプリの動作は継続）
      print('位置情報更新警告: $e');
    }
  }

  /// ドライバーIDを設定
  void setDriverId(String id) {
    _driverId = id;
    notifyListeners();
  }

  /// ドライバーステータスを更新
  Future<void> updateDriverStatus(DriverStatus status) async {
    if (_driverId == null) return;

    try {
      _setLoading(true);
      
      String statusString = status.toString().split('.').last;
      await _apiService.updateDriverStatus(
        driverId: _driverId!,
        status: statusString,
      );

      _driverStatus = status;
      _clearError();
    } catch (e) {
      _setError('ステータス更新に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 近くのドライバーを検索
  Future<void> searchNearbyDrivers({String? vehicleType}) async {
    if (_currentPosition == null) {
      _setError('現在位置が取得できていません');
      return;
    }

    try {
      _setLoading(true);
      
      final result = await _apiService.searchDrivers(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: 5.0,
        vehicleType: vehicleType,
      );

      if (result['success'] == true) {
        _nearbyDrivers = List<Map<String, dynamic>>.from(result['drivers'] ?? []);
        _clearError();
      } else {
        _setError('ドライバー検索に失敗しました');
      }
    } catch (e) {
      _setError('ドライバー検索エラー: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 会社登録
  Future<Map<String, dynamic>> registerCompany({
    required String companyName,
    required String companyAddress,
    required String companyPhone,
    required String licenseNumber,
    required String representativeName,
    required String representativeEmail,
    required String serviceArea,
    required String vehicleCount,
    required String driverCount,
    required String selectedPlan,
  }) async {
    try {
      _setLoading(true);
      
      final result = await _apiService.registerCompany(
        companyName: companyName,
        companyAddress: companyAddress,
        companyPhone: companyPhone,
        licenseNumber: licenseNumber,
        representativeName: representativeName,
        representativeEmail: representativeEmail,
        serviceArea: serviceArea,
        vehicleCount: vehicleCount,
        driverCount: driverCount,
        selectedPlan: selectedPlan,
      );

      _clearError();
      return result;
    } catch (e) {
      _setError('会社登録エラー: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  /// ドライバー登録
  Future<Map<String, dynamic>> registerDriver({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String birthdate,
    required String licenseNumber,
    required String licenseExpiry,
    required String taxiLicenseNumber,
    required bool hasOwnVehicle,
    required bool isFullTime,
    required String workingArea,
    required String vehicleModel,
    required String vehicleYear,
    required String vehiclePlate,
    required String insuranceNumber,
    required String bankName,
    required String branchName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    try {
      _setLoading(true);
      
      final result = await _apiService.registerDriver(
        name: name,
        phone: phone,
        email: email,
        address: address,
        birthdate: birthdate,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        taxiLicenseNumber: taxiLicenseNumber,
        hasOwnVehicle: hasOwnVehicle,
        isFullTime: isFullTime,
        workingArea: workingArea,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehiclePlate: vehiclePlate,
        insuranceNumber: insuranceNumber,
        bankName: bankName,
        branchName: branchName,
        accountNumber: accountNumber,
        accountHolder: accountHolder,
      );

      _clearError();
      return result;
    } catch (e) {
      _setError('ドライバー登録エラー: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  /// AI音声配車を作成
  Future<Map<String, dynamic>?> createVoiceDispatch({
    required String customerName,
    required String customerPhone,
    required String pickupLocation,
    required String destination,
    String vehicleType = 'standard',
  }) async {
    try {
      _setLoading(true);
      
      final result = await _apiService.createVoiceDispatch(
        customerName: customerName,
        customerPhone: customerPhone,
        pickupLocation: pickupLocation,
        destination: destination,
        vehicleType: vehicleType,
      );

      _clearError();
      return result;
    } catch (e) {
      _setError('音声配車作成エラー: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// ダッシュボード統計データを取得
  Future<Map<String, dynamic>?> fetchDashboardStats() async {
    try {
      _setLoading(true);
      
      final result = await _apiService.fetchDashboardStats();
      
      if (result['success'] == true) {
        final data = result['data'];
        // ローカル状態を更新
        _costReduction = data['costReduction']?.toDouble() ?? 75.0;
        _driverSufficiency = data['driverSufficiency']?.toDouble() ?? 95.0;
        _profitIncrease = data['profitIncrease']?.toDouble() ?? 12.0;
        _systemUptime = data['systemUptime']?.toDouble() ?? 99.9;
        
        _clearError();
        notifyListeners();
        return data;
      } else {
        _setError('統計データの取得に失敗しました');
        return null;
      }
    } catch (e) {
      _setError('統計データ取得エラー: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 最近の登録データを取得
  Future<Map<String, dynamic>?> fetchRecentRegistrations() async {
    try {
      _setLoading(true);
      
      final result = await _apiService.fetchRecentRegistrations();
      
      if (result['success'] == true) {
        _clearError();
        return result['data'];
      } else {
        _setError('最近の登録データの取得に失敗しました');
        return null;
      }
    } catch (e) {
      _setError('最近の登録データ取得エラー: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// データを更新
  Future<void> refreshData() async {
    await _checkConnection();
    if (_connectionStatus == ConnectionStatus.online) {
      await fetchDashboardStats();
      await searchNearbyDrivers();
    }
  }

  /// エラーをクリア
  void _clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// エラーを設定
  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  /// ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// エラーを手動でクリア
  void clearError() {
    _clearError();
  }

  /// ログイン処理
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      _setLoading(true);
      
      final result = await _apiService.login(
        email: email,
        password: password,
        userType: userType,
      );
      
      if (result['success'] == true) {
        // トークンを保存（今回は簡易的にメモリに保持）
        _apiService.setAuthToken(result['data']['token']);
        
        // ユーザー情報を保存
        final userData = result['data']['user'];
        if (userType == 'driver' && userData['id'] != null) {
          setDriverId(userData['id']);
        }
        
        _clearError();
      }
      
      return result;
    } catch (e) {
      _setError('ログインエラー: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  /// ログアウト処理
  Future<void> logout() async {
    _apiService.clearAuthToken();
    _driverId = null;
    _driverStatus = DriverStatus.offline;
    _nearbyDrivers = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _locationService.dispose();
    _apiService.dispose();
    super.dispose();
  }
}