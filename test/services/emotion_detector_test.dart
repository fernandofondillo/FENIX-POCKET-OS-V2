import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/emotion_detector.dart';

void main() {
  group('EmotionDetector Unit Tests (A.G.O.S)', () {
    test('Detección algorítmica y ponderada de 5 vectores emocionales', () async {
      final detector = EmotionDetector();
      await detector.init(); // Levanta el json léxico fallback en ambiente Test
      
      final feliz = await detector.detectar_emocion('estoy muy motivado victoria increible');
      expect(feliz['emocion'], 'alegria');
      expect(feliz['intensidad'] > 0, true);

      final triste = await detector.detectar_emocion('depresion estoy llorar solo vacio');
      expect(triste['emocion'], 'tristeza');
      expect(triste['intensidad'] < 0, true);

      final furioso = await detector.detectar_emocion('estoy harto inutil odio todo esto mal');
      expect(furioso['emocion'], 'frustracion');
      expect(furioso['intensidad'] < 0, true);

      final miedo = await detector.detectar_emocion('ansiedad estres futuro insomnio y miedo');
      expect(miedo['emocion'], 'ansiedad');
      expect(miedo['intensidad'] < 0, true);
      
      final neutral = await detector.detectar_emocion('cuanto cuestan las llantas');
      expect(neutral['emocion'], 'neutral');
    });
  });
}
