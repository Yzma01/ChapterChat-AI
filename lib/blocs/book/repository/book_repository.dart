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

  /// NEW: Upload cover image to Firebase Storage
  Future<String> uploadCoverImage(File file, String bookId) async {
    try {
      final storageRef = _storage.ref();
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final uid = user.uid;

      // Get file extension
      final extension = file.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];

      if (!validExtensions.contains(extension)) {
        throw Exception('Invalid image format. Please use JPG, PNG, or WEBP.');
      }

      final coverRef = storageRef.child(
        'uploads/$uid/covers/$bookId.$extension',
      );

      // Determine content type
      String contentType;
      switch (extension) {
        case 'png':
          contentType = 'image/png';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg';
      }

      await coverRef.putFile(file, SettableMetadata(contentType: contentType));

      final downloadUrl = await coverRef.getDownloadURL();
      debugPrint('✅ Cover image uploaded: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Cover upload failed: ${e.message}');
    }
  }

  /// Save book data with PDF and cover image
  Future<void> saveBookData(BookModel book) async {
    try {
      // Generate a unique ID for the book
      final bookId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload PDF
      final pdfUrl = await uploadPdf(book.pdfFile!, bookId);

      // Upload cover image (mandatory)
      if (book.coverImageFile == null) {
        throw Exception('Cover image is required');
      }
      final coverUrl = await uploadCoverImage(book.coverImageFile!, bookId);

      // Save to Firestore
      final data = {
        ...book.toMap(),
        'pdfUrl': pdfUrl,
        'coverUrl': coverUrl, // NEW: Include cover URL
      };

      await _firestore.collection('books').add(data);
      debugPrint('✅ Book saved to Firestore with cover image');
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
