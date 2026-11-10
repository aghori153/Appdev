import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/item_model.dart';
import 'items_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();

  final categories = [
    'Bag',
    'Accessory',
    'ID Card',
    'Electronics',
    'Keys',
    'Book',
    'Clothing',
    'Other',
  ];

  String category = 'Bag';
  String status = 'Found';
  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final item = Item(
      title: titleController.text.trim(),
      category: category,
      location: locationController.text.trim(),
      status: status,
      description: descriptionController.text.trim(),
      postedBy: nameController.text.trim(),
    );

    try {
      await context.read<ItemsProvider>().addItem(item);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Item posted')));
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an Item')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Found',
                  label: Text('I found it'),
                  icon: Icon(Icons.location_on_outlined),
                ),
                ButtonSegment(
                  value: 'Lost',
                  label: Text('I lost it'),
                  icon: Icon(Icons.help_outline),
                ),
              ],
              selected: {status},
              onSelectionChanged: (value) {
                setState(() => status = value.first);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Black Backpack',
                border: OutlineInputBorder(),
              ),
              validator: requiredField,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                setState(() => category = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: status == 'Found' ? 'Where did you find it?' : 'Where did you lose it?',
                border: const OutlineInputBorder(),
              ),
              validator: requiredField,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: requiredField,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
              validator: requiredField,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post Item'),
            ),
          ],
        ),
      ),
    );
  }
}
