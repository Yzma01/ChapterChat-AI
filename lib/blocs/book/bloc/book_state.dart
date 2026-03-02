import 'package:chapter_chat_ai/blocs/book/models/book_model.dart';
import 'package:equatable/equatable.dart';

class BookState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookSuccess extends BookState {}

class BookLoaded extends BookState {
  final List<BookModel> books;
  BookLoaded(this.books);
}

class BookFailure extends BookState {
  final String error;
  BookFailure(this.error);
  @override
  List<Object?> get props => [error];
}
