import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/item_model.dart';
import 'items_provider.dart';
import 'widgets/status_badge.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final Stream<Item?> itemStream;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    itemStream = context.read<ItemsProvider>().watchItem(widget.item.id!);
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour}:$minute';
  }

  Future<void> claim() async {
    setState(() => isBusy = true);
    try {
      await context.read<ItemsProvider>().markAsClaimed(widget.item.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Marked as claimed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
    if (mounted) setState(() => isBusy = false);
  }

  Future<void> delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete item?'),
          content: const Text('This post will be removed for everyone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<ItemsProvider>().deleteItem(widget.item.id!);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<Item?>(
      stream: itemStream,
      initialData: widget.item,
      builder: (context, snapshot) {
        final item = snapshot.data;

        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 56, color: scheme.outline),
                  const SizedBox(height: 12),
                  const Text('This item has been removed'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Item Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: delete,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Hero(
                  tag: 'icon-${item.id}',
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      categoryIcon(item.category),
                      size: 46,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: StatusBadge(
                    key: ValueKey(item.status),
                    status: item.status,
                    large: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    infoRow(Icons.category_outlined, 'Category', item.category),
                    const Divider(height: 1),
                    infoRow(Icons.place_outlined, 'Location', item.location),
                    const Divider(height: 1),
                    infoRow(Icons.person_outline, 'Posted by',
                        item.postedBy.isEmpty ? 'Unknown' : item.postedBy),
                    const Divider(height: 1),
                    infoRow(Icons.schedule, 'Posted on', formatDate(item.createdAt)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description.isEmpty ? 'No description added.' : item.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton.icon(
                onPressed: item.isClaimed || isBusy ? null : claim,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(item.isClaimed ? Icons.check_circle : Icons.check),
                label: Text(item.isClaimed ? 'Already Claimed' : 'Mark as Claimed'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
