import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/user_list_screen.dart';
import 'services/api_service.dart';
import 'viewmodels/theme_view_model.dart';
import 'viewmodels/user_view_model.dart';

void main() {
  runApp(StudentDirectoryApp(apiService: ApiService()));
}

class StudentDirectoryApp extends StatelessWidget {
  const StudentDirectoryApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserViewModel(apiService)..loadUsers(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Student Directory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          home: const UserListScreen(),
        ),
      ),
    );
  }
}

class AppTheme {
  static const Color seed = Color(0xFF0D47A1);

  static ThemeData get light =>
      _build(ColorScheme.fromSeed(seedColor: seed, primary: seed), dark: false);

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    dark: true,
  );

  static ThemeData _build(ColorScheme scheme, {required bool dark}) {
    final headerBg = dark ? scheme.surfaceContainerHigh : scheme.primary;
    final headerFg = dark ? scheme.onSurface : scheme.onPrimary;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: headerBg,
        foregroundColor: headerFg,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: headerFg,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.outline,
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
