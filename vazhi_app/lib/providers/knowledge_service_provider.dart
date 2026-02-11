/// Knowledge Service Provider
///
/// Riverpod provider for the unified knowledge retrieval service.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/retrieval/knowledge_service.dart';
import '../services/query_router.dart';
import '../services/retrieval/thirukkural_service.dart';
import '../services/retrieval/scheme_service.dart';
import '../services/retrieval/emergency_service.dart';
import '../services/retrieval/healthcare_service.dart';

/// Individual service providers (for direct access if needed)
final thirukkuralServiceProvider = Provider<ThirukkuralService>((ref) {
  return ThirukkuralService();
});

final schemeServiceProvider = Provider<SchemeService>((ref) {
  return SchemeService();
});

final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService();
});

final healthcareServiceProvider = Provider<HealthcareService>((ref) {
  return HealthcareService();
});

/// Main knowledge service provider (singleton)
final knowledgeServiceProvider = Provider<KnowledgeService>((ref) {
  return KnowledgeService(
    router: QueryRouter(),
    thirukkuralService: ref.watch(thirukkuralServiceProvider),
    schemeService: ref.watch(schemeServiceProvider),
    emergencyService: ref.watch(emergencyServiceProvider),
    healthcareService: ref.watch(healthcareServiceProvider),
  );
});

/// Query response provider (for individual queries)
final knowledgeQueryProvider = FutureProvider.family<KnowledgeResponse, String>(
  (ref, query) async {
    final service = ref.watch(knowledgeServiceProvider);
    return service.query(query);
  },
);

/// Knowledge database ready state
final knowledgeReadyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(knowledgeServiceProvider);
  return service.isReady();
});

/// Knowledge database statistics
final knowledgeStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(knowledgeServiceProvider);
  return service.getStats();
});
