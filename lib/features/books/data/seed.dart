import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/book_model.dart';

Future<void> seedBooks() async {
  final booksCollection = FirebaseFirestore.instance.collection('books');

    final existing = await booksCollection.limit(1).get();
  if (existing.docs.isNotEmpty) return;

 final samples = [
    Book(title: 'Clean Code', author: 'Robert Martin', copies: 5, available: 3),
    Book(title: 'The Pragmatic Programmer', author: 'Andrew Hunt', copies: 4, available: 1),
    Book(title: 'Introduction to Algorithms', author: 'Thomas Cormen', copies: 6, available: 0),
    Book(title: 'Flutter in action', author: 'Eric Windmill', copies: 3, available: 2),
    Book(title: 'Design Patterns', author: 'Erich Gamma', copies: 4, available: 0),
    Book(title: 'Refactoring', author: 'Martin Fowler', copies: 3, available: 3),
    Book(title:'Code Complete', author: 'Steve McConnell', copies: 2, available: 1),
    Book(title: 'Head First Java', author: 'Kathy Sierra', copies: 5, available: 4),
    Book(title: 'Database System Concepts', author: 'Abraham Silberschatz', copies:4, available: 2),
    Book(title: 'Clean Architecture', author: 'Robert Martin', copies: 3, available: 1),

  ];

  final batch = FirebaseFirestore.instance.batch();

  for (var book in samples) {
    batch.set(booksCollection.doc(), book.toMap());
  }
  await batch.commit();
}