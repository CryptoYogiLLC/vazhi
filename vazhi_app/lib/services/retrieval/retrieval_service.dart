/// Base Retrieval Service
///
/// Abstract base class for deterministic data retrieval services.
/// Each knowledge pack implements this interface for consistent API.

import '../../models/query_result.dart';

/// Result of a retrieval operation
class RetrievalResult<T> {
  /// The retrieved data (null if not found)
  final T? data;

  /// List of results (for search/browse operations)
  final List<T> results;

  /// Whether the operation was successful
  final bool success;

  /// Error message if operation failed
  final String? errorMessage;

  /// Display title for the result
  final String? displayTitle;

  /// Formatted response text for display
  final String? formattedResponse;

  /// Source category
  final KnowledgeCategory category;

  /// Whether more results are available
  final bool hasMore;

  /// Total count (for paginated results)
  final int? totalCount;

  const RetrievalResult({
    this.data,
    this.results = const [],
    this.success = true,
    this.errorMessage,
    this.displayTitle,
    this.formattedResponse,
    required this.category,
    this.hasMore = false,
    this.totalCount,
  });

  /// Create a success result with single item
  factory RetrievalResult.found(T item, {
    required KnowledgeCategory category,
    String? displayTitle,
    String? formattedResponse,
  }) {
    return RetrievalResult(
      data: item,
      results: [item],
      success: true,
      category: category,
      displayTitle: displayTitle,
      formattedResponse: formattedResponse,
    );
  }

  /// Create a success result with multiple items
  factory RetrievalResult.list(List<T> items, {
    required KnowledgeCategory category,
    String? displayTitle,
    String? formattedResponse,
    bool hasMore = false,
    int? totalCount,
  }) {
    return RetrievalResult(
      data: items.isNotEmpty ? items.first : null,
      results: items,
      success: true,
      category: category,
      displayTitle: displayTitle,
      formattedResponse: formattedResponse,
      hasMore: hasMore,
      totalCount: totalCount ?? items.length,
    );
  }

  /// Create a not found result
  factory RetrievalResult.notFound({
    required KnowledgeCategory category,
    String? message,
  }) {
    return RetrievalResult(
      success: false,
      errorMessage: message ?? 'தகவல் கிடைக்கவில்லை (Data not found)',
      category: category,
    );
  }

  /// Create an error result
  factory RetrievalResult.error(String message, {
    required KnowledgeCategory category,
  }) {
    return RetrievalResult(
      success: false,
      errorMessage: message,
      category: category,
    );
  }

  /// Check if result has data
  bool get hasData => data != null || results.isNotEmpty;

  /// Get the first result
  T? get first => data ?? (results.isNotEmpty ? results.first : null);

  /// Check if this is a single item result
  bool get isSingleResult => results.length == 1;

  /// Check if this is a list result
  bool get isListResult => results.length > 1;
}

/// Base abstract class for retrieval services
abstract class RetrievalService {
  /// The knowledge category this service handles
  KnowledgeCategory get category;

  /// Search within this knowledge pack
  Future<RetrievalResult<dynamic>> search(String query, {int limit = 20});

  /// Get a formatted response for display
  String formatForDisplay(dynamic item);

  /// Check if this service can handle the given query
  bool canHandle(QueryClassification classification) {
    return classification.category == category;
  }
}
