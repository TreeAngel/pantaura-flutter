/// API Configuration for Pantaura REST API
class ApiConfig {
  ApiConfig._();

  /// Production Base URL
  static const String baseUrl = 'https://pantaura.mizaru.my.id/api/v1';

  /// Connect & Receive timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoint paths
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Incidents
  static const String incidents = '/incidents';
  static const String incidentMap = '/incidents/map';
  static const String incidentNearby = '/incidents/nearby';
  static String incidentDetail(String id) => '/incidents/$id';
  static String incidentConfirm(String id) => '/incidents/$id/confirm';
  static String incidentReports(String id) => '/incidents/$id/reports';
  static String incidentResolutions(String id) => '/incidents/$id/resolutions';

  // Reports
  static const String reports = '/reports';
  static const String myReports = '/reports/my';

  // Safe Zones
  static const String safeZones = '/safe-zones';

  // Watch Areas
  static const String watchAreas = '/watch-areas';
  static String watchAreaDelete(String id) => '/watch-areas/$id';

  // Alerts
  static const String alerts = '/alerts';
  static String alertRead(String id) => '/alerts/$id/read';
}
