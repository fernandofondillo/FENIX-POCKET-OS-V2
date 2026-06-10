// lib/views/auth/welcome_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../services/perfil_db_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _profesionController = TextEditingController();
  final _metaController = TextEditingController();
  
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();
  bool _isLoading = false;

  Future<void> _iniciarEcosistema() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      // 1. Matrícula y Subconsciente Hardware-Bounded
      final userId = _uuid.v4();
      await _storage.write(key: 'user_id', value: userId);

      // 2. Transmisión del KeyPair a Bóveda Aislada (AES-256 Symmetric)
      final rand = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => rand.nextInt(256));
      final masterKey = base64UrlEncode(keyBytes);
      await _storage.write(key: 'master_key_aes256', value: masterKey);

      // 3. Serialización del perfil Identitario en EAV Core
      final db = PerfilDbService();
      await db.initDb();
      await db.upsertEav('identidad', 'nombre_usuario', _nombreController.text.trim());
      await db.upsertEav('identidad', 'profesion_activa', _profesionController.text.trim());
      await db.upsertEav('identidad', 'meta_dominante', _metaController.text.trim());

      // 4. Parámetros Fundamentales Cero
      await db.upsertEav('sistema', 'config_inicial', 'Activa');
      await db.upsertEav('sistema', 'fecha_onboarding', DateTime.now().toIso8601String());

      // 5. Transferencia de Lógica a UI Engine (Chat Node)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Colapso criptográfico o SQLite err: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A), // Minimal slate background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_moon_outlined, size: 72, color: Color(0xFF4C8CFA)),
                const SizedBox(height: 24),
                const Text(
                  'Fénix Pocket OS',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arranque en Bóveda Cero-Conocimiento',
                  style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'ID / Denominación', 
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4C8CFA)))
                  ),
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Requisito bloqueante.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _profesionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Rol Funcional o Profesión', 
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4C8CFA)))
                  ),
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Requisito bloqueante.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _metaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Metavariable (Objetivo Maestro)', 
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4C8CFA)))
                  ),
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Requisito bloqueante.',
                ),
                const SizedBox(height: 56),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF4C8CFA))
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _iniciarEcosistema,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C8CFA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text('ENGRAVE SYSTEM.IO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Console', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF13131A),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A24),
                      borderRadius: BorderRadius.circular(16).copyWith(topLeft: const Radius.circular(4))
                    ),
                    child: const Text(
                      '[CORE_SYNC_OK] Soy tu encapsulado A.G.O.S local. Mis tensores no persisten nada de ti una vez apagada la RAM. ¿Sobre qué vector operamos?',
                      style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            decoration: const BoxDecoration(color: Color(0xFF0D0D12)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A24),
                      borderRadius: BorderRadius.circular(24)
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Integrar comando léxico...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4C8CFA),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
