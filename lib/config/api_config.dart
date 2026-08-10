/// API configuration — switch between local dev and production here.
class ApiConfig {
  ApiConfig._();

  /// Railway production URL
  static const String baseUrl = 'https://rfwbackend-production.up.railway.app';

  // Local development (Android emulator):
  // static const String baseUrl = 'http://10.0.2.2:3000';
}
