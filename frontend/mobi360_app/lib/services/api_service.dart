import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static Duration get timeout => AppConfig.requestTimeout;

  final http.Client _client = http.Client();
  String? _authToken;

  /// ヘルスチェックを実行
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/../health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('ヘルスチェック失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ヘルスチェックエラー: $e');
    }
  }

  /// ドライバー検索
  Future<Map<String, dynamic>> searchDrivers({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String? vehicleType,
  }) async {
    try {
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        if (vehicleType != null) 'vehicle_type': vehicleType,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/driver-pool/search'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('ドライバー検索失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ドライバー検索エラー: $e');
    }
  }

  /// ドライバーマッチング
  Future<Map<String, dynamic>> matchDriver({
    required Map<String, dynamic> dispatchRequest,
    required List<Map<String, dynamic>> availableDrivers,
  }) async {
    try {
      final body = {
        'dispatch_request': dispatchRequest,
        'available_drivers': availableDrivers,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/driver-pool/match'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('ドライバーマッチング失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ドライバーマッチングエラー: $e');
    }
  }

  /// AI音声配車リクエスト作成
  Future<Map<String, dynamic>> createVoiceDispatch({
    required String customerName,
    required String customerPhone,
    required String pickupLocation,
    required String destination,
    String vehicleType = 'standard',
  }) async {
    try {
      final body = {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'pickupLocation': pickupLocation,
        'destination': destination,
        'vehicleType': vehicleType,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/voice-dispatch/create'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('音声配車作成失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('音声配車作成エラー: $e');
    }
  }

  /// 配車ステータス取得
  Future<Map<String, dynamic>> getDispatchStatus(String dispatchId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/voice-dispatch/$dispatchId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('配車ステータス取得失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('配車ステータス取得エラー: $e');
    }
  }

  /// ドライバー位置更新
  Future<Map<String, dynamic>> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    double? accuracy,
  }) async {
    try {
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        if (accuracy != null) 'accuracy': accuracy,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/driver-pool/$driverId/location'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('位置更新失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('位置更新エラー: $e');
    }
  }

  /// ドライバーステータス更新
  Future<Map<String, dynamic>> updateDriverStatus({
    required String driverId,
    required String status, // 'available', 'busy', 'offline'
  }) async {
    try {
      final body = {'status': status};

      final response = await _client
          .post(
            Uri.parse('$baseUrl/driver-pool/$driverId/status'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('ステータス更新失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ステータス更新エラー: $e');
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
      final body = {
        'companyName': companyName,
        'companyAddress': companyAddress,
        'companyPhone': companyPhone,
        'licenseNumber': licenseNumber,
        'representativeName': representativeName,
        'representativeEmail': representativeEmail,
        'serviceArea': serviceArea,
        'vehicleCount': vehicleCount,
        'driverCount': driverCount,
        'selectedPlan': selectedPlan,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/register/company'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('会社登録失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('会社登録エラー: $e');
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
      final body = {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'birthdate': birthdate,
        'licenseNumber': licenseNumber,
        'licenseExpiry': licenseExpiry,
        'taxiLicenseNumber': taxiLicenseNumber,
        'hasOwnVehicle': hasOwnVehicle,
        'isFullTime': isFullTime,
        'workingArea': workingArea,
        'vehicleModel': vehicleModel,
        'vehicleYear': vehicleYear,
        'vehiclePlate': vehiclePlate,
        'insuranceNumber': insuranceNumber,
        'bankName': bankName,
        'branchName': branchName,
        'accountNumber': accountNumber,
        'accountHolder': accountHolder,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/register/driver'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('ドライバー登録失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ドライバー登録エラー: $e');
    }
  }

  /// ダッシュボード統計データを取得
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/dashboard/stats'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('ダッシュボード統計取得失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ダッシュボード統計取得エラー: $e');
    }
  }

  /// 最近の登録データを取得
  Future<Map<String, dynamic>> fetchRecentRegistrations() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/api/dashboard/recent-registrations'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('最近の登録データ取得失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('最近の登録データ取得エラー: $e');
    }
  }

  /// ログイン
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'userType': userType,
      };

      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'メールアドレスまたはパスワードが違います',
        };
      } else {
        throw Exception('ログイン失敗: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ログインエラー: $e');
    }
  }

  /// 認証トークンを設定
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// 認証トークンをクリア
  void clearAuthToken() {
    _authToken = null;
  }

  /// 認証ヘッダーを含むヘッダーを生成
  Map<String, String> _getAuthHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// リソースをクリーンアップ
  void dispose() {
    _client.close();
  }
}