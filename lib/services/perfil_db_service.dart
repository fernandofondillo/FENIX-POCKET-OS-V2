// lib/services/perfil_db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PerfilDbService {
  Database? _db;

  Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fenix_perfil.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE eav_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoria TEXT NOT NULL,
            clave TEXT UNIQUE NOT NULL,
            valor TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> upsertEav(String categoria, String clave, String valor) async {
    if (_db == null) await initDb();
    await _db!.insert(
      'eav_data',
      {'categoria': categoria, 'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getPerfilCompleto() async {
    if (_db == null) await initDb();
    final List<Map<String, dynamic>> rows = await _db!.query('eav_data');
    if (rows.isEmpty) {
      // Retornar datos base reales si no hay configurado para evitar nulls estructurales
      return {
        'nombre_usuario': 'Operador Zero',
        'profesion_activa': 'N/A',
        'meta_dominante': 'Integración y Hardening de Sistema',
        'config_inicial': 'En Progreso',
        'fecha_onboarding': DateTime.now().toIso8601String().split('T').first
      };
    }
    
    Map<String, dynamic> perfil = {};
    for (var row in rows) {
      perfil[row['clave'] as String] = row['valor'];
    }
    return perfil;
  }
}
