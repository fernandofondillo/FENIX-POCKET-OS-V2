import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/capsule_detector.dart';

void main() {
  group('CapsuleDetector Unit Tests', () {
    test('Validación estructural de enrutamiento a 6 cápsulas y su fallback', () {
      expect(CapsuleDetector.detectar_capsula('mi rutina pesas y músculo'), 'fitness_expert');
      expect(CapsuleDetector.detectar_capsula('mis calorias macros y nutrición keto'), 'nutricion_expert');
      expect(CapsuleDetector.detectar_capsula('algo para la ansiedad, quiero paz y meditación'), 'zen_mentor');
      expect(CapsuleDetector.detectar_capsula('las pastillas para mi abuelo y su memoria'), 'elderly_care');
      expect(CapsuleDetector.detectar_capsula('dopamina ciclo de sueño y ayuno longevidad'), 'biohacking_expert');
      expect(CapsuleDetector.detectar_capsula('tenemos una reunión código deadline finanzas excel'), 'pro_work_assistant');
      
      // Fallback cognitivo en O(n) local
      expect(CapsuleDetector.detectar_capsula('hola ¿qué tal? quiero saber el clima'), 'general_coordinator');
    });
  });
}
