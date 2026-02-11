/// Chat Message Model
///
/// Represents a single message in a conversation.

enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final String? pack; // Which knowledge pack was used
  final bool isLoading;
  final String? error;

  Message({
    required this.id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.pack,
    this.isLoading = false,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a user message
  factory Message.user(String content) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
    );
  }

  /// Create an assistant message
  factory Message.assistant(String content, {String? pack}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      pack: pack,
    );
  }

  /// Create a loading placeholder
  factory Message.loading() {
    return Message(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      role: MessageRole.assistant,
      isLoading: true,
    );
  }

  /// Create an error message
  factory Message.error(String errorMessage) {
    return Message(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      role: MessageRole.assistant,
      error: errorMessage,
    );
  }

  /// Copy with modifications
  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    String? pack,
    bool? isLoading,
    String? error,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      pack: pack ?? this.pack,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'pack': pack,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MessageRole.assistant,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      pack: json['pack'] as String?,
    );
  }
}
