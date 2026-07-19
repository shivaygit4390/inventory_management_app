abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://6a5c494564f700df5bd7e300.mockapi.io/api/v1',
  );

  static const String productsPath = 'products';
  static const Duration requestTimeout = Duration(seconds: 15);
}
