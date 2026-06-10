// lib/views/chat/chat_screen.dart
//
// ✅ FIX CTO: ChatScreen REAL integrado con api_service + skills_service.
// Acepta input del usuario, envía al backend FastAPI, renderiza la respuesta
// y muestra skills ejecutadas.
//
// Tipos: usa PayloadRequest/RagContext/CapsulaActiva/ChatMessage
//        del nuevo models/payload_request.dart (snake_case estricto,
//        sincronizado con /root/agos-backend/app/schemas/chat_schema.py).
//
// Autor: Líder CTO | Fecha: 2026-06-10

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/api_service.dart';
import '../../services/capsule_detector.dart';
import '../../services/memory_service.dart';
import '../../services/skills_service.dart';
import '../../services/perfil_db_service.dart';
import '../../models/payload_request.dart';
import '../auth/welcome_screen.dart' show WelcomeScreen; // Para navegación de vuelta

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _api = ApiService(
    baseUrl: 'https://roguish-degradedly-anjelica.ngrok-free.app',
  );
  final _memory = MemoryService();
  final _skills = SkillsService(
    baseUrl: 'https://roguish-degradedly-anjelica.ngrok-free.app',
  );
  final _storage = const FlutterSecureStorage();
  final _db = PerfilDbService();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  String _userId = 'unknown';

  // System prompts de las 7 cápsulas (extraídos de capsule_routing.json)
  static const Map<String, String> _capsuleSystemPrompts = {
    'fitness_expert': 'Eres Carlos, entrenador personal biomecánico certificado. Tu enfoque es seguridad lumbar, técnica limpia, y progresión sostenible. Si el usuario reporta dolor, detén la progresión y propone descarga activa. Si pide nutrición, redirige a Dra. Sofía. Habla con autoridad técnica pero cercana. Máximo 250 palabras.',
    'nutricion_expert': 'Eres la Dra. Sofía, nutricionista especializada en cetosis y ayuno intermitente. Tu enfoque es evidencia científica, nunca moda. Si el usuario menciona patología, pregunta por su médico antes de aconsejar. Habla con precisión bioquímica pero sin jerga innecesaria. Si pide entrenamiento, redirige a Carlos. Máximo 250 palabras.',
    'zen_mentor': 'Eres Aurelio, mentor estoico. Tu enfoque es resiliencia, foco, y aceptación activa. Si el usuario está en crisis, sugiere profesional. Si pide físico, redirige a Carlos o Sofía. Máximo 250 palabras.',
    'elderly_care': 'Eres Mateo, asistente de cuidado geriátrico. Tu enfoque es acompañamiento empático, adherencia a medicación, y alertas de seguridad. SIEMPRE recuerda que no sustituyes al médico. Habla con paciencia. Máximo 250 palabras.',
    'biohacking_expert': 'Eres Dr. Lex, médico biohacker con foco en longevidad saludable. Tu enfoque es evidencia + experimentación controlada. Distingues: "esto tiene RCTs sólidos" vs "esto es experimental". Máximo 250 palabras.',
    'pro_work_assistant': 'Eres Elena, asistente de productividad. Tu enfoque es ejecución: menos reunión, más shipping. Usas frameworks: GTD, Pomodoro, Deep Work, Eisenhower. Si el usuario procrastina, le das UN paso concreto. Máximo 250 palabras.',
    'general_coordinator': 'Eres Fénix, el coordinador general. Tu rol es entender la intención y redirigir a una cápsula especializada. Respondes con calidez y brevedad. Máximo 250 palabras.',
  };

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _memory.init_memory();
    final uid = await _storage.read(key: 'user_id') ?? 'unknown';
    setState(() => _userId = uid);

    // Mensaje de bienvenida
    setState(() {
      _messages.add(_ChatMessage(
        role: 'assistant',
        content: '[CORE_SYNC_OK] Bóveda conectada. Soy Fénix, tu agente de inteligencia soberana. ¿Sobre qué vector operamos?',
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Detectar cápsula
    final capsuleId = CapsuleDetector.detectar_capsula(text);
    final capsuleSystemPrompt = _capsuleSystemPrompts[capsuleId] ??
        _capsuleSystemPrompts['general_coordinator']!;

    // Obtener perfil identidad (como String denso, snake_case listo)
    final identidad = await _db.obtenerIdentidad();
    final perfilIdentidadStr = identidad.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    // Historial reciente (FIFO 8) → List<ChatMessage>
    final historialRaw = _memory.obtener_memoria_inmediata();
    final historialMessages = historialRaw
        .map((m) => ChatMessage(
              role: (m['role'] ?? 'user').toString(),
              content: (m['content'] ?? '').toString(),
            ))
        .toList();

    // Construir payload snake_case con tipos correctos
    const allowedSkills = [
      'agenda_crear', 'notificacion_enviar', 'web_search',
      'memoria_recordar', 'memoria_olvidar',
    ];
    final payload = PayloadRequest(
      userId: _userId,
      mensajeActual: text,
      perfilIdentidad: perfilIdentidadStr,
      contextoRagHibrido: const RagContext(
        historialUsuario: '',
        conocimientoExperto: '',
      ),
      capsulaActiva: CapsulaActiva(
        id: capsuleId,
        systemPrompt: capsuleSystemPrompt,
        allowedSkills: _skills.listar_habilidades_permitidas(allowedSkills),
      ),
      activeSkills: allowedSkills,
      historialReciente: historialMessages,
    );

    // Guardar en memoria inmediata
    _memory.agregar_mensaje_inmediato('user', text);

    try {
      // Llamar backend (a través de ngrok → VPS :8000)
      // ApiService ya hace long-polling internamente: POST → 202 → GET task hasta completed
      final response = await _api.enviar_mensaje_con_polling(payload);

      // Parsear respuesta
      final cleanText =
          response['assistant_response']?.toString() ?? 'Sin respuesta';
      final skills =
          (response['executed_skills'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
      final perfilUpdateRaw =
          (response['perfil_update'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();

      setState(() {
        _messages.add(_ChatMessage(
          role: 'assistant',
          content: cleanText,
          timestamp: DateTime.now(),
          executedSkills: skills,
          perfilUpdates: perfilUpdateRaw,
        ));
      });

      // Guardar respuesta en memoria
      _memory.agregar_mensaje_inmediato('assistant', cleanText);

      // Aplicar mutaciones EAV en SQLite local
      for (final mutation in perfilUpdateRaw) {
        final cat = mutation['categoria']?.toString() ?? 'general';
        final clave = mutation['clave']?.toString() ?? '';
        final valor = mutation['valor']?.toString() ?? '';
        if (clave.isNotEmpty && valor.isNotEmpty) {
          await _db.upsertEav(cat, clave, valor);
        }
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'assistant',
          content: 'Error de conexión con la matriz cognitiva: $e',
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_moon_outlined, color: Color(0xFF4C8CFA)),
            const SizedBox(width: 8),
            const Text(
              'Fénix Pocket OS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 18, color: Colors.white54),
            onPressed: () async {
              await _storage.delete(key: 'user_id');
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF13131A),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF4C8CFA),
              backgroundColor: Color(0xFF1A1A24),
            ),
          _InputBar(
            controller: _inputController,
            onSend: _sendMessage,
            enabled: !_isLoading,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final List<Map<String, dynamic>> executedSkills;
  final List<Map<String, dynamic>> perfilUpdates;
  _ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.executedSkills = const [],
    this.perfilUpdates = const [],
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF4C8CFA) : const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(16).copyWith(
              topRight: Radius.circular(isUser ? 4 : 16),
              topLeft: Radius.circular(isUser ? 16 : 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (message.executedSkills.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...message.executedSkills.map((s) => _SkillChip(skill: s)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final Map<String, dynamic> skill;
  const _SkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    final success = skill['result']?['success'] ?? false;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: success ? const Color(0xFF0F4C2E) : const Color(0xFF4C0F1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${success ? '✅' : '❌'} ${skill['skill_name']}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: const BoxDecoration(color: Color(0xFF0D0D12)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Integra comando léxico...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              icon: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: enabled ? onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}
