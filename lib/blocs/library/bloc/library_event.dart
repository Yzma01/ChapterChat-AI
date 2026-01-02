import 'package:equatable/equatable.dart';
import '../models/local_book_model.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Load all books from local library
class LoadLibrary extends LibraryEvent {
  const LoadLibrary();
}

/// Purchase and download a book
class PurchaseBook extends LibraryEvent {
  final String id;
  final String title;
  final String author;
  final String? description;
  final List<String> genres;
  final String language;
  final int pages;
  final double price;
  final int minAge;
  final String? publisher;
  final String? storySetting;
  final String pdfUrl;
  final List<LocalCharacterModel> characters;

  const PurchaseBook({
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
    required this.characters,
  });

  @override
  List<Object?> get props => [id, title, pdfUrl];
}

/// Update reading progress for a book
class UpdateReadingProgress extends LibraryEvent {
  final String bookId;
  final int currentPage;
  final int totalPages;

  const UpdateReadingProgress({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [bookId, currentPage, totalPages];
}

/// Delete a book from library
class DeleteBook extends LibraryEvent {
  final String bookId;

  const DeleteBook({required this.bookId});

  @override
  List<Object?> get props => [bookId];
}

/// Refresh library (reload from storage)
class RefreshLibrary extends LibraryEvent {
  const RefreshLibrary();
}
