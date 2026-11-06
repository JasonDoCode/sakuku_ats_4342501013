import 'package:flutter/material.dart';

import 'data/sakuku_store.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/history_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SakukuApp());
}

class SakukuApp extends StatefulWidget {
  const SakukuApp({super.key});
  @override
  State<SakukuApp> createState() => _SakukuAppState();
}

class _SakukuAppState extends State<SakukuApp> {
  // Store berada di atas Navigator agar data bertahan saat pindah halaman.
  final store = SakukuStore();
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SakukuScope(
    store: store,
    child: MaterialApp(
      title: 'Sakuku',
      debugShowCheckedModeBanner: false,
      theme: sakukuTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/add': (_) => const AddTransactionScreen(),
        '/history': (_) => const HistoryScreen(),
      },
    ),
  );
}
