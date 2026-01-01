import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_entity.dart';

/// Service for local storage of chat messages using Hive
class ChatLocalStorage {
  static const String _boxName = 'chat_messages';
  static ChatLocalStorage? _instance;

  Box<ChatMessageEntity>? _box;

  ChatLocalStorage._();

  /// Singleton instance
  static ChatLocalStorage get instance {
    _instance ??= ChatLocalStorage._();
    return _instance!;
  }

  /// Initialize Hive and register adapters
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageSenderEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MessageTypeEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChatMessageEntityAdapter());
    }

    // Open the box
    await instance._openBox();
  }

  Future<void> _openBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<ChatMessageEntity>(_boxName);
    }
  }

  /// Get all messages for a specific character
  Future<List<ChatMessageEntity>> getMessagesForCharacter(
    String characterId,
  ) async {
    await _openBox();

    final messages =
        _box!.values
            .where((message) => message.characterId == characterId)
            .toList();

    // Sort by timestamp (oldest first)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return messages;
  }

  /// Save a single message
  Future<void> saveMessage(ChatMessageEntity message) async {
    await _openBox();
    await _box!.put(message.id, message);
  }

  /// Save multiple messages
  Future<void> saveMessages(List<ChatMessageEntity> messages) async {
    await _openBox();
    final Map<String, ChatMessageEntity> messageMap = {
      for (var message in messages) message.id: message,
    };
    await _box!.putAll(messageMap);
  }

  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    await _openBox();
    await _box!.delete(messageId);
  }

  /// Delete all messages for a character
  Future<void> deleteMessagesForCharacter(String characterId) async {
    await _openBox();

    final keysToDelete =
        _box!.values
            .where((message) => message.characterId == characterId)
            .map((message) => message.id)
            .toList();

    for (final key in keysToDelete) {
      await _box!.delete(key);
    }
  }

  /// Delete all messages
  Future<void> clearAll() async {
    await _openBox();
    await _box!.clear();
  }

  /// Check if there are messages for a character
  Future<bool> hasMessagesForCharacter(String characterId) async {
    await _openBox();
    return _box!.values.any((message) => message.characterId == characterId);
  }

  /// Get the last message for a character (for preview)
  Future<ChatMessageEntity?> getLastMessageForCharacter(
    String characterId,
  ) async {
    final messages = await getMessagesForCharacter(characterId);
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Get message count for a character
  Future<int> getMessageCount(String characterId) async {
    await _openBox();
    return _box!.values
        .where((message) => message.characterId == characterId)
        .length;
  }

  /// Close the box (call when app is closing)
  Future<void> close() async {
    await _box?.close();
  }
}
