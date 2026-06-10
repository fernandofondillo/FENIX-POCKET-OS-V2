// lib/models/payload_request.dart

/// Representa la carga densa de información contextual efímera
/// que el dispositivo móvil emitirá hacia el servidor VPS.
class PayloadRequest {
  /// Identificador anónimo del usuario (Zero-Knowledge UUID).
  /// Fundamental para la segmentación Multi-Usuario en el Orquestador VPS.
  final String userId;
  
  /// El texto emitido por el usuario o extraído mediante Speech-to-Text.
  final String mensajeActual;
  
  /// La instancia completa de la identidad base del usuario extraída de SQLite.
  final Map<String, dynamic> perfilIdentidad;
  
  /// Fragmentos estructurados correspondientes a un sistema RAG local, si aplica.
  final String contextoRagHibrido;
  
  /// Detalles de la cápsula de personalidad activa (Ej. "Entrenador", "Ingeniero").
  final Map<String, dynamic> capsulaActiva;
  
  /// Historial Fifo ultra-compacto y encriptado en reposo en el móvil de últimos comandos del chat
  final List<Map<String, String>> historialReciente;

  PayloadRequest({
    required this.userId,
    required this.mensajeActual,
    required this.perfilIdentidad,
    required this.contextoRagHibrido,
    required this.capsulaActiva,
    required this.historialReciente,
  });

  /// Transmuta el objeto a su representación Map en `snake_case` estricto
  /// garantizando su integridad para FastAPI/Pydantic en backend.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mensaje_actual': mensajeActual,
      'perfil_identidad': perfilIdentidad,
      'contexto_rag_hibrido': contextoRagHibrido,
      'capsula_activa': capsulaActiva,
      'historial_reciente': historialReciente,
    };
  }
}
