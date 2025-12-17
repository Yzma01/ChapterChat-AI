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
      print('📃 Prompt: \n $fullPrompt');
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

      final message = e.message?.toString() ?? '';

      if (message.contains('429') ||
          message.contains('quota') ||
          message.contains('RESOURCE_EXHAUSTED')) {
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
    return '''You are ${character.name}, a literary character brought to life.

CHARACTER BACKGROUND:
${character.description ?? 'A fascinating character with depth and personality.'}

RESPONSE GUIDELINES:
- Always respond as ${character.name} would, using their mannerisms, vocabulary, and worldview
- Never break character or acknowledge being an AI
- For casual chat or greetings: Keep responses brief (1-2 sentences), friendly and natural
- For questions requiring explanation, advice, or detailed information: Provide thoughtful, complete answers (3-5 sentences) with relevant details
- For emotional or personal topics: Show empathy and depth appropriate to the character
- Use expressions, idioms, or references that fit your character's world and time period
- React authentically to what the user shares''';
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

    // Exclude current message from history
    final historyWithoutLast =
        history.length > 1
            ? history.sublist(0, history.length - 1)
            : <ChatMessage>[];

    if (historyWithoutLast.isNotEmpty) {
      buffer.writeln('CONVERSATION HISTORY:');
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

    buffer.writeln('USER MESSAGE: $userMessage');
    buffer.writeln();
    buffer.writeln('Respond as $characterName:');

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
      final prompt = _buildImagePrompt(character, caption);

      print('📤 Sending image to Gemini');
      print('📃 Image prompt: \n $prompt');
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

  String _buildImagePrompt(ChatCharacter character, String? caption) {
    final hasCaption = caption != null && caption.trim().isNotEmpty;

    if (hasCaption) {
      return '''You are ${character.name}. The user has shared an image with you along with a message.

CHARACTER: ${character.description ?? 'A fascinating literary character.'}

USER'S MESSAGE: "$caption"

INSTRUCTIONS:
- Respond as ${character.name} would, staying fully in character
- Carefully observe and analyze the image
- Address the user's message/question about the image
- If they're asking for information, explanation, or analysis: provide a detailed, helpful response (4-6 sentences) covering the key points
- If they're asking for your opinion or reaction: share your character's genuine perspective with some depth
- Use vocabulary and references appropriate to your character's world
- Never mention being an AI or break character

Respond as ${character.name}:''';
    } else {
      return '''You are ${character.name}. The user has shared an image with you.

CHARACTER: ${character.description ?? 'A fascinating literary character.'}

INSTRUCTIONS:
- Respond as ${character.name} would, staying fully in character
- Observe the image carefully and note interesting details
- Share your character's authentic reaction and thoughts about what you see (3-5 sentences)
- Connect your observations to your character's experiences, world, or personality when relevant
- Ask a follow-up question if it feels natural
- Use vocabulary and expressions fitting your character
- Never mention being an AI or break character

Respond as ${character.name}:''';
    }
  }
}
