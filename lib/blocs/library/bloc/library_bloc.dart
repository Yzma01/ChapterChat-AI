import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/library_local_storage.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryLocalStorage _storage = LibraryLocalStorage.instance;

  LibraryBloc() : super(const LibraryState()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<PurchaseBook>(_onPurchaseBook);
    on<UpdateReadingProgress>(_onUpdateReadingProgress);
    on<DeleteBook>(_onDeleteBook);
    on<RefreshLibrary>(_onRefreshLibrary);
  }

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading));

    try {
      final books = await _storage.getAllBooks();
      emit(state.copyWith(status: LibraryStatus.loaded, books: books));
      debugPrint('📚 Library loaded: ${books.length} books');
    } catch (e) {
      debugPrint('❌ Error loading library: $e');
      emit(
        state.copyWith(status: LibraryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onPurchaseBook(
    PurchaseBook event,
    Emitter<LibraryState> emit,
  ) async {
    // Check if already purchased
    if (_storage.hasBook(event.id)) {
      debugPrint('📚 Book already in library: ${event.title}');
      emit(
        state.copyWith(
          status: LibraryStatus.purchaseSuccess,
          purchasedBookId: event.id,
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: LibraryStatus.purchasing, downloadProgress: 0.0),
    );

    try {
      final localBook = await _storage.purchaseBook(
        id: event.id,
        title: event.title,
        author: event.author,
        description: event.description,
        genres: event.genres,
        language: event.language,
        pages: event.pages,
        price: event.price,
        minAge: event.minAge,
        publisher: event.publisher,
        storySetting: event.storySetting,
        pdfUrl: event.pdfUrl,
        characters: event.characters,
      );

      // Reload library to include new book
      final books = await _storage.getAllBooks();

      emit(
        state.copyWith(
          status: LibraryStatus.purchaseSuccess,
          books: books,
          purchasedBookId: localBook.id,
          downloadProgress: 1.0,
        ),
      );

      debugPrint('✅ Book purchased: ${event.title}');
    } catch (e) {
      debugPrint('❌ Error purchasing book: $e');
      emit(
        state.copyWith(
          status: LibraryStatus.error,
          errorMessage: 'Failed to download book: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateReadingProgress(
    UpdateReadingProgress event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _storage.updateReadingProgress(
        event.bookId,
        currentPage: event.currentPage,
        totalPages: event.totalPages,
      );

      // Reload library to get updated progress
      final books = await _storage.getAllBooks();
      emit(state.copyWith(status: LibraryStatus.loaded, books: books));
    } catch (e) {
      debugPrint('❌ Error updating progress: $e');
    }
  }

  Future<void> _onDeleteBook(
    DeleteBook event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _storage.deleteBook(event.bookId);

      // Reload library
      final books = await _storage.getAllBooks();
      emit(state.copyWith(status: LibraryStatus.loaded, books: books));

      debugPrint('🗑️ Book deleted: ${event.bookId}');
    } catch (e) {
      debugPrint('❌ Error deleting book: $e');
      emit(
        state.copyWith(status: LibraryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRefreshLibrary(
    RefreshLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final books = await _storage.getAllBooks();
      emit(state.copyWith(status: LibraryStatus.loaded, books: books));
    } catch (e) {
      debugPrint('❌ Error refreshing library: $e');
    }
  }
}
