import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/finance_provider.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final provider = FinanceProvider();
  await provider.loadData();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => provider),
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
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.indigoAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const HomePage(),
    );
  }
}
