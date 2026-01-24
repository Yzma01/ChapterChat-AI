import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Storage for tracking which characters the user has started chatting with
/// This determines what appears in the Chat tab
class ActiveChatsStorage {
  static const String _boxName = 'active_chats';
  static ActiveChatsStorage? _instance;

  Box<Map>? _box;

  ActiveChatsStorage._();

  static ActiveChatsStorage get instance {
    _instance ??= ActiveChatsStorage._();
    return _instance!;
  }

  /// Initialize storage - call after Hive.initFlutter()
  static Future<void> initialize() async {
    await instance._openBox();
  }

  Future<void> _openBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  /// Add a character to active chats
  Future<void> addActiveChat(ActiveChatData chatData) async {
    await _openBox();
    await _box!.put(chatData.characterId, chatData.toMap());
  }

  /// Check if a character is already in active chats
  Future<bool> hasActiveChat(String characterId) async {
    await _openBox();
    return _box!.containsKey(characterId);
  }

  /// Get all active chats
  Future<List<ActiveChatData>> getAllActiveChats() async {
    await _openBox();
    final List<ActiveChatData> chats = [];

    for (final key in _box!.keys) {
      final data = _box!.get(key);
      if (data != null) {
        chats.add(ActiveChatData.fromMap(Map<String, dynamic>.from(data)));
      }
    }

    // Sort by last interaction time (most recent first)
    chats.sort(
      (a, b) => b.lastInteractionTime.compareTo(a.lastInteractionTime),
    );

    return chats;
  }

  /// Update last interaction time for a character
  Future<void> updateLastInteraction(String characterId) async {
    await _openBox();
    final existing = _box!.get(characterId);
    if (existing != null) {
      final data = ActiveChatData.fromMap(Map<String, dynamic>.from(existing));
      final updated = data.copyWith(lastInteractionTime: DateTime.now());
      await _box!.put(characterId, updated.toMap());
    }
  }

  /// Remove a character from active chats
  Future<void> removeActiveChat(String characterId) async {
    await _openBox();
    await _box!.delete(characterId);
  }

  /// Clear all active chats
  Future<void> clearAll() async {
    await _openBox();
    await _box!.clear();
  }
}

/// Data class for active chat information
class ActiveChatData {
  final String characterId;
  final String characterName;
  final String? characterDescription;
  final String? avatarPath;
  final String bookId;
  final String bookTitle;
  final DateTime lastInteractionTime;
  final bool hasUnread;

  ActiveChatData({
    required this.characterId,
    required this.characterName,
    this.characterDescription,
    this.avatarPath,
    required this.bookId,
    required this.bookTitle,
    required this.lastInteractionTime,
    this.hasUnread = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'characterId': characterId,
      'characterName': characterName,
      'characterDescription': characterDescription,
      'avatarPath': avatarPath,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'lastInteractionTime': lastInteractionTime.toIso8601String(),
      'hasUnread': hasUnread,
    };
  }

  factory ActiveChatData.fromMap(Map<String, dynamic> map) {
    return ActiveChatData(
      characterId: map['characterId'] ?? '',
      characterName: map['characterName'] ?? '',
      characterDescription: map['characterDescription'],
      avatarPath: map['avatarPath'],
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      lastInteractionTime:
          DateTime.tryParse(map['lastInteractionTime'] ?? '') ?? DateTime.now(),
      hasUnread: map['hasUnread'] ?? false,
    );
  }

  ActiveChatData copyWith({
    String? characterId,
    String? characterName,
    String? characterDescription,
    String? avatarPath,
    String? bookId,
    String? bookTitle,
    DateTime? lastInteractionTime,
    bool? hasUnread,
  }) {
    return ActiveChatData(
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      characterDescription: characterDescription ?? this.characterDescription,
      avatarPath: avatarPath ?? this.avatarPath,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      lastInteractionTime: lastInteractionTime ?? this.lastInteractionTime,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }
}
