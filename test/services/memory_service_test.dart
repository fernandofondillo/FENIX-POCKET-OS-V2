import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/memory_service.dart';

void main() {
  group('MemoryService Unit Tests', () {
    test('Validación estricta del límite FIFO (8 mensajes)', () async {
      final memory = MemoryService();
      
      for(int i = 0; i < 12; i++) {
        memory.agregar_mensaje_inmediato('user', 'mensaje $i');
      }
      
      final cache = memory.obtener_memoria_inmediata();
      
      expect(cache.length, 8);
      // Validamos que el índice 0 original fue borrado protegiendo la RAM
      expect(cache.first['content'], 'mensaje 4');
      // Validamos que el último sobrevive inalterado
      expect(cache.last['content'], 'mensaje 11');
    });
  });
}
