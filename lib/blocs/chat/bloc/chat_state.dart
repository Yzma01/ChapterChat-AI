import 'package:equatable/equatable.dart';
import '../../../models/chat_message.dart';
import '../../../models/chat_character.dart';

/// Enum for chat status
enum ChatStatus {
  initial,
  loading,
  loaded,
  sending,
  waitingResponse,
  error,
  rateLimited,
}

/// State class for chat BLoC
class ChatState extends Equatable {
  final ChatStatus status;
  final ChatCharacter? character;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final bool isTyping;
  final bool isRateLimited;
  final int rateLimitSeconds;

  const ChatState({
    this.status = ChatStatus.initial,
    this.character,
    this.messages = const [],
    this.errorMessage,
    this.isTyping = false,
    this.isRateLimited = false,
    this.rateLimitSeconds = 0,
  });

  /// Initial state
  factory ChatState.initial() => const ChatState();

  /// Loading messages state
  factory ChatState.loading(ChatCharacter character) =>
      ChatState(status: ChatStatus.loading, character: character);

  /// Create a copy with updated values
  ChatState copyWith({
    ChatStatus? status,
    ChatCharacter? character,
    List<ChatMessage>? messages,
    String? errorMessage,
    bool? isTyping,
    bool? isRateLimited,
    int? rateLimitSeconds,
  }) {
    return ChatState(
      status: status ?? this.status,
      character: character ?? this.character,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      isTyping: isTyping ?? this.isTyping,
      isRateLimited: isRateLimited ?? this.isRateLimited,
      rateLimitSeconds: rateLimitSeconds ?? this.rateLimitSeconds,
    );
  }

  /// Check if we can send messages
  bool get canSendMessage =>
      status != ChatStatus.sending &&
      status != ChatStatus.waitingResponse &&
      !isRateLimited;

  /// Get input hint text based on state
  String getInputHint() {
    if (isRateLimited) {
      return 'Wait $rateLimitSeconds seconds...';
    }
    if (status == ChatStatus.waitingResponse) {
      return '${character?.name ?? 'Character'} is typing...';
    }
    return 'Text message';
  }

  @override
  List<Object?> get props => [
    status,
    character?.id,
    messages,
    errorMessage,
    isTyping,
    isRateLimited,
    rateLimitSeconds,
  ];
}
