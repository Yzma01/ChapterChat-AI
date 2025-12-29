import 'package:chapter_chat_ai/blocs/book/bloc/book_event.dart';
import 'package:chapter_chat_ai/blocs/book/bloc/book_state.dart';
import 'package:chapter_chat_ai/blocs/book/models/book_model.dart';
import 'package:chapter_chat_ai/blocs/book/repository/book_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository bookRepository;

  BookBloc(this.bookRepository) : super(BookInitial()) {
    on<UploadBookRequested>(_uploadBookRequested);
    on<FetchBooksRequested>(_fetchBooksRequested);
  }

  Future<void> _uploadBookRequested(
    UploadBookRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      await bookRepository.saveBookData(event.book);
      emit(BookSuccess());
    } on FirebaseException catch (e) {
      emit(BookFailure(e.message ?? 'An unknown error occurred.'));
    } catch (e) {
      emit(BookFailure(e.toString()));
    }
  }

  Future<void> _fetchBooksRequested(
    FetchBooksRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final books = await bookRepository.fetchBooks();

      emit(BookLoaded(books));
    } on FirebaseException catch (e) {
      emit(BookFailure(e.message ?? 'An unknown error occurred.'));
    } catch (e) {
      emit(BookFailure(e.toString()));
    }
  }
}
