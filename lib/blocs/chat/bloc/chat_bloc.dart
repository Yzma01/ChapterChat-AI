import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/chat_message.dart';
import '../../../models/chat_character.dart';
import '../../../services/gemini_chat_service.dart';
import '../repository/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing chat functionality
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final GeminiChatService _chatService;

  ChatCharacter? _currentCharacter;
  Timer? _rateLimitTimer;

  ChatBloc({ChatRepository? repository, GeminiChatService? chatService})
    : _repository = repository ?? ChatRepository(),
      _chatService = chatService ?? GeminiChatService(),
      super(ChatState.initial()) {
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendTextMessage>(_onSendTextMessage);
    on<ChatSendImageMessage>(_onSendImageMessage);
    on<ChatReceiveResponse>(_onReceiveResponse);
    on<ChatResponseFailed>(_onResponseFailed);
    on<ChatRateLimited>(_onRateLimited);
    on<ChatResetConversation>(_onResetConversation);
    on<ChatDeleteMessage>(_onDeleteMessage);
    on<ChatUpdateRateLimitCountdown>(_onUpdateRateLimitCountdown);
    on<ChatRateLimitExpired>(_onRateLimitExpired);
    on<ClearLocalData>((event, emit) async {
      await _repository.clearLocalData();
      emit(ChatState.initial());
    });
  }

  @override
  Future<void> close() {
    _rateLimitTimer?.cancel();
    return super.close();
  }

  /// Load messages for a character
  Future<void> _onLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    _currentCharacter = event.character;

    emit(ChatState.loading(event.character));

    try {
      // Load existing messages from local storage
      final messages = await _repository.loadMessages(event.character.id);

      // If no messages, add welcome message
      if (messages.isEmpty) {
        final welcomeMessage = ChatMessage.text(
          id: 'welcome_${event.character.id}',
          text: "Hello! I'm ${event.character.name}. How can I help you today?",
          sender: MessageSender.character,
          timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
        );

        // Save welcome message
        await _repository.saveMessage(welcomeMessage, event.character.id);

        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            character: event.character,
            messages: [welcomeMessage],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            character: event.character,
            messages: messages,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          character: event.character,
          errorMessage: 'Failed to load messages: $e',
        ),
      );
    }
  }

  /// Send a text message
  Future<void> _onSendTextMessage(
    ChatSendTextMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentCharacter == null || !state.canSendMessage) return;

    final userMessage = ChatMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.text,
      sender: MessageSender.user,
    );

    // Add message to state and save
    final updatedMessages = [...state.messages, userMessage];
    await _repository.saveMessage(userMessage, _currentCharacter!.id);

    emit(
      state.copyWith(
        status: ChatStatus.waitingResponse,
        messages: updatedMessages,
        isTyping: true,
      ),
    );

    // Send to Gemini
    final result = await _chatService.sendTextMessage(
      character: _currentCharacter!,
      userMessage: event.text,
      conversationHistory: updatedMessages,
    );

    // Handle response
    if (result.isRateLimited) {
      add(ChatRateLimited(retryAfterSeconds: result.retryAfterSeconds ?? 60));
    } else if (result.isSuccess) {
      add(ChatReceiveResponse(response: result.response!));
    } else {
      add(
        ChatResponseFailed(
          errorMessage: result.errorMessage ?? 'Unknown error',
        ),
      );
    }
  }

  /// Send an image message
  Future<void> _onSendImageMessage(
    ChatSendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentCharacter == null || !state.canSendMessage) return;

    final userMessage = ChatMessage.image(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: event.caption,
      imageBytes: event.imageBytes,
    );

    // Add message to state and save
    final updatedMessages = [...state.messages, userMessage];
    await _repository.saveMessage(userMessage, _currentCharacter!.id);

    emit(
      state.copyWith(
        status: ChatStatus.waitingResponse,
        messages: updatedMessages,
        isTyping: true,
      ),
    );

    // Send to Gemini
    final result = await _chatService.sendImageMessage(
      character: _currentCharacter!,
      imageBytes: event.imageBytes,
      caption: event.caption,
      conversationHistory: updatedMessages,
    );

    // Handle response
    if (result.isRateLimited) {
      add(ChatRateLimited(retryAfterSeconds: result.retryAfterSeconds ?? 60));
    } else if (result.isSuccess) {
      add(ChatReceiveResponse(response: result.response!));
    } else {
      add(
        ChatResponseFailed(
          errorMessage: result.errorMessage ?? 'Failed to process image',
        ),
      );
    }
  }

  /// Handle successful AI response
  Future<void> _onReceiveResponse(
    ChatReceiveResponse event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentCharacter == null) return;

    final characterMessage = ChatMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.response,
      sender: MessageSender.character,
    );

    // Save and update state
    await _repository.saveMessage(characterMessage, _currentCharacter!.id);

    final updatedMessages = [...state.messages, characterMessage];
    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        messages: updatedMessages,
        isTyping: false,
      ),
    );
  }

  /// Handle failed AI response
  Future<void> _onResponseFailed(
    ChatResponseFailed event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentCharacter == null) return;

    // Add a fallback message from the character
    final fallbackMessage = ChatMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _getCharacterFallbackMessage(),
      sender: MessageSender.character,
    );

    await _repository.saveMessage(fallbackMessage, _currentCharacter!.id);

    final updatedMessages = [...state.messages, fallbackMessage];
    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        messages: updatedMessages,
        isTyping: false,
        errorMessage: event.errorMessage,
      ),
    );
  }

  /// Handle rate limiting
  void _onRateLimited(ChatRateLimited event, Emitter<ChatState> emit) {
    if (_currentCharacter == null) return;

    // Add rate limit message
    final rateLimitMessage = ChatMessage.text(
      id: 'ratelimit_${DateTime.now().millisecondsSinceEpoch}',
      text:
          "Give me a moment... I need to catch my breath. Try again in about a minute.",
      sender: MessageSender.character,
    );

    _repository.saveMessage(rateLimitMessage, _currentCharacter!.id);

    final updatedMessages = [...state.messages, rateLimitMessage];

    emit(
      state.copyWith(
        status: ChatStatus.rateLimited,
        messages: updatedMessages,
        isTyping: false,
        isRateLimited: true,
        rateLimitSeconds: event.retryAfterSeconds,
      ),
    );

    // Start countdown timer
    _startRateLimitCountdown(event.retryAfterSeconds);
  }

  void _startRateLimitCountdown(int seconds) {
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = seconds - timer.tick;
      if (remaining <= 0) {
        timer.cancel();
        add(const ChatRateLimitExpired());
      } else {
        add(ChatUpdateRateLimitCountdown(secondsRemaining: remaining));
      }
    });
  }

  void _onUpdateRateLimitCountdown(
    ChatUpdateRateLimitCountdown event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(rateLimitSeconds: event.secondsRemaining));
  }

  void _onRateLimitExpired(
    ChatRateLimitExpired event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        isRateLimited: false,
        rateLimitSeconds: 0,
      ),
    );
  }

  /// Reset conversation
  Future<void> _onResetConversation(
    ChatResetConversation event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentCharacter == null) return;

    _rateLimitTimer?.cancel();

    await _repository.clearConversation(_currentCharacter!.id);

    // Reload with welcome message
    add(ChatLoadMessages(character: _currentCharacter!));
  }

  /// Delete a message
  Future<void> _onDeleteMessage(
    ChatDeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    await _repository.deleteMessage(event.messageId);

    final updatedMessages =
        state.messages.where((m) => m.id != event.messageId).toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  String _getCharacterFallbackMessage() {
    final fallbacks = [
      "Hmm, I seem to have lost my train of thought. What were we discussing?",
      "My mind wandered for a moment. Could you repeat that?",
      "I... I'm not sure what to say to that. Perhaps we could talk about something else?",
    ];
    return fallbacks[DateTime.now().second % fallbacks.length];
  }
}
