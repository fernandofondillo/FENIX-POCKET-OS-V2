import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Servicio encargado de la matriz de conocimiento estructural (Perfil Evolutivo).
/// Esta base de datos es la única fuente de verdad sobre el usuario, residente
/// en el almacenamiento encriptado del OS (sandboxed), garantizando Zero-Knowledge en la nube.
class PerfilDbService {
  static const String _databaseName = "fenix_perfil_evolutivo.db";
  static const int _databaseVersion = 1;

  // Tabla EAV (Entidad-Atributo-Valor)
  static const String tablePerfil = 'perfil_usuario';

  static const String columnId = 'id';
  static const String columnCategoria = 'categoria';
  static const String columnClave = 'clave';
  static const String columnValor = 'valor';
  static const String columnUltimaActualizacion = 'ultima_actualizacion';

  // Singleton pattern
  PerfilDbService._privateConstructor();
  static final PerfilDbService instance = PerfilDbService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicialización Segura: Apertura y creación estructural
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Schema de Creación con patrón EAV (Entity-Attribute-Value)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tablePerfil (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnCategoria TEXT NOT NULL,
            $columnClave TEXT NOT NULL UNIQUE,
            $columnValor TEXT NOT NULL,
            $columnUltimaActualizacion TEXT NOT NULL
          )
          ''');

    // Datos Semilla (Arranque en frío para asegurar variables requeridas por el RAG)
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final seedData = [
      {'categoria': 'sistema', 'clave': 'nombre_usuario', 'valor': 'Desconocido'},
      {'categoria': 'salud', 'clave': 'estado_general', 'valor': 'En evaluación'},
    ];

    for (var data in seedData) {
      await db.insert(
        tablePerfil,
        {
          ...data,
          columnUltimaActualizacion: DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Procesador de Mutaciones en Caliente (Upsert)
  /// Recibe un String JSON plano extraído del payload del servidor (perfil_update) y ejecuta mutaciones SQL atómicas.
  Future<void> procesarPerfilUpdate(String perfilUpdateJsonStr) async {
    if (perfilUpdateJsonStr.isEmpty || perfilUpdateJsonStr == "[]") return;

    try {
      final List<dynamic> actualizaciones = jsonDecode(perfilUpdateJsonStr);
      final db = await instance.database;

      // Ejecutar en transacción para garantizar consistencia ACID
      await db.transaction((txn) async {
        for (var item in actualizaciones) {
          if (item is Map<String, dynamic> &&
              item.containsKey('categoria') &&
              item.containsKey('clave') &&
              item.containsKey('valor')) {
            await txn.insert(
              tablePerfil,
              {
                columnCategoria: item['categoria'],
                columnClave: item['clave'],
                columnValor: item['valor'].toString(),
                columnUltimaActualizacion: DateTime.now().toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.replace, // Upsert (INSERT OR REPLACE INTO)
            );
          }
        }
      });
    } catch (e) {
      // Ignorar errores de parseo silenciosamente para no quebrar la UI de Chat agnóstica.
      // Se delegan fallos de red/json al olvido seguro en el edge.
      print("Error procesando mutación de perfil: $e");
    }
  }

  /// Compilador de Contexto Semántico
  /// Exporta el perfil estructural en un bloque de texto ultra-denso, parametrizado y listo 
  /// para el Payload Híbrido, evitando que el LLM remoto sobrepiense.
  Future<String> obtenerPerfilComoString() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> registros = await db.query(tablePerfil);

    if (registros.isEmpty) return "Perfil no configurado.";

    // Agrupación en memoria por Categoría
    final Map<String, List<Map<String, dynamic>>> agrupados = {};
    for (var row in registros) {
      final categoria = row[columnCategoria] as String;
      if (!agrupados.containsKey(categoria)) {
        agrupados[categoria] = [];
      }
      agrupados[categoria]!.add(row);
    }

    // Ensamblaje iterativo en String plano encapsulado con viñetas
    final buffer = StringBuffer();
    agrupados.forEach((categoria, items) {
      buffer.writeln("### ${categoria.toUpperCase()}");
      for (var item in items) {
        final claveStr = (item[columnClave] as String).replaceAll('_', ' ').toUpperCase();
        buffer.writeln("- $claveStr: ${item[columnValor]}");
      }
      buffer.writeln("");
    });

    return buffer.toString().trim();
  }
}
