class AppConfig {
  static const String appName = 'Mobility Ops 360';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Mobility Ops 360 Team';
  static const String supportEmail = 'support@mobility360.jp';
  static const String privacyPolicyUrl = 'https://mobility360.jp/privacy';
  static const String termsOfServiceUrl = 'https://mobility360.jp/terms';
  
  // 環境別設定
  static const String _environment = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'development');
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.mobility360.jp';
      case 'staging':
        return 'https://staging-api.mobility360.jp';
      default:
        return 'http://localhost:56523';
    }
  }
  
  static String get webUrl {
    switch (_environment) {
      case 'production':
        return 'https://mobility360.jp';
      case 'staging':
        return 'https://staging.mobility360.jp';
      default:
        return 'http://localhost:8080';
    }
  }
  
  static bool get isProduction => _environment == 'production';
  static bool get isStaging => _environment == 'staging';
  static bool get isDevelopment => _environment == 'development';
  
  // 機能フラグ
  static bool get enableAnalytics => isProduction || isStaging;
  static bool get enableCrashReporting => isProduction || isStaging;
  static bool get enableDebugMode => isDevelopment;
  
  // API設定
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // 位置情報設定
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  static const double locationAccuracyThreshold = 100.0; // メートル
  
  // キャッシュ設定
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // ログ設定
  static String get logLevel {
    if (isProduction) return 'ERROR';
    if (isStaging) return 'WARNING';
    return 'DEBUG';
  }
}