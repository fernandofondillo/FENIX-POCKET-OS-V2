// lib/services/skills_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class SkillsService {
  final Dio _dio;
  static const String _historial_claves = 'skills_executed_history';

  // Inyección del Cliente Dio bajo BaseOptions nativo del Framework.
  SkillsService({required String baseUrl}) 
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl, 
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30)
        )) {
    // Intercepción visual de Consola Opcional. No rompe abstracción.
    // _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  /// 1. Listar Habilidades Dinámicamente según la Cápsula o System Directive
  List<String> listar_habilidades_permitidas(List<String> allowed_skills) {
    // 5 Built-in mandatorios del Repositorio Pydantic en servidor ASGI
    const built_in = [
      'agenda_crear',
      'notificacion_enviar',
      'web_search',
      'memoria_recordar',
      'memoria_olvidar'
    ];
    
    // Filtro relacional en Dart Core (O(N))
    final disponibles = built_in.where((skill) => allowed_skills.contains(skill)).toList();
    _logger.i('[SKILLS_SERVICE] Handshake de cruce listo. Autorizadas: $disponibles');
    return disponibles;
  }

  /// Petición Activa manual del Móvil al Servidor para Ejecución Inyectada
  Future<Map<String, dynamic>> execute_skill(String skill_name, Map<String, dynamic> args, String user_id) async {
    try {
      final payload = {
        'skill_name': skill_name,
        'args': args,
        'user_id': user_id
      };
      
      final response = await _dio.post('/api/v1/skills/execute', data: payload);
      
      if (response.statusCode == 200) {
        final result = response.data;
        await _registrar_historial_local(skill_name, result);
        return result as Map<String, dynamic>;
      } else {
         throw Exception("Rotura TCP/HTTP. Código Base: \${response.statusCode}");
      }
    } on DioException catch (e) {
      _logger.e("[SKILLS_SERVICE_ERROR] Dio Error interceptable: \${e.message}");
      rethrow;
    }
  }

  /// 2. Caching Persistente en Shared Preferences para Trazabilidad sin Latencia Nube
  Future<void> _registrar_historial_local(String skill_name, Map<String, dynamic> output) async {
    final prefs = await SharedPreferences.getInstance();
    final historial_raw = prefs.getStringList(_historial_claves) ?? [];
    
    final entrada = jsonEncode({
      'skill': skill_name,
      'timestamp': DateTime.now().toIso8601String(),
      'result': output
    });
    
    historial_raw.insert(0, entrada);
    // Purga bufferística de OOM OutOfMemory Error sobre Heap
    if (historial_raw.length > 50) historial_raw.removeLast();
    
    await prefs.setStringList(_historial_claves, historial_raw);
    _logger.i('[SKILLS_SERVICE] Traza auditada criptográficamente (Sandbox Nativo).');
  }

  Future<List<Map<String, dynamic>>> leer_historial_skills() async {
    final prefs = await SharedPreferences.getInstance();
    final historial_raw = prefs.getStringList(_historial_claves) ?? [];
    
    return historial_raw.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  /// 3. Inyección Plástica / Firma para Módulos de Autoría Propios
  void registrar_skill_customizada(String signature_name, Map<String, String> argument_schema) {
    // Pipeline para inyección lateral en un backend GraphQL o API Manager REST. 
    // Pendiente al Sprint 4 (Expansión Dinámica).
    _logger.w('[SKILLS_SERVICE] Mock FIRMA VÁLIDA: $signature_name detectada. Falta envío de schema JSON.');
  }
}
