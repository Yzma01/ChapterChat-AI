import 'package:equatable/equatable.dart';
import '../models/local_book_model.dart';

enum LibraryStatus {
  initial,
  loading,
  loaded,
  purchasing,
  purchaseSuccess,
  error,
}

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<LocalBookModel> books;
  final String? errorMessage;
  final String? purchasedBookId;
  final double downloadProgress;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.books = const [],
    this.errorMessage,
    this.purchasedBookId,
    this.downloadProgress = 0.0,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<LocalBookModel>? books,
    String? errorMessage,
    String? purchasedBookId,
    double? downloadProgress,
  }) {
    return LibraryState(
      status: status ?? this.status,
      books: books ?? this.books,
      errorMessage: errorMessage,
      purchasedBookId: purchasedBookId,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  /// Check if a book is in the library
  bool hasBook(String bookId) {
    return books.any((book) => book.id == bookId);
  }

  /// Get a book by ID
  LocalBookModel? getBook(String bookId) {
    try {
      return books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    status,
    books,
    errorMessage,
    purchasedBookId,
    downloadProgress,
  ];
}
