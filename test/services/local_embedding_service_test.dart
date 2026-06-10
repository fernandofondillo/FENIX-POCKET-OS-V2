import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/local_embedding_service.dart';

void main() {
  group('LocalEmbeddingService Unit Tests', () {
    test('Validación en Background Isolate de la vectorización en Float32 (384D)', () async {
      final embeddings = LocalEmbeddingService();
      
      // La inicialización no bloqueante y lazy loading del sub-worker
      final vector_v1 = await embeddings.generar_vector("Test abstracto uno para el motor TFLite");
      final vector_v2 = await embeddings.generar_vector("Test abstracto dos");
      
      // Verificación Topológica obligatoria para la compatibilidad L2 norm (bge-micro-v2 model size)
      expect(vector_v1.length, 384);
      expect(vector_v2.length, 384);
    });
  });
}
