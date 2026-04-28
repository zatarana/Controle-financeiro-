import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/finance_provider.dart';
import 'core/task_provider.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final financeProvider = FinanceProvider();
  await financeProvider.loadData();
  
  final taskProvider = TaskProvider();
  await taskProvider.loadData();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => financeProvider),
        ChangeNotifierProvider(create: (_) => taskProvider),
      ],
      child: const CtrlFinanceApp(),
    ),
  );
}

class CtrlFinanceApp extends StatelessWidget {
  const CtrlFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CtrlFinance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Color(0xFF9CA3AF),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}
