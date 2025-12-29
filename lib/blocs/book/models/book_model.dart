import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'character_model.dart';

class BookModel {
  final String? id;
  final String title;
  final String description;
  final List<String> genres;
  final String language;
  final int pages;
  final double price;
  final int minAge;
  final String? publisher;
  final String? storySetting;

  // ⚠️ Solo para upload
  final File? pdfFile;

  // ⚠️ Solo para lectura
  final String? pdfUrl;

  final List<CharacterModel>? characters;

  BookModel({
    this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.language,
    required this.pages,
    required this.price,
    required this.minAge,
    this.publisher,
    this.storySetting,
    this.pdfFile,
    this.pdfUrl,
    this.characters,
  });

  /// Para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'genres': genres.map((g) => g.toLowerCase()).toList(),
      'language': language,
      'pages': pages,
      'price': price,
      'minAge': minAge,
      'publisher': publisher,
      'storySetting': storySetting,
      'pdfUrl': pdfUrl,
      'characters': characters?.map((c) => c.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Para leer desde Firestore
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      genres: List<String>.from(data['genres']),
      language: data['language'],
      pages: data['pages'],
      price: (data['price'] as num).toDouble(),
      minAge: data['minAge'],
      publisher: data['publisher'],
      storySetting: data['storySetting'],
      pdfUrl: data['pdfUrl'],
      characters:
          (data['characters'] as List<dynamic>?)
              ?.map((c) => CharacterModel.fromMap(c))
              .toList(),
    );
  }
}
