import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network/api_client.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'services/report_service.dart';
import 'services/safe_zone_service.dart';
import 'services/watch_area_service.dart';

// Token Provider
final tokenProviderInstance = Provider<TokenProvider>((ref) {
  return InMemoryTokenProvider();
});

// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenProvider = ref.watch(tokenProviderInstance);
  return ApiClient(tokenProvider: tokenProvider);
});

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final incidentServiceProvider = Provider<IncidentService>((ref) {
  return IncidentService(ref.watch(apiClientProvider));
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(apiClientProvider));
});

final safeZoneServiceProvider = Provider<SafeZoneService>((ref) {
  return SafeZoneService(ref.watch(apiClientProvider));
});

final watchAreaServiceProvider = Provider<WatchAreaService>((ref) {
  return WatchAreaService(ref.watch(apiClientProvider));
});
