import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../models/local_book_model.dart';

class LibraryLocalStorage {
  static const String _boxName = 'local_library';
  static LibraryLocalStorage? _instance;
  late Box<LocalBookModel> _box;

  LibraryLocalStorage._();

  static LibraryLocalStorage get instance {
    _instance ??= LibraryLocalStorage._();
    return _instance!;
  }

  static Future<void> initialize() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(LocalBookModelAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(LocalCharacterModelAdapter());
    }

    // Open box
    instance._box = await Hive.openBox<LocalBookModel>(_boxName);
    debugPrint(
      '✅ LibraryLocalStorage initialized with ${instance._box.length} books',
    );
  }

  /// Get all books from local library
  Future<List<LocalBookModel>> getAllBooks() async {
    return _box.values.toList()
      ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
  }

  /// Get a specific book by ID
  Future<LocalBookModel?> getBook(String bookId) async {
    return _box.get(bookId);
  }

  /// Check if book exists in library
  bool hasBook(String bookId) {
    return _box.containsKey(bookId);
  }

  /// Add or update a book in local library
  Future<void> saveBook(LocalBookModel book) async {
    await _box.put(book.id, book);
    debugPrint('📚 Saved book: ${book.title}');
  }

  /// Delete a book from local library
  Future<void> deleteBook(String bookId) async {
    final book = _box.get(bookId);
    if (book != null) {
      // Delete local PDF file
      if (book.localPdfPath != null) {
        final pdfFile = File(book.localPdfPath!);
        if (await pdfFile.exists()) {
          await pdfFile.delete();
        }
      }
      await _box.delete(bookId);
      debugPrint('🗑️ Deleted book: ${book.title}');
    }
  }

  /// Update reading progress
  Future<void> updateReadingProgress(
    String bookId, {
    required int currentPage,
    required int totalPages,
  }) async {
    final book = _box.get(bookId);
    if (book != null) {
      // currentPage is 0-indexed, so add 1 for correct progress calculation
      // Page 0 of 2 = 50% (viewing first page)
      // Page 1 of 2 = 100% (viewing last page)
      final progress = totalPages > 0 ? (currentPage + 1) / totalPages : 0.0;
      final isRead = currentPage >= totalPages - 1;

      final updatedBook = book.copyWith(
        currentPage: currentPage,
        totalPages: totalPages,
        readingProgress: progress.clamp(0.0, 1.0),
        lastReadAt: DateTime.now(),
        isRead: isRead,
      );

      await _box.put(bookId, updatedBook);
      debugPrint(
        '📖 Updated progress: ${book.title} - Page ${currentPage + 1}/$totalPages (${(progress * 100).toInt()}%)',
      );
    }
  }

  /// Download PDF from URL and save locally
  Future<String> downloadPdf(String pdfUrl, String bookId) async {
    try {
      debugPrint('⬇️ Downloading PDF for book: $bookId');

      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }

      final directory = await getApplicationDocumentsDirectory();
      final bookDir = Directory('${directory.path}/books/$bookId');
      if (!await bookDir.exists()) {
        await bookDir.create(recursive: true);
      }

      final pdfPath = '${bookDir.path}/book.pdf';
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(response.bodyBytes);

      debugPrint('✅ PDF downloaded: $pdfPath');
      return pdfPath;
    } catch (e) {
      debugPrint('❌ Error downloading PDF: $e');
      rethrow;
    }
  }

  /// Purchase and download book
  Future<LocalBookModel> purchaseBook({
    required String id,
    required String title,
    required String author,
    String? description,
    required List<String> genres,
    required String language,
    required int pages,
    required double price,
    required int minAge,
    String? publisher,
    String? storySetting,
    required String pdfUrl,
    required List<LocalCharacterModel> characters,
  }) async {
    try {
      debugPrint('💰 Purchasing book: $title');

      // Download PDF
      final localPdfPath = await downloadPdf(pdfUrl, id);

      // Get total pages from PDF
      final document = await PdfDocument.openFile(localPdfPath);
      final totalPages = document.pagesCount;
      await document.close();

      // Create local book model
      final localBook = LocalBookModel(
        id: id,
        title: title,
        author: author,
        description: description,
        genres: genres,
        language: language,
        pages: pages,
        price: price,
        minAge: minAge,
        publisher: publisher,
        storySetting: storySetting,
        pdfUrl: pdfUrl,
        localPdfPath: localPdfPath,
        readingProgress: 0.0,
        currentPage: 0,
        totalPages: totalPages,
        purchasedAt: DateTime.now(),
        lastReadAt: DateTime.now(),
        isDownloaded: true,
        isRead: false,
        characters: characters,
      );

      // Save to local storage
      await saveBook(localBook);

      debugPrint('✅ Book purchased and saved: $title');
      return localBook;
    } catch (e) {
      debugPrint('❌ Error purchasing book: $e');
      rethrow;
    }
  }

  /// Get total books count
  int get totalBooks => _box.length;

  /// Clear all data (for debugging)
  Future<void> clearAll() async {
    // Delete all local PDF files
    for (final book in _box.values) {
      if (book.localPdfPath != null) {
        final pdfFile = File(book.localPdfPath!);
        if (await pdfFile.exists()) {
          await pdfFile.delete();
        }
      }
    }
    await _box.clear();
    debugPrint('🗑️ Library cleared');
  }
}
