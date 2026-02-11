/// Query Router Provider
///
/// Riverpod provider for query classification and routing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/query_router.dart';
import '../models/query_result.dart';

/// Singleton QueryRouter instance
final queryRouterProvider = Provider<QueryRouter>((ref) {
  return QueryRouter();
});

/// Classify a query and get routing information
final queryClassificationProvider =
    FutureProvider.family<QueryClassification, String>((ref, query) async {
      final router = ref.watch(queryRouterProvider);
      return router.classify(query);
    });

/// Get routing statistics for debugging
final routingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final router = ref.watch(queryRouterProvider);
  return router.getRoutingStats();
});

/// Check if a query can be answered without the model
final canAnswerWithoutModelProvider = FutureProvider.family<bool, String>((
  ref,
  query,
) async {
  final classification = await ref.watch(
    queryClassificationProvider(query).future,
  );
  return classification.canAnswerWithoutModel;
});
