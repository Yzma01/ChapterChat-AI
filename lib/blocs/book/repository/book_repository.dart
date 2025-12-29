import 'dart:io';
import 'package:chapter_chat_ai/blocs/book/models/book_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadPdf(File file) async {
    try {
      final storageRef = _storage.ref();
      final pdfName = DateTime.now().millisecondsSinceEpoch.toString();
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final uid = user.uid;
      final pdfRef = storageRef.child('uploads/$uid/pdfs/$pdfName.pdf');

      await pdfRef.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      );
      return await pdfRef.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }

  Future<void> saveBookData(BookModel book) async {
    try {
      final pdfUrl = await uploadPdf(book.pdfFile!);
      final data = {...book.toMap(), 'pdfUrl': pdfUrl};
      await _firestore.collection('books').add(data);
    } on FirebaseException catch (e) {
      throw Exception('Failed to save book data: ${e.message}');
    }
  }

  Future<List<BookModel>> fetchBooks() async {
    try {
      final snapshot = await _firestore.collection('books').get();

      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get books: ${e.message}');
    }
  }
}
