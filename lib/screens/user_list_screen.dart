import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/user.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<UserViewModel>().setQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final theme = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56 + 16 + kTextTabBarHeight),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: DirectorySearchBar(
                  controller: _searchController,
                  users: vm.users,
                  onUserSelected: _openDetail,
                  isDark: theme.isDark,
                  onToggleTheme: theme.toggle,
                ),
              ),
              DirectoryTabBar(controller: _tabController),
            ],
          ),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(UserViewModel vm) {
    return FutureBuilder<List<UserModel>>(
      future: vm.usersFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading && !vm.hasData) return const LoadingPlaceholder();

        if (!isLoading && snapshot.hasError) {
          return ErrorView(error: snapshot.error!, onRetry: vm.loadUsers);
        }

        final noFavoritesYet = vm.query.isEmpty && vm.favoriteIds.isEmpty;

        return TabBarView(
          controller: _tabController,
          children: [
            UserListView(
              key: const PageStorageKey('all-users'),
              users: vm.filteredUsers,
              isFavorite: vm.isFavorite,
              onUserTap: _openDetail,
              onFavoriteToggle: vm.toggleFavorite,
              onRefresh: vm.refresh,
              emptyTitle: 'No users found',
              emptyMessage: vm.query.isEmpty
                  ? null
                  : 'No name matches "${vm.query}".',
            ),
            UserListView(
              key: const PageStorageKey('favorites'),
              users: vm.filteredFavorites,
              isFavorite: vm.isFavorite,
              onUserTap: _openDetail,
              onFavoriteToggle: vm.toggleFavorite,
              onRefresh: vm.refresh,
              emptyTitle: noFavoritesYet
                  ? 'No favorites yet'
                  : 'No users found',
              emptyMessage: noFavoritesYet
                  ? 'Tap the heart on a student to add them here.'
                  : null,
            ),
          ],
        );
      },
    );
  }
}
