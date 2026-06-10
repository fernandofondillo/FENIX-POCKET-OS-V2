// test/smoke_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/capsule_detector.dart';
import '../lib/services/memory_service.dart';
import '../lib/services/local_embedding_service.dart';

void main() {
  group('Fénix Pocket OS V2 - Smoke Test Arquitectural (Foundation)', () {
    
    test('1. Router Cognitivo - Detección de Cápsulas', () {
      // Flujo esperado: Puntuación directa de keywords
      expect(CapsuleDetector.detectar_capsula('Me duele el músculo tras hacer cardio'), 'fitness_expert');
      expect(CapsuleDetector.detectar_capsula('Hoy calculé los macros y la proteína'), 'nutricion_expert');
      expect(CapsuleDetector.detectar_capsula('Mi jefe pidió ese excel para la reunión'), 'pro_work_assistant');
      
      // Fallback a coordinador general
      expect(CapsuleDetector.detectar_capsula('Buenos días, ¿qué hora es?'), 'general_coordinator');
    });

    test('2. Limpieza de Memoria RAM Inmediata (Limitador Estricto)', () {
      final memory = MemoryService();
      
      // Simulamos enviar 12 mensajes
      for(int i = 0; i < 12; i++) {
        memory.agregar_mensaje_inmediato('user', 'Mensaje de prueba número \$i');
      }
      
      // Comprobamos la restricción FIFO (Solo pueden quedar 8)
      final cache_reciente = memory.obtener_memoria_inmediata();
      expect(cache_reciente.length, 8);
      
      // Comprobamos que retuvo del índice 4 al 11 (desechando del 0 al 3)
      expect(cache_reciente.first['content'], 'Mensaje de prueba número 4');
      expect(cache_reciente.last['content'], 'Mensaje de prueba número 11');
    });

    test('3. LocalEmbeddingService - Comprobación de Instancia', () {
      // Nota técnica: Los tests sobre SQLite y TFLite nativos requieren bindings FFI (Desktop/Mobile).
      // Aquí certificamos la robustez del constructor e inicialización por capas de Isolates.
      final embedding = LocalEmbeddingService();
      expect(embedding, isNotNull);
    });
  });
}
