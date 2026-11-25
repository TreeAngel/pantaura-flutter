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

  static String incidentDetail(String id) => '/incidents/$id';
}
