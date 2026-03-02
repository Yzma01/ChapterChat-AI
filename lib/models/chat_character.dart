class ChatCharacter {
  final String id;
  final String name;
  final String? avatarPath;
  final DateTime lastMessageTime;
  final bool hasUnread;
  final String? description; // Solo para modo bookPreview

  ChatCharacter({
    required this.id,
    required this.name,
    this.avatarPath,
    required this.lastMessageTime,
    this.hasUnread = false,
    this.description,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    }
  }

  ChatCharacter copyWith({
    String? id,
    String? name,
    String? avatarPath,
    DateTime? lastMessageTime,
    bool? hasUnread,
    String? description,
  }) {
    return ChatCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      hasUnread: hasUnread ?? this.hasUnread,
      description: description ?? this.description,
    );
  }
}
