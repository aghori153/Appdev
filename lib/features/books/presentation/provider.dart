import 'package:flutter/material.dart';
import '../domain/book_model.dart';
import '../data/repository.dart';

class BooksProvider extends ChangeNotifier {
  final BookRepository repo;
  List<Book> books = [];
  bool isLoading = true;
  String searchText = '';
  bool onlyAvailable = false;

  BooksProvider(this.repo) {
    repo.watchBooks().listen((data) {
      books = data;
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('error loading books: $e');
      isLoading = false;
      notifyListeners();
    });
  }

  void setSearch(String text) {
    searchText = text;
    notifyListeners();
  }

  void toggleOnlyAvailable(bool value) {
    onlyAvailable = value;
    notifyListeners();
  }

  List<Book> get filteredBooks {
    List<Book> result = books;
    if (searchText.isNotEmpty) {
      result = result
          .where((b) => b.author.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    if (onlyAvailable) {
      result = result.where((b) => b.available > 0).toList();
    }

    return result;
  }

  Future<void> issueBook(String id) async {
    await repo.issueBook(id);
  }

  Future<void> returnBook(String id) async {
    await repo.returnBook(id);
  }
}