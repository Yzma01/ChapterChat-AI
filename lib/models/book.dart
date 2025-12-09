class Book {
  final String id;
  final String title;
  final String author;
  final String? coverImagePath;
  final bool isRead;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverImagePath,
    this.isRead = false,
  });
}
