import '../../../models/chat_message.dart';
import 'chat_message_entity.dart';

/// Mapper class to convert between domain models and storage entities
class ChatMessageMapper {
  ChatMessageMapper._();

  /// Convert domain model to storage entity
  static ChatMessageEntity toEntity(ChatMessage message, String characterId) {
    return ChatMessageEntity(
      id: message.id,
      text: message.text,
      sender: _mapSenderToEntity(message.sender),
      timestamp: message.timestamp,
      isRead: message.isRead,
      type: _mapTypeToEntity(message.type),
      imagePath: message.imagePath,
      imageBytes: message.imageBytes,
      characterId: characterId,
    );
  }

  /// Convert storage entity to domain model
  static ChatMessage toDomain(ChatMessageEntity entity) {
    return ChatMessage(
      id: entity.id,
      text: entity.text,
      sender: _mapSenderToDomain(entity.sender),
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      type: _mapTypeToDomain(entity.type),
      imagePath: entity.imagePath,
      imageBytes: entity.imageBytes,
    );
  }

  /// Convert list of entities to domain models
  static List<ChatMessage> toDomainList(List<ChatMessageEntity> entities) {
    return entities.map((e) => toDomain(e)).toList();
  }

  /// Convert list of domain models to entities
  static List<ChatMessageEntity> toEntityList(
    List<ChatMessage> messages,
    String characterId,
  ) {
    return messages.map((m) => toEntity(m, characterId)).toList();
  }

  // Private helper methods
  static MessageSenderEntity _mapSenderToEntity(MessageSender sender) {
    switch (sender) {
      case MessageSender.user:
        return MessageSenderEntity.user;
      case MessageSender.character:
        return MessageSenderEntity.character;
    }
  }

  static MessageSender _mapSenderToDomain(MessageSenderEntity sender) {
    switch (sender) {
      case MessageSenderEntity.user:
        return MessageSender.user;
      case MessageSenderEntity.character:
        return MessageSender.character;
    }
  }

  static MessageTypeEntity _mapTypeToEntity(MessageType type) {
    switch (type) {
      case MessageType.text:
        return MessageTypeEntity.text;
      case MessageType.image:
        return MessageTypeEntity.image;
      case MessageType.textWithImage:
        return MessageTypeEntity.textWithImage;
    }
  }

  static MessageType _mapTypeToDomain(MessageTypeEntity type) {
    switch (type) {
      case MessageTypeEntity.text:
        return MessageType.text;
      case MessageTypeEntity.image:
        return MessageType.image;
      case MessageTypeEntity.textWithImage:
        return MessageType.textWithImage;
    }
  }
}
