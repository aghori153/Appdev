# Student Directory — Flutter Class Activity

Two-screen Flutter app (list + detail) backed by
`https://jsonplaceholder.typicode.com/users`.

## Run
```
flutter pub get
flutter run
flutter test      # 11 tests: service errors, search, favorites, back navigation, retry
```

## Structure (3 layers — no http calls in widgets)
```
lib/
  main.dart                        App, Provider setup, Material 3 theme
  models/user_model.dart           UserModel + nested Address / Company (fromJson)
  services/api_service.dart        GET /users, GET /users/{id}, 8s timeout
  services/api_exceptions.dart     NoInternet / Timeout / Server / DataParsing
  viewmodels/user_view_model.dart  ChangeNotifier: users, search query, favorites Set, Future
  screens/user_list_screen.dart    Screen 1: search, All/Favorites tabs, pull-to-refresh
  screens/user_detail_screen.dart  Screen 2: profile rows, FAB -> SnackBar
  widgets/                         UserCard, UserAvatar, InfoRow, loading/empty/error views
```

## Requirement checklist
| Requirement | Where |
|---|---|
| AppBar "Student Directory" + search toggle that filters by name | `user_list_screen.dart` (`_SearchField`, `UserViewModel.setQuery`) |
| TabBar: All Users / Favorites | `_DirectoryTabBar` + `TabBarView` |
| ListView.builder of Cards: initials avatar, name, email/company, heart | `_UserList`, `widgets/user_card.dart` |
| Navigator.push to detail with the selected user | `_UserList._openDetail` |
| Pull-to-refresh | `RefreshIndicator` → `UserViewModel.refresh()` |
| Loading placeholder | `LoadingPlaceholder` (pulsing skeleton cards) |
| Empty state "No users found" | `MessageView` |
| Detail: avatar, name, email, phone, address, company in icon rows | `user_detail_screen.dart`, `widgets/info_row.dart` |
| FAB "Send Message" → SnackBar | `_sendMessage` |
| Back preserves favorites / search / tab | state lives in `UserViewModel`; tested in `widget_test.dart` |
| Nested sub-models | `Address.fromJson`, `Company.fromJson` |
| Service layer only (GET list + GET by id) | `ApiService.fetchUsers`, `fetchUserById` |
| FutureBuilder + Provider | list screen binds `vm.usersFuture`; detail screen re-fetches by id |
| Distinct errors + Retry | `ErrorView` shows a different icon/message per exception type |
| Timeout | `.timeout(Duration(seconds: 8))` in `ApiService._get` |
| Local search (no API call per keystroke) | `UserViewModel.filteredUsers` |
| In-memory favorites | `Set<int> _favoriteIds` |
