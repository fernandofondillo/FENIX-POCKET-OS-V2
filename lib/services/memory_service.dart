// lib/services/memory_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final Logger _logger = Logger();

/// Gestiona la jerarquía de retención cognitiva del agente A.G.O.S.
/// Nivel 1: Memoria Inmediata (RAM)
/// Nivel 2: Memoria de Identidad (SQLite EAV)
/// Nivel 3: Memoria a Largo Plazo (Archivos AES-256 en Sandbox Móvil)
class MemoryService {
  // --- Nivel 1: Memoria Inmediata (RAM) ---
  final List<Map<String, String>> _memoria_inmediata = [];
  static const int _limite_inmediata = 8; // Mantenemos el buffer pequeño para no quemar el VPS

  // --- Nivel 2: Memoria de Identidad (SQLite) ---
  Database? _db_identidad;

  // --- Nivel 3: Memoria a Largo Plazo (Bóveda SQLite / Archivos) ---
  final FlutterSecureStorage _secure_storage = const FlutterSecureStorage();
  encrypt.Encrypter? _encrypter;
  encrypt.IV? _iv;

  Future<void> init_memory() async {
    await _init_sqlite_identity();
    await _init_long_term_crypto();
  }

  // ==============================================
  // NIVEL 1: Memoria Efímera
  // ==============================================
  void agregar_mensaje_inmediato(String rol, String contenido) {
    if (_memoria_inmediata.length >= _limite_inmediata) {
      _memoria_inmediata.removeAt(0); // Elimina el más antiguo estructurando FIFO
    }
    _memoria_inmediata.add({'role': rol, 'content': contenido});
  }

  List<Map<String, String>> obtener_memoria_inmediata() => List.unmodifiable(_memoria_inmediata);

  void limpiar_memoria_inmediata() {
    _memoria_inmediata.clear();
  }

  // ==============================================
  // NIVEL 2: Identidad SQLite (Mutación vía <perfil_update>)
  // ==============================================
  Future<void> _init_sqlite_identity() async {
    final db_path = await getDatabasesPath();
    final path = join(db_path, 'identidad_evolutiva.db');

    _db_identidad = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE identidad_eav (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoria TEXT NOT NULL,
            clave TEXT UNIQUE NOT NULL,
            valor TEXT NOT NULL,
            ultima_actualizacion TEXT NOT NULL
          )
        ''');
        _logger.i('[MEMORY_LEVEL_2] Base de datos de Identidad (EAV) SQLite instanciada.');
      },
    );
  }

  Future<void> procesar_perfil_update(Map<String, dynamic> update_json) async {
    if (_db_identidad == null) return;
    
    try {
      final categoria = update_json['categoria'] ?? 'GENERAL';
      final clave = update_json['clave'];
      final valor = update_json['valor'];
      final accion = update_json['accion'] ?? 'upsert';

      if (accion == 'delete') {
        await _db_identidad!.delete('identidad_eav', where: 'clave = ?', whereArgs: [clave]);
        _logger.w('[MEMORY_LEVEL_2] Clave de identidad eliminada pacíficamente: $clave');
      } else {
        await _db_identidad!.insert(
          'identidad_eav',
          {
            'categoria': categoria,
            'clave': clave,
            'valor': valor,
            'ultima_actualizacion': DateTime.now().toIso8601String()
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        _logger.i('[MEMORY_LEVEL_2] Identidad EAV Mutada al Vuelo: $clave -> $valor');
      }
    } catch (e) {
      _logger.e('[MEMORY_LEVEL_2_ERROR] Falla al mutar Identidad EAV: $e');
    }
  }

  Future<Map<String, String>> obtener_identidad_estructurada() async {
    if (_db_identidad == null) return {};
    final records = await _db_identidad!.query('identidad_eav');
    Map<String, String> identity = {};
    for (var record in records) {
      identity[record['clave'] as String] = record['valor'] as String;
    }
    return identity;
  }

  // ==============================================
  // NIVEL 3: Largo Plazo (Archivos AES-256 GCM)
  // ==============================================
  Future<void> _init_long_term_crypto() async {
    String? base64_key = await _secure_storage.read(key: 'master_key_aes256');
    if (base64_key == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      base64_key = key.base64; // base64 encode
      await _secure_storage.write(key: 'master_key_aes256', value: base64_key);
    }

    final key = encrypt.Key.fromBase64(base64_key);
    // Para simplificación algorítmica en Dart usamos Vector Estático para pruebas, 
    // en prod se empaqueta junto al cipher-text.
    _iv = encrypt.IV.fromLength(16); 
    _encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
  }

  Future<void> guardar_documento_largo_plazo(String sub_directorio, String nombre_archivo, String contenido) async {
    if (_encrypter == null || _iv == null) return;

    final encrypted = _encrypter!.encrypt(contenido, iv: _iv!);
    final app_dir = await getApplicationDocumentsDirectory();
    final target_dir = Directory(join(app_dir.path, sub_directorio));
    
    if (!await target_dir.exists()) {
      await target_dir.create(recursive: true);
    }
    
    final file = File(join(target_dir.path, '$nombre_archivo.md.aes'));
    await file.writeAsBytes(encrypted.bytes);
    _logger.i('[MEMORY_LEVEL_3] Archivo cifrado en $sub_directorio/$nombre_archivo');
  }

  Future<String?> leer_documento_largo_plazo(String sub_directorio, String nombre_archivo) async {
     if (_encrypter == null || _iv == null) return null;

     final app_dir = await getApplicationDocumentsDirectory();
     final file = File(join(app_dir.path, sub_directorio, '$nombre_archivo.md.aes'));
     
     if (!await file.exists()) return null;

     final bytes = await file.readAsBytes();
     final encrypted = encrypt.Encrypted(bytes);
     return _encrypter!.decrypt(encrypted, iv: _iv!);
  }
}
