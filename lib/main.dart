import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/items/data/item_repository.dart';
import 'features/items/data/seed.dart';
import 'features/items/presentation/item_list_screen.dart';
import 'features/items/presentation/items_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await seedItems();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ItemsProvider(FirestoreItemRepository()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7A1F2B),
        useMaterial3: true,
      ),
      home: const ItemListScreen(),
    );
  }
}
