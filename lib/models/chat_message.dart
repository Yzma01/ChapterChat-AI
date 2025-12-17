import 'dart:typed_data';

enum MessageSender { user, character }

enum MessageType { text, image, textWithImage }

class ChatMessage {
  final String id;
  final String? text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isRead;

  // Soporte para imágenes
  final MessageType type;
  final String? imagePath; // Path local de la imagen
  final Uint8List? imageBytes; // Bytes de la imagen (para mostrar sin guardar)

  ChatMessage({
    required this.id,
    this.text,
    required this.sender,
    required this.timestamp,
    this.isRead = true,
    this.type = MessageType.text,
    this.imagePath,
    this.imageBytes,
  });

  bool get isFromUser => sender == MessageSender.user;
  bool get isFromCharacter => sender == MessageSender.character;

  bool get hasImage =>
      type == MessageType.image || type == MessageType.textWithImage;
  bool get hasText => text != null && text!.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    String? imagePath,
    Uint8List? imageBytes,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  /// Factory para crear mensaje de solo texto
  factory ChatMessage.text({
    required String id,
    required String text,
    required MessageSender sender,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      sender: sender,
      timestamp: timestamp ?? DateTime.now(),
      type: MessageType.text,
    );
  }

  /// Factory para crear mensaje con imagen
  factory ChatMessage.image({
    required String id,
    required MessageSender sender,
    String? text,
    String? imagePath,
    Uint8List? imageBytes,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      sender: sender,
      timestamp: timestamp ?? DateTime.now(),
      type:
          text != null && text.isNotEmpty
              ? MessageType.textWithImage
              : MessageType.image,
      imagePath: imagePath,
      imageBytes: imageBytes,
    );
  }
}
