import 'dart:typed_data';
import '../models/chat_character.dart';
import '../models/chat_message.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

/// Result class to communicate rate limiting to UI
class ChatResult {
  final String? response;
  final bool isRateLimited;
  final int? retryAfterSeconds;
  final String? errorMessage;

  ChatResult({
    this.response,
    this.isRateLimited = false,
    this.retryAfterSeconds,
    this.errorMessage,
  });

  bool get isSuccess => response != null && response!.isNotEmpty;
}

class GeminiChatService {
  final Gemini _gemini = Gemini.instance;

  static final GeminiChatService _instance = GeminiChatService._internal();
  factory GeminiChatService() => _instance;
  GeminiChatService._internal();

  //static const String _modelName = 'gemini-2.5-flash-lite';

  static const int _maxHistoryMessages = 6;

  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 4);

  Future<ChatResult> sendTextMessage({
    required ChatCharacter character,
    required String userMessage,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    // Client-side rate limiting - wait between requests
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        print('⏳ Rate limit protection: waiting ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }

    try {
      final systemPrompt = _buildCharacterSystemPrompt(character);
      final fullPrompt = _buildPromptWithHistory(
        characterName: character.name,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: conversationHistory,
      );

      print('📤 Sending to Gemini (${fullPrompt.length} chars)');
      _lastRequestTime = DateTime.now();

      final response = await _gemini.text(fullPrompt);

      if (response?.output != null && response!.output!.isNotEmpty) {
        final output = response.output!.trim();
        print('✅ Response received (${output.length} chars)');
        return ChatResult(response: output);
      }

      print('⚠️ Empty response from Gemini');
      return ChatResult(errorMessage: 'Empty response');
    } on GeminiException catch (e) {
      print('❌ GeminiException: ${e.message}');

      // Convert to String safely
      final message = e.message?.toString() ?? '';

      // Check for rate limit error
      if (message.contains('429') ||
          message.contains('quota') ||
          message.contains('RESOURCE_EXHAUSTED')) {
        // Extract retry time if available
        int retrySeconds = 60;
        final retryMatch = RegExp(r'retry in (\d+)').firstMatch(message);
        if (retryMatch != null) {
          retrySeconds = int.tryParse(retryMatch.group(1) ?? '60') ?? 60;
        }

        print('🚫 RATE LIMITED - Retry after ${retrySeconds}s');
        return ChatResult(
          isRateLimited: true,
          retryAfterSeconds: retrySeconds,
          errorMessage: 'Rate limited - please wait',
        );
      }

      return ChatResult(errorMessage: message);
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('Stack: $stackTrace');
      return ChatResult(errorMessage: e.toString());
    }
  }

  String _buildCharacterSystemPrompt(ChatCharacter character) {
    return '''You are ${character.name}. Stay in character always.

ABOUT YOU: ${character.description ?? 'A fascinating character.'}

RULES:
- Respond as ${character.name} would
- Never break character or mention being an AI
- Keep responses to 1-3 sentences
- Be natural and conversational''';
  }

  String _buildPromptWithHistory({
    required String characterName,
    required String systemPrompt,
    required String userMessage,
    required List<ChatMessage> history,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(systemPrompt);
    buffer.writeln();

    // Exclude current message from history (it's already added)
    final historyWithoutLast =
        history.length > 1
            ? history.sublist(0, history.length - 1)
            : <ChatMessage>[];

    if (historyWithoutLast.isNotEmpty) {
      buffer.writeln('CONVERSATION:');
      final recentHistory =
          historyWithoutLast.length > _maxHistoryMessages
              ? historyWithoutLast.sublist(
                historyWithoutLast.length - _maxHistoryMessages,
              )
              : historyWithoutLast;

      for (final message in recentHistory) {
        if (message.hasText &&
            message.text != null &&
            message.text!.isNotEmpty) {
          final prefix = message.isFromUser ? 'User' : characterName;
          buffer.writeln('$prefix: ${message.text}');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('User: $userMessage');
    buffer.writeln('$characterName:');

    return buffer.toString();
  }

  Future<ChatResult> sendImageMessage({
    required ChatCharacter character,
    required Uint8List imageBytes,
    String? caption,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }

    try {
      final prompt =
          caption != null && caption.isNotEmpty
              ? 'As ${character.name}, respond to this image. User says: "$caption"'
              : 'As ${character.name}, comment on this image briefly.';

      _lastRequestTime = DateTime.now();
      final response = await _gemini.textAndImage(
        text: prompt,
        images: [imageBytes],
      );

      if (response?.output != null) {
        return ChatResult(response: response!.output!.trim());
      }
      return ChatResult(errorMessage: 'Empty response');
    } on GeminiException catch (e) {
      final message = e.message?.toString() ?? '';
      if (message.contains('429')) {
        return ChatResult(isRateLimited: true, retryAfterSeconds: 60);
      }
      return ChatResult(errorMessage: message);
    } catch (e) {
      return ChatResult(errorMessage: e.toString());
    }
  }
}
