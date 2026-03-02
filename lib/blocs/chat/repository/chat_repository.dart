import 'package:chapter_chat_ai/blocs/chat/repository/active_chats_storage.dart';
import 'package:chapter_chat_ai/blocs/library/repository/library_local_storage.dart';
import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../../models/chat_character.dart';
import '../models/chat_message_entity.dart';
import '../models/chat_message_mapper.dart';
import 'chat_local_storage.dart';

/// Repository for managing chat data
/// Acts as a bridge between the BLoC and the data layer
class ChatRepository {
  final ChatLocalStorage _localStorage;

  ChatRepository({ChatLocalStorage? localStorage})
    : _localStorage = localStorage ?? ChatLocalStorage.instance;

  /// Load all messages for a specific character
  Future<List<ChatMessage>> loadMessages(String characterId) async {
    try {
      final entities = await _localStorage.getMessagesForCharacter(characterId);
      return ChatMessageMapper.toDomainList(entities);
    } catch (e) {
      print('❌ Error loading messages: $e');
      return [];
    }
  }

  /// Save a new message
  Future<bool> saveMessage(ChatMessage message, String characterId) async {
    try {
      final entity = ChatMessageMapper.toEntity(message, characterId);
      await _localStorage.saveMessage(entity);
      return true;
    } catch (e) {
      print('❌ Error saving message: $e');
      return false;
    }
  }

  /// Save multiple messages at once
  Future<bool> saveMessages(
    List<ChatMessage> messages,
    String characterId,
  ) async {
    try {
      final entities = ChatMessageMapper.toEntityList(messages, characterId);
      await _localStorage.saveMessages(entities);
      return true;
    } catch (e) {
      print('❌ Error saving messages: $e');
      return false;
    }
  }

  /// Delete a specific message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _localStorage.deleteMessage(messageId);
      return true;
    } catch (e) {
      print('❌ Error deleting message: $e');
      return false;
    }
  }

  /// Clear all messages for a character (reset conversation)
  Future<bool> clearConversation(String characterId) async {
    try {
      await _localStorage.deleteMessagesForCharacter(characterId);
      return true;
    } catch (e) {
      print('❌ Error clearing conversation: $e');
      return false;
    }
  }

  /// Check if character has existing conversation
  Future<bool> hasConversation(String characterId) async {
    try {
      return await _localStorage.hasMessagesForCharacter(characterId);
    } catch (e) {
      print('❌ Error checking conversation: $e');
      return false;
    }
  }

  /// Get the last message for a character (useful for chat list preview)
  Future<ChatMessage?> getLastMessage(String characterId) async {
    try {
      final entity = await _localStorage.getLastMessageForCharacter(
        characterId,
      );
      if (entity == null) return null;
      return ChatMessageMapper.toDomain(entity);
    } catch (e) {
      print('❌ Error getting last message: $e');
      return null;
    }
  }

  /// Get message count for a character
  Future<int> getMessageCount(String characterId) async {
    try {
      return await _localStorage.getMessageCount(characterId);
    } catch (e) {
      print('❌ Error getting message count: $e');
      return 0;
    }
  }

  /// Clear all chat data
  Future<bool> clearAllData() async {
    try {
      await _localStorage.clearAll();
      return true;
    } catch (e) {
      print('❌ Error clearing all data: $e');
      return false;
    }
  }

  Future<void> clearLocalData() async {
    // 1. Limpiar todos los chats
    await clearAllData();

    // 2. Limpiar biblioteca (libros guardados)
    await LibraryLocalStorage.instance.clearAll();

    // 3. Limpiar chats activos
    await ActiveChatsStorage.instance.clearAll();
  }
}
