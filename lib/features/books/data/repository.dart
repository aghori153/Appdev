import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/book_model.dart';


abstract class BookRepository {
  Stream<List<Book>> watchBooks();
  Future<void> issueBook(String id);
  Future<void> returnBook(String id);
}

class FirestoreBookRepository implements BookRepository {
  final CollectionReference<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection('books');

  @override
  Stream<List<Book>> watchBooks() {   return booksRef.orderBy('title').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
 return Book.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<void> issueBook(String id) async {
    final docRef = booksRef.doc(id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Book not found');
      }

      int available = (snapshot.data()!['available'] as num).toInt();
      if (available > 0) {
        transaction.update(docRef, {'available': available - 1});
      } else {
        throw Exception('No copies left');
      }
    });
  }

  @override
  Future<void> returnBook(String id) async {
    final docRef = booksRef.doc(id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Book not found');
      }

      int available = (snapshot.data()!['available'] as num).toInt();
      int copies = (snapshot.data()!['copies'] as num).toInt();
      if (available >= copies) {
        throw Exception('Available copies cannot exceed total copies');
      }else{
      transaction.update(docRef, {'available': available + 1});
      }
    });
  }
}