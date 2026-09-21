import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_exceptions.dart';

class DirectorySearchBar extends StatelessWidget {
  const DirectorySearchBar({
    super.key,
    required this.controller,
    required this.users,
    required this.onUserSelected,
    required this.isDark,
    required this.onToggleTheme,
  });

  final SearchController controller;
  final List<UserModel> users;
  final ValueChanged<UserModel> onUserSelected;
  final bool isDark;
  final VoidCallback onToggleTheme;

  List<UserModel> _matches(String text) {
    final q = text.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) => u.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: controller,
      viewHintText: 'Search students...',
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          key: const Key('search-bar'),
          controller: controller,
          hintText: 'Search students...',
          elevation: const WidgetStatePropertyAll<double>(0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: controller.openView,
          onChanged: (_) => controller.openView(),
          leading: const Icon(Icons.search),
          trailing: <Widget>[
            if (controller.text.isNotEmpty)
              IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: controller.clear,
              ),
            Tooltip(
              message: 'Change brightness mode',
              child: IconButton(
                isSelected: isDark,
                onPressed: onToggleTheme,
                icon: const Icon(Icons.wb_sunny_outlined),
                selectedIcon: const Icon(Icons.brightness_2_outlined),
              ),
            ),
          ],
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final matches = _matches(controller.text);
        if (matches.isEmpty) {
          return const [
            ListTile(
              leading: Icon(Icons.person_search),
              title: Text('No users found'),
            ),
          ];
        }
        return matches.map(
          (user) => ListTile(
            key: Key('suggestion-${user.id}'),
            leading: UserAvatar(initials: user.initials, radius: 18),
            title: Text(user.name),
            subtitle: Text(user.email),
            onTap: () {
              controller.closeView(user.name);
              onUserSelected(user);
            },
          ),
        );
      },
    );
  }
}

class DirectoryTabBar extends StatelessWidget implements PreferredSizeWidget {
  const DirectoryTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: controller,
        tabs: const [
          Tab(text: 'All Users'),
          Tab(text: 'Favorites'),
        ],
      ),
    );
  }
}

class UserListView extends StatelessWidget {
  const UserListView({
    super.key,
    required this.users,
    required this.isFavorite,
    required this.onUserTap,
    required this.onFavoriteToggle,
    required this.onRefresh,
    required this.emptyTitle,
    this.emptyMessage,
  });

  final List<UserModel> users;
  final bool Function(int id) isFavorite;
  final void Function(UserModel user) onUserTap;
  final void Function(int id) onFavoriteToggle;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: users.isEmpty
          ? MessageView(
              icon: Icons.person_search,
              title: emptyTitle,
              message: emptyMessage,
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserCard(
                  user: user,
                  isFavorite: isFavorite(user.id),
                  onTap: () => onUserTap(user),
                  onFavoriteToggle: () => onFavoriteToggle(user.id),
                );
              },
            ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final UserModel user;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: Hero(
          tag: 'avatar-${user.id}',
          child: UserAvatar(initials: user.initials),
        ),
        title: Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${user.email}\n${user.company.name}',
          style: theme.textTheme.bodySmall,
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: onFavoriteToggle,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.initials, this.radius = 22});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Hero(
            tag: 'avatar-${user.id}',
            child: UserAvatar(initials: user.initials, radius: 44),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.company.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      onPressed: onPressed,
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}

class LoadingPlaceholder extends StatefulWidget {
  const LoadingPlaceholder({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<LoadingPlaceholder> createState() => _LoadingPlaceholderState();
}

class _LoadingPlaceholderState extends State<LoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: ListView.builder(
        key: const Key('loading-placeholder'),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.itemCount,
        itemBuilder: (_, _) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(140, 14),
                      const SizedBox(height: 8),
                      bar(200, 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                  if (action != null) ...[const SizedBox(height: 20), action!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  IconData get _icon => switch (error) {
    NoInternetException() => Icons.wifi_off,
    RequestTimeoutException() => Icons.hourglass_empty,
    ServerException() => Icons.cloud_off,
    DataParsingException() => Icons.data_object,
    _ => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final e = error;
    return MessageView(
      icon: _icon,
      title: e is ApiException ? e.title : 'Something went wrong',
      message: e is ApiException ? e.message : e.toString(),
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
    );
  }
}
