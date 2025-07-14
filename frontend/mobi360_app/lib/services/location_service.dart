import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const int _locationUpdateInterval = 5; // 5秒間隔
  static const int _minDistanceFilter = 10; // 10メートル以上移動で更新

  StreamController<Position>? _positionController;
  StreamSubscription<Position>? _positionSubscription;

  Stream<Position> get positionStream {
    _positionController ??= StreamController<Position>.broadcast();
    return _positionController!.stream;
  }

  /// 位置情報権限をリクエスト
  Future<bool> requestLocationPermission() async {
    try {
      // 位置情報サービスが有効かチェック
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // 権限をチェック
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('位置情報権限リクエストエラー: $e');
      return false;
    }
  }

  /// 現在の位置情報を取得
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('現在位置取得エラー: $e');
      return null;
    }
  }

  /// リアルタイム位置追跡を開始
  Future<void> startLocationTracking() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('位置情報権限が許可されていません');
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _minDistanceFilter,
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _positionController?.add(position);
        },
        onError: (error) {
          print('位置情報ストリームエラー: $error');
        },
      );
    } catch (e) {
      print('位置追跡開始エラー: $e');
      rethrow;
    }
  }

  /// 位置追跡を停止
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// 2つの位置間の距離を計算（メートル）
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// リソースをクリーンアップ
  void dispose() {
    stopLocationTracking();
    _positionController?.close();
    _positionController = null;
  }
}