/// Feedback Model
///
/// Represents user feedback on a model response.
library;


enum FeedbackType {
  positive,   // 👍 - Response was helpful
  negative,   // 👎 - Response was wrong/unhelpful
  correction, // ✏️ - User provided correct answer
}

class UserFeedback {
  final String id;
  final String messageId;
  final String question;        // Original user question
  final String modelResponse;   // What the model said
  final FeedbackType type;
  final String? correction;     // User's correction (if type == correction)
  final String? pack;           // Which knowledge pack was used
  final DateTime timestamp;
  final bool synced;            // Has been synced to backend

  UserFeedback({
    required this.id,
    required this.messageId,
    required this.question,
    required this.modelResponse,
    required this.type,
    this.correction,
    this.pack,
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create positive feedback
  factory UserFeedback.positive({
    required String messageId,
    required String question,
    required String modelResponse,
    String? pack,
  }) {
    return UserFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      type: FeedbackType.positive,
      pack: pack,
    );
  }

  /// Create negative feedback
  factory UserFeedback.negative({
    required String messageId,
    required String question,
    required String modelResponse,
    String? pack,
  }) {
    return UserFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      type: FeedbackType.negative,
      pack: pack,
    );
  }

  /// Create correction feedback
  factory UserFeedback.correction({
    required String messageId,
    required String question,
    required String modelResponse,
    required String correction,
    String? pack,
  }) {
    return UserFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      type: FeedbackType.correction,
      correction: correction,
      pack: pack,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'question': question,
      'modelResponse': modelResponse,
      'type': type.name,
      'correction': correction,
      'pack': pack,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced,
    };
  }

  /// Create from JSON
  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      question: json['question'] as String,
      modelResponse: json['modelResponse'] as String,
      type: FeedbackType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => FeedbackType.negative,
      ),
      correction: json['correction'] as String?,
      pack: json['pack'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  /// Convert to training format (Alpaca style)
  String toTrainingFormat() {
    if (type != FeedbackType.correction || correction == null) {
      return '';
    }
    return '''### Instruction:
$question

### Response:
$correction</s>''';
  }

  /// Mark as synced
  UserFeedback markSynced() {
    return UserFeedback(
      id: id,
      messageId: messageId,
      question: question,
      modelResponse: modelResponse,
      type: type,
      correction: correction,
      pack: pack,
      timestamp: timestamp,
      synced: true,
    );
  }
}
