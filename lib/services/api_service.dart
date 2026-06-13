// lib/services/api_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/payload_request.dart';
import '../core/app_config.dart';

/// Servicio robusto encargado de dialogar con el VPS backend bajo el nuevo paradigma
/// de Arquitectura Orientada a Eventos (Redis + Arq).
class ApiService {
  final String _base_url = AppConfig.apiBaseUrl;

  /// Envía el payload denso al Endpoint Ingestor No-Bloqueante (Event-Driven).
  /// Captura el `task_id` y delega la responsabilidad a un ciclo automatizado de Long-Polling.
  Future<Map<String, dynamic>> enviar_mensaje_con_polling(PayloadRequest payload) async {
    final String url_ingesta = '$_base_url/api/v1/chat';
    
    print("[API_SERVICE] Despachando ráfaga hacia el Ingestor de VPS: $url_ingesta");

    try {
      final respuesta_ingesta = await http.post(
        Uri.parse(url_ingesta),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload.toJson()),
      );

      // El servidor de FastAPI nos debe responder con 202 (Accepted) y encolarlo
      if (respuesta_ingesta.statusCode == 202) {
        final Map<String, dynamic> datos_ingesta = jsonDecode(respuesta_ingesta.body);
        
        if (datos_ingesta['status'] == 'queued' && datos_ingesta.containsKey('task_id')) {
          final String task_id = datos_ingesta['task_id'];
          print("[API_SERVICE] Tarea encolada en Redis con éxito. Task ID: $task_id");
          
          return await _iniciar_bucle_de_polling_automata(task_id);
        } else {
           throw Exception("Respuesta anómala del ingestor 202: ${respuesta_ingesta.body}");
        }
      } else {
        throw Exception("Fallo en la comunicación principal. Código HTTP: ${respuesta_ingesta.statusCode}");
      }
    } catch (excepcion_red) {
      print("[API_SERVICE_ERROR] Error crítico en la transmisión del payload: $excepcion_red");
      rethrow;
    }
  }

  /// Ejecuta un ciclo continuo de consultas de alta frecuencia cada 800ms limitando las requests
  /// con un máximo de tiempo de espera (Timeout de 30 segundos)
  /// para impedir la congelación de la promesa principal y recuperar el output del Worker procesado.
  Future<Map<String, dynamic>> _iniciar_bucle_de_polling_automata(String taskId) async {
    final String url_polling = '$_base_url/api/v1/task/$taskId';
    final int intervalo_polling_ms = 800; // 800 milisegundos de frecuencia de interrogación
    final int timeout_segundos = 30;     // Evita la congestión con bucles infinitos en el Frontend
    
    DateTime tiempo_inicio = DateTime.now();

    while (true) {
      // 1. Condición de Evasión (Timeout)
      if (DateTime.now().difference(tiempo_inicio).inSeconds > timeout_segundos) {
         print("[API_SERVICE_TIMEOUT] Se excedió el tiempo máximo de espera para la tarea: $taskId");
         throw Exception("Tiempo de espera agotado. El modelo del VPS está saturado o fuera de línea.");
      }

      try {
        final respuesta_polling = await http.get(Uri.parse(url_polling));

        if (respuesta_polling.statusCode == 200) {
          final Map<String, dynamic> datos_polling = jsonDecode(respuesta_polling.body);
          final String estado = datos_polling['status'];

          // 2. Transmisión Completada
          if (estado == 'completed' && datos_polling.containsKey('result')) {
            print("[API_SERVICE] Tarea completada. Recepción encriptada entregada y borrada paralelamente en Servidor.");
            final Map<String, dynamic> data = datos_polling['result'] as Map<String, dynamic>;
            
            final String respuestaText = data['assistant_response']?.toString() ?? '';
            final List<dynamic> executedSkills = data['executed_skills'] as List<dynamic>? ?? [];
            final List<dynamic> perfilUpdate = data['perfil_update'] as List<dynamic>? ?? [];

            // Si existen skills ejecutadas, reportamos el skill call
            if (executedSkills.isNotEmpty) {
               return {
                 'skill_call': {
                   'name': executedSkills.first['skill_name'] ?? executedSkills.first['name'] ?? 'Unknown',
                   'arguments': executedSkills.first['arguments'] ?? {}
                 }
               };
            }
            
            // Retorna limpiamente con la llave 'response' esperada por el UI
            return {'response': respuestaText};
          } 
          // 3. Proceso en Continuo
          else if (estado == 'processing' || estado == 'queued') {
            // El modelo de IA local sigue evaluando parámetros, silenciamos el log de terminal.
            // print("La Cápsula Fénix procesando entorno... (Estado actual: $estado)");
          } 
          // 4. Fallos desde Python
          else if (estado == 'error') {
             throw Exception("Error fatal en el Worker de Python para la Tarea (Arq): $taskId");
          } else {
            print("[API_SERVICE_WARNNING] Estado infra-estructural desconocido en el Polling: $estado");
          }
        } else {
          throw Exception("Fallo intermedio en el servicio de Long-Polling HTTP: ${respuesta_polling.statusCode}");
        }
      } catch (excepcion_temporal) {
        // En caso de que haya una interrupción temporal de red en un solo ciclo de polling
        print("[API_SERVICE_REINTENTO] Fallo de red temporal evaluando el task $taskId: $excepcion_temporal");
      }

      // 5. Suspensión del hilo asíncrono temporal para espaciar las requests a Hostinger.
      await Future.delayed(Duration(milliseconds: intervalo_polling_ms));
    }
  }

  /// Ejecuta skills manuales de forma síncrona
  Future<Map<String, dynamic>> ejecutar_skill(String skillName, Map<String, dynamic> arguments) async {
    final String url_skills = '$_base_url/api/v1/skills/execute';
    
    try {
      final respuesta = await http.post(
        Uri.parse(url_skills),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'skill_name': skillName,
          'arguments': arguments
        }),
      );

      if (respuesta.statusCode == 200) {
        return jsonDecode(respuesta.body);
      } else {
        throw Exception("Error al ejecutar skill. HTTP: ${respuesta.statusCode}");
      }
    } catch (e) {
      print("[API_SERVICE_ERROR] Error ejecutando skill: $e");
      rethrow;
    }
  }

  /// Endpoint de consolidación para unificar perfiles o vectorización batch
  Future<Map<String, dynamic>> consolidar_perfil(Map<String, dynamic> datos) async {
    final String url_consolidate = '$_base_url/api/v1/consolidate';
    
    try {
      final respuesta = await http.post(
        Uri.parse(url_consolidate),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(datos), // Debe respetar `snake_case` desde el invocador
      );

      if (respuesta.statusCode == 200) {
        return jsonDecode(respuesta.body);
      } else {
        throw Exception("Error consolidando perfil. HTTP: ${respuesta.statusCode}");
      }
    } catch (e) {
      print("[API_SERVICE_ERROR] Error en consolidación: $e");
      rethrow;
    }
  }
}
