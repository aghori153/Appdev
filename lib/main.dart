import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/books/data/seed.dart';
import 'features/books/presentation/provider.dart';
import 'features/books/data/repository.dart';
import 'features/books/presentation/book_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();          
  await Firebase.initializeApp(                       
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await seedBooks(); 
  runApp(                                             
    ChangeNotifierProvider(
      create: (_) => BooksProvider(FirestoreBookRepository()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Book Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const BookListScreen(),
    );
  }
}

