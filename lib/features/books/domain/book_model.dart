import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final String title;
  final String author;
  final int copies;
  final int available;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.copies,
    required this.available,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'copies': copies,
      'available': available,
    };
  }

  factory Book.fromMap(String id, Map<String, dynamic> map) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      copies: (map['copies'] as num).toInt(),
      available: (map['available'] as num).toInt(),
    );
  }


bool get isAvailable { return available > 0; }


}