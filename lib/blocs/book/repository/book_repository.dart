import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/book_model.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload PDF to Firebase Storage
  Future<String> uploadPdf(File file, String bookId) async {
    try {
      final storageRef = _storage.ref();
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final uid = user.uid;
      final pdfRef = storageRef.child('uploads/$uid/pdfs/$bookId.pdf');

      await pdfRef.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      );
      return await pdfRef.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }

  /// Save book data with PDF
  Future<void> saveBookData(BookModel book) async {
    try {
      // Generate a unique ID for the book
      final bookId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload PDF
      final pdfUrl = await uploadPdf(book.pdfFile!, bookId);

      // Save to Firestore
      final data = {...book.toMap(), 'pdfUrl': pdfUrl};

      await _firestore.collection('books').add(data);
      debugPrint('✅ Book saved to Firestore');
    } on FirebaseException catch (e) {
      throw Exception('Failed to save book data: ${e.message}');
    }
  }

  /// Fetch all books from Firestore
  Future<List<BookModel>> fetchBooks() async {
    try {
      final snapshot =
          await _firestore
              .collection('books')
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get books: ${e.message}');
    }
  }

  /// Fetch a single book by ID
  Future<BookModel?> fetchBookById(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to get book: ${e.message}');
    }
  }
}
