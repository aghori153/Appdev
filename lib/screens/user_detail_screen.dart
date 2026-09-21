import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/user.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final Future<UserModel> _userFuture = context
      .read<UserViewModel>()
      .fetchUser(widget.user.id);

  void _sendMessage(UserModel user) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Message sent to ${user.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return FutureBuilder<UserModel>(
      future: _userFuture,
      initialData: widget.user,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.user;
        final refreshing = snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              FavoriteButton(
                isFavorite: vm.isFavorite(user.id),
                onPressed: () => vm.toggleFavorite(user.id),
              ),
            ],
            bottom: refreshing
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(2),
                    child: LinearProgressIndicator(minHeight: 2),
                  )
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              children: [
                ProfileHeader(user: user),
                const Divider(height: 1),
                const SizedBox(height: 8),
                InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phone,
                ),
                InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: user.address.fullAddress,
                ),
                InfoRow(
                  icon: Icons.business_outlined,
                  label: 'Company',
                  value: user.company.name,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _sendMessage(user),
            icon: const Icon(Icons.message_outlined),
            label: const Text('Send Message'),
          ),
        );
      },
    );
  }
}
