import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel(this._api);

  final ApiService _api;

  List<UserModel> _users = const [];
  final Set<int> _favoriteIds = {};
  String _query = '';
  Future<List<UserModel>>? _usersFuture;

  Future<List<UserModel>>? get usersFuture => _usersFuture;

  List<UserModel> get users => _users;
  bool get hasData => _users.isNotEmpty;
  String get query => _query;
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<UserModel> get filteredUsers => _applySearch(_users);

  List<UserModel> get filteredFavorites =>
      _applySearch(_users.where((u) => _favoriteIds.contains(u.id)).toList());

  List<UserModel> _applySearch(List<UserModel> list) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((u) => u.name.toLowerCase().contains(q)).toList();
  }

  void loadUsers() {
    _usersFuture = _fetch();
    notifyListeners();
  }

  Future<void> refresh() {
    loadUsers();
    return _usersFuture!.then((_) {}, onError: (_) {});
  }

  Future<List<UserModel>> _fetch() async {
    final result = await _api.fetchUsers();
    _users = result;
    notifyListeners();
    return result;
  }

  Future<UserModel> fetchUser(int id) => _api.fetchUserById(id);

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  bool isFavorite(int id) => _favoriteIds.contains(id);

  void toggleFavorite(int id) {
    if (!_favoriteIds.remove(id)) _favoriteIds.add(id);
    notifyListeners();
  }
}
