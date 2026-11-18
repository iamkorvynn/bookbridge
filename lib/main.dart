import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/database_helper.dart';

void main() {
  runApp(const BookBridgeApp());
}

class BookBridgeApp extends StatelessWidget {
  const BookBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _Root(),
    );
  }
}

/// Shows onboarding on first run, then the browse screen.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final seen = await DatabaseHelper.instance.hasSeenOnboarding();
    if (!mounted) return;
    setState(() => _seenOnboarding = seen);
  }

  Future<void> _finishOnboarding() async {
    await DatabaseHelper.instance.setOnboardingSeen();
    if (!mounted) return;
    setState(() => _seenOnboarding = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_seenOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_seenOnboarding!) {
      return OnboardingScreen(onDone: _finishOnboarding);
    }
    return const HomeScreen();
  }
}
