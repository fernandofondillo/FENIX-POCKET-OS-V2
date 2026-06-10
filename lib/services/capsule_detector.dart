// lib/services/capsule_detector.dart
import 'package:logger/logger.dart';

final Logger _logger = Logger();

/// Escáner heurístico NLP (On-Device) que decide de manera instantánea 
/// qué "Cápsula de Experto" debe asumir la conversación antes de armar 
/// el Payload REST hacia FastAPI.
class CapsuleDetector {
  static const Map<String, List<String>> _diccionario_lexico = {
    'fitness_expert': ['entrenamiento', 'gimnasio', 'pesas', 'cardio', 'músculo', 'músculos', 'lesión', 'rutina', 'ejercicio', 'hipertrofia'],
    'nutricion_expert': ['dieta', 'calorías', 'proteínas', 'comida', 'ayuno', 'suplementos', 'peso', 'keto', 'nutrición', 'macros'],
    'zen_mentor': ['ansiedad', 'estrés', 'meditación', 'paz', 'relax', 'respiración', 'emociones', 'estoicismo', 'calma', 'depresión'],
    'elderly_care': ['abuelos', 'tensión', 'pastillas', 'memoria', 'articulaciones', 'médico', 'cuidador', 'salud mayor', 'alzheimer'],
    'biohacking_expert': ['nootrópicos', 'vo2', 'longevidad', 'sueño', 'rem', 'dopamina', 'testosterona', 'ritmo circadiano', 'ayuno', 'hielo'],
    'pro_work_assistant': ['código', 'reunión', 'excel', 'email', 'jefe', 'productividad', 'startup', 'finanzas', 'proyecto', 'deadline']
  };

  /// Analiza el mensaje emitido por el usuario mediante un recuento frecuencial de palabras clave (Bag-of-Words ligero).
  static String detectar_capsula(String texto_usuario) {
    if (texto_usuario.trim().isEmpty) return 'general_coordinator';

    // Normalizado básico: a minúsculas y eliminación de signos de puntuación pesados
    final palabras_limpias = texto_usuario.toLowerCase().replaceAll(RegExp(r'[^\w\sáéíóúüñ]'), '').split(' ');
    
    Map<String, int> puntuaciones = {
      for (var k in _diccionario_lexico.keys) k: 0
    };

    // Puntuación: +1 por cada "exact match" léxico
    for (var palabra in palabras_limpias) {
      for (var entrada in _diccionario_lexico.entries) {
        if (entrada.value.contains(palabra)) {
          puntuaciones[entrada.key] = puntuaciones[entrada.key]! + 1;
        }
      }
    }

    String capsule_ganadora = 'general_coordinator';
    int max_puntuacion = 0;

    puntuaciones.forEach((key, valor) {
      if (valor > max_puntuacion) {
        max_puntuacion = valor;
        capsule_ganadora = key;
      }
    });

    // Evaluamos el umbral mínimo de confianza para abandonar el fallback general
    if (max_puntuacion >= 1) {
       _logger.i('[ROUTING] Enrutamiento Cognitivo delegado a: $capsule_ganadora (Score: $max_puntuacion)');
       return capsule_ganadora;
    } else {
       _logger.i('[ROUTING] Intención difusa o ambigua. Empleando fallback: general_coordinator.');
       return 'general_coordinator';
    }
  }
}
