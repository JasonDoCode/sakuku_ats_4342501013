import 'package:flutter/material.dart';

import '../data/sakuku_store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final store = SakukuScope.of(context);
    // Muat data selama splash berlangsung.
    final results = await Future.wait<dynamic>([
      store.load(),
      Future<void>.delayed(const Duration(seconds: 6)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
    if (results.first != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(results.first as String)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: green,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandMark(size: 92, light: true),
              const SizedBox(height: 24),
              const Text(
                'sakuku',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 56),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFD9EFB1),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
