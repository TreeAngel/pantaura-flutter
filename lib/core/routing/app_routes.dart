class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String map = '/map';
  static const String createReport = '/report/create';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String incidentDetailPath = '/incidents/:id';
  static const String incidentAddReportPath = '/incidents/:id/report';
  static const String incidentRecoveredPath = '/incidents/:id/recovered';

  static String incidentDetail(String id) => '/incidents/$id';
  static String incidentAddReport(String id) => '/incidents/$id/report';
  static String incidentRecovered(String id) => '/incidents/$id/recovered';
}
