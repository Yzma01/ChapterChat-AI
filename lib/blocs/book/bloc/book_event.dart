import 'package:chapter_chat_ai/blocs/book/models/book_model.dart';
import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchBooksRequested extends BookEvent {}

class UploadBookRequested extends BookEvent {
  final BookModel book;

  UploadBookRequested({required this.book});

  @override
  List<Object?> get props => [book];
}
