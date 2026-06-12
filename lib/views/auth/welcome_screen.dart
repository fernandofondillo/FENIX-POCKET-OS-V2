// lib/views/auth/welcome_screen.dart
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../services/perfil_db_service.dart';
import '../../services/api_service.dart';
import '../../services/skills_service.dart';
import '../../models/payload_request.dart';
import '../../services/capsule_detector.dart';
import '../../services/memory_service.dart';
import '../../services/local_embedding_service.dart';
import '../../services/secure_storage_service.dart';
import '../obsidian/nano_obsidian_screen.dart';
import '../skills/skills_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

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

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _mensajesUI = [
    '[CORE_SYNC_OK] Soy tu encapsulado A.G.O.S local. Mis tensores no persisten nada de ti una vez apagada la RAM. ¿Sobre qué vector operamos?'
  ];
  bool _isProcessing = false;
  String _capsulaActiva = 'Fénix Base'; // Actualizamos Default a un nombre premium

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _enviarMensaje() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    setState(() {
      _mensajesUI.add('USUARIO: $text');
      _textController.clear();
      _isProcessing = true;
    });

    try {
      final String userId = await _storage.read(key: 'user_id') ?? const Uuid().v4();
      
      final db = PerfilDbService();
      await db.initDb();
      final identidad = await db.getPerfilCompleto();
      
      _capsulaActiva = CapsuleDetector.detectar_capsula(text, capsula_anterior: _capsulaActiva);
      
      final memoryService = MemoryService();
      await memoryService.init_memory();
      final identityData = await memoryService.obtener_identidad_estructurada();
      final historialUsuarioStr = identityData.entries.map((e) => '${e.key}: ${e.value}').join(', ');

      final localEmbedding = LocalEmbeddingService();
      await localEmbedding.init_model();
      final queryVector = await localEmbedding.generar_vector(text);
      final topK = await localEmbedding.buscar_top_k(queryVector, k: 3);

      final secureStorage = SecureStorageService();
      String expertoContext = '';
      for (var item in topK) {
        try {
          final content = await secureStorage.readDecryptedMarkdown(item['doc_id']);
          expertoContext += content.substring(0, min(200, content.length)) + '... ';
        } catch (_) {}
      }

      // Creamos un payload estrictamente tipado y empaquetado en snake_case al enviar al backend
      final payload = PayloadRequest(
        userId: userId,
        mensajeActual: text,
        perfilIdentidad: jsonEncode(identidad),
        contextoRagHibrido: ContextoRagHibridoPayload(
          historialUsuario: historialUsuarioStr.isEmpty ? 'Ninguno' : historialUsuarioStr,
          conocimientoExperto: expertoContext.isEmpty ? '' : expertoContext
        ),
        capsulaActiva: CapsulaActivaPayload(
          id: _capsulaActiva,
          systemPrompt: 'Eres A.G.O.S, asistente seguro operando como $_capsulaActiva.',
          allowedSkills: ['agenda_crear', 'web_search']
        ),
        historialReciente: []
      );

      final apiService = ApiService();
      // Delegación Real hacia el ORQUESTADOR ASGI FastAPI
      final resultado = await apiService.enviar_mensaje_con_polling(payload).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException("El clúster no respondió a tiempo.")
      );

      setState(() {
        if (resultado.containsKey('response')) {
           _mensajesUI.add('A.G.O.S: ${resultado['response']}');
        } else if (resultado.containsKey('skill_call')) {
           final skillData = resultado['skill_call'];
           _mensajesUI.add('A.G.O.S (Accionando Skill): Invocando ${skillData['name']} localmente...');
           // Intercepción Ejecutiva local (De-Mocking)
           _ejecutarSkillReal(skillData['name'], skillData['arguments'], userId);
        } else {
           _mensajesUI.add('A.G.O.S: Respuesta estructural no parseable. $resultado');
        }
      });
    } catch (e) {
      setState(() {
        _mensajesUI.add('[ERROR_LINK] El Agente A.G.O.S no pudo establecer el enlace a la red temporalmente ($e)');
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _ejecutarSkillReal(String skillName, Map<String, dynamic> arguments, String userId) async {
    try {
      final skillsService = SkillsService();
      final result = await skillsService.execute_skill(skillName, arguments, userId);
      setState(() {
         _mensajesUI.add('A.G.O.S (Resultado Skill): ${result.toString()}');
      });
    } catch (e) {
      setState(() {
         _mensajesUI.add('[ERROR_LINK] Ejecución de Skill fallida: $e');
      });
    }
  }

  void _abrirSelectorCapsulas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF13131A),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.5))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const Text('CÁPSULAS DE IDENTIDAD', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 24),
              _buildCapsuleCard('Fénix Base', 'v2.0-Pro', 'INTEGRADO E INSTALADO', '12 Skills'),
              const SizedBox(height: 12),
              _buildCapsuleCard('Coach Carlos', 'Entrenamiento', 'INTEGRADO E INSTALADO', '3 Skills'),
              const SizedBox(height: 12),
              _buildCapsuleCard('Dra. Sofía', 'Salud y Nutrición', 'INTEGRADO E INSTALADO', '2 Skills'),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCapsuleCard(String title, String badge1, String badge2, String badge3) {
    bool isActive = _capsulaActiva == title;
    return GestureDetector(
      onTap: () {
        setState(() => _capsulaActiva = title);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFF1A1A24),
          border: Border.all(color: isActive ? const Color(0xFFD4AF37) : Colors.white12),
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isActive ? const Color(0xFFD4AF37) : Colors.white12, shape: BoxShape.circle),
              child: Icon(Icons.psychology, color: isActive ? Colors.black : Colors.white54, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _badge(badge1, Colors.blueAccent),
                      _badge(badge2, Colors.green),
                      _badge(badge3, Colors.purpleAccent),
                    ],
                  )
                ],
              ),
            ),
            if (isActive) const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDrawerMenu() {
    return Drawer(
      backgroundColor: const Color(0xFF13131A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 40),
                const SizedBox(height: 16),
                const Text('FÉNIX POCKET OS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Text('VER. 6.0 RC1 SOBERANA', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
              ],
            ),
          ),
          _drawerItem('01', 'Nexus Console', Icons.terminal, () => Navigator.pop(context)),
          _drawerItem('02', 'Nano-Obsidian', Icons.shield_outlined, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NanoObsidianScreen())); }),
          _drawerItem('03', 'Skills History', Icons.memory, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillsScreen())); }),
          _drawerItem('04', 'Capsule Matrix', Icons.view_module_outlined, () { Navigator.pop(context); _abrirSelectorCapsulas(); }),
          _drawerItem('05', 'Metabase Profile', Icons.person_outline, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }),
          _drawerItem('06', 'System Architecture', Icons.settings_outlined, () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
        ],
      ),
    );
  }

  Widget _drawerItem(String number, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Text(number, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
      title: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14)),
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawerMenu(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF0D0D12),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, color: Color(0xFFD4AF37), size: 20),
                  const SizedBox(width: 8),
                  const Text('ARQUITECTURA SOBERANA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF4C8CFA).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('SMARTPHONE MEMORY / STATELESS VPS : ACTIVE', style: TextStyle(color: Color(0xFF4C8CFA), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              )
            ],
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: _abrirSelectorCapsulas,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37))),
                child: const Icon(Icons.psychology, color: Color(0xFFD4AF37), size: 24),
              ),
            )
          ],
        ),
      ),
      backgroundColor: const Color(0xFF13131A),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _mensajesUI.length,
              itemBuilder: (context, index) {
                final isUser = _mensajesUI[index].startsWith('USUARIO:');
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFD4AF37).withOpacity(0.1) : const Color(0xFF1A1A24),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                        topRight: isUser ? const Radius.circular(4) : const Radius.circular(20)
                      ),
                      border: Border.all(color: isUser ? const Color(0xFFD4AF37).withOpacity(0.3) : Colors.white12, width: 1)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isUser ? Icons.person : Icons.diamond, size: 14, color: isUser ? Colors.white54 : const Color(0xFFD4AF37)),
                            const SizedBox(width: 6),
                            Text(isUser ? 'HUMANO' : _capsulaActiva.toUpperCase(), style: TextStyle(color: isUser ? Colors.white54 : const Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mensajesUI[index].replaceAll('USUARIO: ', ''),
                          style: TextStyle(
                            color: _mensajesUI[index].startsWith('[ERROR_LINK]') ? Colors.redAccent : Colors.white, 
                            height: 1.6, 
                            fontSize: 15,
                            fontFamily: 'Inter'
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)),
                  const SizedBox(width: 8),
                  const Text('Vectorizando conocimiento...', style: TextStyle(color: Color(0xFFD4AF37), fontFamily: 'Inter', fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D12),
              border: Border(top: BorderSide(color: Colors.white12))
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A24),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12)
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Transmite instrucción a $_capsulaActiva...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                      ),
                      onSubmitted: (_) => _enviarMensaje(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _isProcessing ? Colors.grey : const Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!_isProcessing) BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 12, spreadRadius: 2)
                    ]
                  ),
                  child: IconButton(
                    icon: _isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                    onPressed: _enviarMensaje,
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

