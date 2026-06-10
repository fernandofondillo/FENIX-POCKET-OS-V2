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

  /// Lee todos los EAV con categoria='identidad' y los retorna como Map<clave, valor>.
  /// Usado por el WelcomeScreen para construir el `perfilIdentidad` denso del payload.
  Future<Map<String, String>> obtenerIdentidad() async {
    if (_db == null) await initDb();
    final rows = await _db!.query(
      'eav_data',
      columns: ['clave', 'valor'],
      where: 'categoria = ?',
      whereArgs: ['identidad'],
    );
    return {
      for (final r in rows)
        r['clave'] as String: r['valor'] as String,
    };
  }

  /// Lee TODOS los EAV (para `/api/v1/consolidate`).
  Future<Map<String, String>> obtenerTodo() async {
    if (_db == null) await initDb();
    final rows = await _db!.query('eav_data', columns: ['clave', 'valor']);
    return {
      for (final r in rows)
        r['clave'] as String: r['valor'] as String,
    };
  }

  /// Lee EAV filtrando por categoría.
  Future<Map<String, String>> obtenerPorCategoria(String categoria) async {
    if (_db == null) await initDb();
    final rows = await _db!.query(
      'eav_data',
      columns: ['clave', 'valor'],
      where: 'categoria = ?',
      whereArgs: [categoria],
    );
    return {
      for (final r in rows)
        r['clave'] as String: r['valor'] as String,
    };
  }
}
