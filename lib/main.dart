// lib/main.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'views/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Opcional: Aquí se inicializarían configuraciones globales, 
  // lectura de dotenv, o la inyección de dependencias como PushService.
  
  runApp(const FenixPocketOsApp());
}

class FenixPocketOsApp extends StatelessWidget {
  const FenixPocketOsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fénix Pocket OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4C8CFA),
        scaffoldBackgroundColor: const Color(0xFF13131A),
        fontFamily: 'Inter', // Opcional, asumiendo una fuente por defecto
      ),
      home: const WelcomeScreen(),
    );
  }
}
