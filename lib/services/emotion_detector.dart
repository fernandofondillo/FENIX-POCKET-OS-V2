import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class EmotionDetector {
  Map<String, dynamic> _emociones_dict = {};
  bool _is_initialized = false;

  Future<void> init() async {
    if (_is_initialized) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/emociones_es.json');
      _emociones_dict = json.decode(jsonString);
      _is_initialized = true;
      _logger.i('[EMOTION_DETECTOR] Diccionario léxico de emociones cargado exitosamente.');
    } catch (e) {
      _logger.e('[EMOTION_DETECTOR_ERROR] Falla al cargar el diccionario de emociones: $e');
      // Diccionario de fallback si el asset no está montado en AI Studio
      _emociones_dict = {
        'frustracion': ['harto', 'imposible', 'inutil', 'cansado', 'bloqueado', 'maldito', 'odio'],
        'ansiedad': ['nervios', 'miedo', 'preocupado', 'taquicardia', 'futuro', 'insomnio', 'estres'],
        'tristeza': ['llorar', 'depresion', 'vacio', 'solo', 'dolor', 'perdida', 'apatico'],
        'alegria': ['feliz', 'genial', 'logro', 'victoria', 'motivado', 'energia', 'increible']
      };
      _is_initialized = true;
    }
  }

  Future<Map<String, dynamic>> detectar_emocion(String texto_usuario) async {
    if (!_is_initialized) await init();

    if (texto_usuario.trim().isEmpty) return {'emocion': 'neutral', 'intensidad': 0.0};

    final palabras_limpias = texto_usuario.toLowerCase().replaceAll(RegExp(r'[^\w\sáéíóúüñ]'), '').split(' ');
    
    Map<String, double> puntuaciones = {
      'frustracion': 0.0,
      'ansiedad': 0.0,
      'tristeza': 0.0,
      'alegria': 0.0
    };

    final Map<String, double> pesos = {
      'frustracion': -0.7,
      'ansiedad': -0.5,
      'tristeza': -0.6,
      'alegria': 0.8
    };

    for (var palabra in palabras_limpias) {
      for (var emocion in _emociones_dict.keys) {
        if (_emociones_dict[emocion] != null && (_emociones_dict[emocion] as List).contains(palabra)) {
          puntuaciones[emocion] = puntuaciones[emocion]! + pesos[emocion]!;
        }
      }
    }

    String emocion_dominante = 'neutral';
    double intensidad_maxima = 0.0;

    puntuaciones.forEach((emocion, acumulado) {
      if (acumulado.abs() > intensidad_maxima.abs() && acumulado != 0) {
        intensidad_maxima = acumulado;
        emocion_dominante = emocion;
      }
    });

    if (intensidad_maxima.abs() > 0.3) {
       _logger.i('[EMOTION] Emoción estructural detectada: $emocion_dominante (Intensidad: $intensidad_maxima)');
       return {
         'emocion': emocion_dominante,
         'intensidad': intensidad_maxima
       };
    }

    return {'emocion': 'neutral', 'intensidad': 0.0};
  }
}
