import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const productionBaseUrl = 'https://anabool.vercel.app';
  static const localBaseUrl = 'http://127.0.0.1:8000';
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:8000';

  static const _configuredBaseUrl = String.fromEnvironment(
    'ANABOOL_API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }

    return localBaseUrl;
  }
}