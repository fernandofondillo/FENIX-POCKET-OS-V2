// lib/services/capsule_detector.dart
import 'package:logger/logger.dart';

final Logger _logger = Logger();

/// Escáner heurístico NLP (On-Device) que decide de manera instantánea 
/// qué "Cápsula de Experto" debe asumir la conversación antes de armar 
/// el Payload REST hacia FastAPI.
class CapsuleDetector {
  static const Map<String, Map<String, int>> _diccionario_ponderado = {
    'fitness_expert': {'entrenamiento': 2, 'gimnasio': 2, 'pesas': 2, 'cardio': 1, 'músculo': 2, 'músculos': 2, 'lesión': 1, 'rutina': 2, 'ejercicio': 1, 'hipertrofia': 3},
    'nutricion_expert': {'dieta': 2, 'calorías': 2, 'proteínas': 2, 'comida': 1, 'ayuno': 1, 'suplementos': 2, 'peso': 1, 'keto': 3, 'nutrición': 2, 'macros': 3},
    'zen_mentor': {'ansiedad': 3, 'estrés': 3, 'meditación': 2, 'paz': 1, 'relax': 1, 'respiración': 2, 'emociones': 2, 'estoicismo': 3, 'calma': 1, 'depresión': 3},
    'elderly_care': {'abuelos': 2, 'tensión': 2, 'pastillas': 2, 'memoria': 1, 'articulaciones': 2, 'médico': 2, 'cuidador': 3, 'salud mayor': 3, 'alzheimer': 3},
    'biohacking_expert': {'nootrópicos': 3, 'vo2': 3, 'longevidad': 2, 'sueño': 2, 'rem': 2, 'dopamina': 2, 'testosterona': 2, 'ritmo circadiano': 3, 'ayuno': 2, 'hielo': 2},
    'pro_work_assistant': {'código': 2, 'reunión': 2, 'excel': 2, 'email': 1, 'jefe': 2, 'productividad': 3, 'startup': 3, 'finanzas': 2, 'proyecto': 2, 'deadline': 3}
  };

  /// Jerarquía por defecto para tiebreakers (Desempate)
  static const List<String> _jerarquia_default = [
    'general_coordinator',
    'zen_mentor',
    'pro_work_assistant',
    'fitness_expert',
    'nutricion_expert',
    'biohacking_expert',
    'elderly_care'
  ];

  /// Analiza el mensaje emitido por el usuario mediante recuento con pesos.
  static String detectar_capsula(String texto_usuario, {String capsula_anterior = 'general_coordinator'}) {
    if (texto_usuario.trim().isEmpty) return 'general_coordinator';

    // Normalizado básico: a minúsculas y eliminación de signos de puntuación pesados
    final palabras_limpias = texto_usuario.toLowerCase().replaceAll(RegExp(r'[^\w\sáéíóúüñ]'), '').split(' ');
    
    Map<String, int> puntuaciones = {
      for (var k in _diccionario_ponderado.keys) k: 0
    };

    // Puntuación: por cada "exact match" léxico suma su peso
    for (var palabra in palabras_limpias) {
      for (var entrada in _diccionario_ponderado.entries) {
        if (entrada.value.containsKey(palabra)) {
          puntuaciones[entrada.key] = puntuaciones[entrada.key]! + entrada.value[palabra]!;
        }
      }
    }

    // Aportamos un leve bonus de continuidad (+1) si no es general_coordinator
    if (capsula_anterior != 'general_coordinator' && puntuaciones.containsKey(capsula_anterior)) {
       puntuaciones[capsula_anterior] = puntuaciones[capsula_anterior]! + 1;
    }

    List<String> candidatas = [];
    int max_puntuacion = 0;

    puntuaciones.forEach((key, valor) {
      if (valor > max_puntuacion) {
        max_puntuacion = valor;
        candidatas = [key];
      } else if (valor == max_puntuacion && valor > 0) {
        candidatas.add(key);
      }
    });

    // Evaluamos el umbral mínimo de confianza para abandonar el fallback general
    if (max_puntuacion < 2) { 
       _logger.i('[ROUTING] Intención difusa o ambigua. Empleando fallback: general_coordinator.');
       return 'general_coordinator';
    }

    String capsule_ganadora = candidatas.first;

    // Tiebreaker si hay empate (> 1 candidata)
    if (candidatas.length > 1) {
      if (candidatas.contains(capsula_anterior)) {
        capsule_ganadora = capsula_anterior;
      } else {
        // Buscar por jerarquía
        for (var caps in _jerarquia_default) {
           if (candidatas.contains(caps)) {
             capsule_ganadora = caps;
             break;
           }
        }
      }
      _logger.i('[ROUTING] Empate resuelto ($candidatas). Ganadora: $capsule_ganadora');
    }

    _logger.i('[ROUTING] Enrutamiento Cognitivo delegado a: $capsule_ganadora (Score: $max_puntuacion)');
    return capsule_ganadora;
  }
}
