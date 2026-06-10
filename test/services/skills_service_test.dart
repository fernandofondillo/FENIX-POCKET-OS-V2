import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/skills_service.dart';

void main() {
  group('SkillsService Mobile Unit Test (A.G.O.S)', () {
    test('1. Filtro Cognitivo Dinámico', () {
      final service = SkillsService(baseUrl: 'http://localhost');
      
      // Injectamos cápsula con permisos limitados
      final permisos = ['web_search', 'agenda_crear'];
      final disponibles = service.listar_habilidades_permitidas(permisos);
      
      expect(disponibles.length, 2);
      expect(disponibles.contains('web_search'), true);
      expect(disponibles.contains('memoria_recordar'), false);
    });
  });
}
