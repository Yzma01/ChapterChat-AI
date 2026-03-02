import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'chat_message_entity.g.dart';

/// Enum for message sender stored in Hive
@HiveType(typeId: 0)
enum MessageSenderEntity {
  @HiveField(0)
  user,

  @HiveField(1)
  character,
}

/// Enum for message type stored in Hive
@HiveType(typeId: 1)
enum MessageTypeEntity {
  @HiveField(0)
  text,

  @HiveField(1)
  image,

  @HiveField(2)
  textWithImage,
}

/// Hive entity for storing chat messages locally
@HiveType(typeId: 2)
class ChatMessageEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? text;

  @HiveField(2)
  final MessageSenderEntity sender;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final MessageTypeEntity type;

  @HiveField(6)
  final String? imagePath;

  @HiveField(7)
  final Uint8List? imageBytes;

  @HiveField(8)
  final String characterId; // To associate message with a character

  ChatMessageEntity({
    required this.id,
    this.text,
    required this.sender,
    required this.timestamp,
    this.isRead = true,
    this.type = MessageTypeEntity.text,
    this.imagePath,
    this.imageBytes,
    required this.characterId,
  });

  /// Create a copy with updated fields
  ChatMessageEntity copyWith({
    String? id,
    String? text,
    MessageSenderEntity? sender,
    DateTime? timestamp,
    bool? isRead,
    MessageTypeEntity? type,
    String? imagePath,
    Uint8List? imageBytes,
    String? characterId,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      characterId: characterId ?? this.characterId,
    );
  }
}
