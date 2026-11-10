import 'dart:async';
import 'package:flutter/material.dart';
import '../data/item_repository.dart';
import '../domain/item_model.dart';

class ItemsProvider extends ChangeNotifier {
  final ItemRepository repo;
  StreamSubscription<List<Item>>? _sub;

  List<Item> items = [];
  bool isLoading = true;
  String? error;
  String searchText = '';
  String statusFilter = 'All';

  ItemsProvider(this.repo) {
    _sub = repo.watchItems().listen((data) {
      data.sort((a, b) {
        final first = a.createdAt ?? DateTime.now();
        final second = b.createdAt ?? DateTime.now();
        return second.compareTo(first);
      });
      items = data;
      isLoading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      debugPrint('error loading items: $e');
      error = 'Could not load items';
      isLoading = false;
      notifyListeners();
    });
  }

  void setSearch(String text) {
    searchText = text;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    statusFilter = status;
    notifyListeners();
  }

  List<Item> get filteredItems {
    List<Item> result = items;
    final query = searchText.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((i) => i.title.toLowerCase().contains(query)).toList();
    }
    if (statusFilter != 'All') {
      result = result.where((i) => i.status == statusFilter).toList();
    }
    return result;
  }

  int countFor(String status) {
    if (status == 'All') return items.length;
    return items.where((i) => i.status == status).length;
  }

  Stream<Item?> watchItem(String id) {
    return repo.watchItem(id);
  }

  Future<void> addItem(Item item) async {
    await repo.addItem(item);
  }

  Future<void> markAsClaimed(String id) async {
    await repo.markAsClaimed(id);
  }

  Future<void> deleteItem(String id) async {
    await repo.deleteItem(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
