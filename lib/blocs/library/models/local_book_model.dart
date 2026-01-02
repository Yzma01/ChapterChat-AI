import 'package:hive/hive.dart';

part 'local_book_model.g.dart';

@HiveType(typeId: 10)
class LocalBookModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final List<String> genres;

  @HiveField(5)
  final String language;

  @HiveField(6)
  final int pages;

  @HiveField(7)
  final double price;

  @HiveField(8)
  final int minAge;

  @HiveField(9)
  final String? publisher;

  @HiveField(10)
  final String? storySetting;

  @HiveField(11)
  final String pdfUrl;

  @HiveField(12)
  String? localPdfPath;

  @HiveField(14)
  double readingProgress;

  @HiveField(15)
  int currentPage;

  @HiveField(16)
  int totalPages;

  @HiveField(17)
  final DateTime purchasedAt;

  @HiveField(18)
  DateTime lastReadAt;

  @HiveField(19)
  bool isDownloaded;

  @HiveField(20)
  bool isRead;

  @HiveField(21)
  final List<LocalCharacterModel> characters;

  LocalBookModel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    required this.genres,
    required this.language,
    required this.pages,
    required this.price,
    required this.minAge,
    this.publisher,
    this.storySetting,
    required this.pdfUrl,
    this.localPdfPath,
    this.readingProgress = 0.0,
    this.currentPage = 0,
    this.totalPages = 0,
    required this.purchasedAt,
    required this.lastReadAt,
    this.isDownloaded = false,
    this.isRead = false,
    required this.characters,
  });

  LocalBookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    List<String>? genres,
    String? language,
    int? pages,
    double? price,
    int? minAge,
    String? publisher,
    String? storySetting,
    String? pdfUrl,
    String? localPdfPath,
    double? readingProgress,
    int? currentPage,
    int? totalPages,
    DateTime? purchasedAt,
    DateTime? lastReadAt,
    bool? isDownloaded,
    bool? isRead,
    List<LocalCharacterModel>? characters,
  }) {
    return LocalBookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      pages: pages ?? this.pages,
      price: price ?? this.price,
      minAge: minAge ?? this.minAge,
      publisher: publisher ?? this.publisher,
      storySetting: storySetting ?? this.storySetting,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      localPdfPath: localPdfPath ?? this.localPdfPath,
      readingProgress: readingProgress ?? this.readingProgress,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isRead: isRead ?? this.isRead,
      characters: characters ?? this.characters,
    );
  }

  String get progressText {
    final percentage = (readingProgress * 100).toInt();
    return '$percentage% complete';
  }

  String get priceText {
    if (price == 0) return 'Free';
    return 'CRC ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get ageText {
    if (minAge == 0) return 'All Ages';
    return '+$minAge';
  }
}

@HiveType(typeId: 11)
class LocalCharacterModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? avatarPath;

  LocalCharacterModel({
    required this.id,
    required this.name,
    required this.description,
    this.avatarPath,
  });

  LocalCharacterModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarPath,
  }) {
    return LocalCharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
