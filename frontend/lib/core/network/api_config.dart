class ApiConfig {
  const ApiConfig._();

  static const productionBaseUrl = 'https://anabool.vercel.app';

  static const _configuredBaseUrl = String.fromEnvironment(
    'ANABOOL_API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    return productionBaseUrl;
  }
}
