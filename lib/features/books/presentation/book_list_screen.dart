import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/book_model.dart';
import 'provider.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Text('${provider.books.length} books in the catalogue'),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by author',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                provider.setSearch(value);
              },
            ),
          ),

          SwitchListTile(
            title: const Text('Show only available'),
            value: provider.onlyAvailable,
            onChanged: (value) {
              provider.toggleOnlyAvailable(value);
            },
          ),


          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredBooks.isEmpty
                    ? const Center(child: Text('No books match your search'))
                    : ListView.builder(
                        itemCount: provider.filteredBooks.length,
                        itemBuilder: (context, index) {
                          Book book = provider.filteredBooks[index];
                          return Card(
                        child: ListTile(
                             onTap: () => showDetails(context, book),
                          leading: const Icon(Icons.book),
                                    title: Text(
                            book.title,
                            style: TextStyle(
                              color: book.available == 0 ? Colors.red : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.author),
                              book.available == 0
                                  ? const Text('Not Available',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text('${book.available} / ${book.copies} available'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                tooltip: 'Issue',
                                onPressed: () => issue(context, book),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                tooltip: 'Return',
                                onPressed: () => returnBook(context, book),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void issue(BuildContext context, Book book) async {
    try {
      await context.read<BooksProvider>().issueBook(book.id!);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void returnBook(BuildContext context, Book book) async {
    try {
      await context.read<BooksProvider>().returnBook(book.id!);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void showDetails(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final provider = sheetContext.watch<BooksProvider>();
        Book current = provider.books.firstWhere((b) => b.id == book.id);

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.book, size: 48),
              const SizedBox(height: 12),
              Text(
                current.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: current.available == 0 ? Colors.red : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(current.author),
              const SizedBox(height: 16),
              Text(
                '${current.available} / ${current.copies} copies available',
                style: TextStyle(
                  fontSize: 18,
                  color: current.available == 0 ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: current.available > 0
                          ? () => issue(sheetContext, current)
                          : null,
                      child: const Text('Issue'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: current.available < current.copies
                          ? () => returnBook(sheetContext, current)
                          : null,
                      child: const Text('Return'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}