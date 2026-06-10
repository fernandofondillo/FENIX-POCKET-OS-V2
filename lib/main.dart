// lib/main.dart
// Entry point de Fénix Pocket OS V2 (A.G.O.S.)
// Autor: Líder CTO | Fecha: 2026-06-10

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/memory_service.dart';
import 'views/auth/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const FenixPocketOSApp());
}

class FenixPocketOSApp extends StatelessWidget {
  const FenixPocketOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fénix Pocket OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4C8CFA),
        scaffoldBackgroundColor: const Color(0xFF13131A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4C8CFA),
          secondary: const Color(0xFF4C8CFA),
          surface: const Color(0xFF1A1A24),
        ),
        fontFamily: 'SF Pro',
      ),
      home: const _BootstrapGate(),
    );
  }
}

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  final _memory = MemoryService();
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _memory.init_memory();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error de inicialización:\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4C8CFA)),
              SizedBox(height: 24),
              Text(
                'Inicializando bóveda cero-conocimiento...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return const WelcomeScreen();
  }
}
