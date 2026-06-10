// lib/models/payload_request.dart
//
// Modelos Dart que reflejan EXACTAMENTE el contrato Pydantic del backend.
// Ver: /root/agos-backend/app/schemas/chat_schema.py
//
// Todos los campos son snake_case estricto (Fénix Pocket OS V2).
// Mantener sincronizado si el backend cambia.

import 'package:flutter/foundation.dart';

/// Una cápsula cognitiva activa (system prompt + skills permitidas).
/// Mirror exacto del Pydantic `CapsulaActiva`.
@immutable
class CapsulaActiva {
  final String id;
  final String systemPrompt;
  final List<String> allowedSkills;

  const CapsulaActiva({
    required this.id,
    required this.systemPrompt,
    this.allowedSkills = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'system_prompt': systemPrompt,
        'allowed_skills': allowedSkills,
      };

  factory CapsulaActiva.fromJson(Map<String, dynamic> json) => CapsulaActiva(
        id: json['id'] as String? ?? 'general_coordinator',
        systemPrompt: json['system_prompt'] as String? ?? '',
        allowedSkills: (json['allowed_skills'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

/// Contexto RAG híbrido (historial usuario + conocimiento experto).
/// Mirror exacto del Pydantic `RagContext`.
@immutable
class RagContext {
  final String historialUsuario;
  final String conocimientoExperto;

  const RagContext({
    this.historialUsuario = '',
    this.conocimientoExperto = '',
  });

  Map<String, dynamic> toJson() => {
        'historial_usuario': historialUsuario,
        'conocimiento_experto': conocimientoExperto,
      };

  factory RagContext.fromJson(Map<String, dynamic> json) => RagContext(
        historialUsuario: json['historial_usuario'] as String? ?? '',
        conocimientoExperto: json['conocimiento_experto'] as String? ?? '',
      );
}

/// Un mensaje del historial FIFO (últimos 8).
/// Mirror exacto del Pydantic `Message`.
@immutable
class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String? ?? 'user',
        content: json['content'] as String? ?? '',
      );
}

/// Payload completo de request al endpoint /api/v1/chat.
/// Mirror exacto del Pydantic `ChatRequest`.
@immutable
class PayloadRequest {
  final String userId;
  final String mensajeActual;
  final String perfilIdentidad;
  final RagContext contextoRagHibrido;
  final CapsulaActiva capsulaActiva;
  final List<String> activeSkills;
  final List<ChatMessage> historialReciente;

  const PayloadRequest({
    required this.userId,
    required this.mensajeActual,
    required this.perfilIdentidad,
    required this.contextoRagHibrido,
    required this.capsulaActiva,
    this.activeSkills = const [],
    this.historialReciente = const [],
  });

  /// Transmuta el objeto a su representación Map en `snake_case` estricto
  /// garantizando su integridad para FastAPI/Pydantic en backend.
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'mensaje_actual': mensajeActual,
        'perfil_identidad': perfilIdentidad,
        'contexto_rag_hibrido': contextoRagHibrido.toJson(),
        'capsula_activa': capsulaActiva.toJson(),
        'active_skills': activeSkills,
        'historial_reciente':
            historialReciente.map((m) => m.toJson()).toList(),
      };
}

/// Item de perfil_update que viene en la respuesta.
/// Mirror exacto del Pydantic `PerfilUpdateItem`.
@immutable
class PerfilUpdateItem {
  final String categoria;
  final String clave;
  final String valor;

  const PerfilUpdateItem({
    required this.categoria,
    required this.clave,
    required this.valor,
  });

  factory PerfilUpdateItem.fromJson(Map<String, dynamic> json) =>
      PerfilUpdateItem(
        categoria: json['categoria'] as String? ?? 'general',
        clave: json['clave'] as String? ?? '',
        valor: json['valor'] as String? ?? '',
      );
}

/// Respuesta completa del backend.
/// Mirror exacto del Pydantic `ChatResponse`.
@immutable
class ChatResponse {
  final String status;
  final String assistantResponse;
  final List<PerfilUpdateItem> perfilUpdate;
  final List<Map<String, dynamic>> executedSkills;
  final String inferencedBy;

  const ChatResponse({
    required this.status,
    required this.assistantResponse,
    this.perfilUpdate = const [],
    this.executedSkills = const [],
    required this.inferencedBy,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    // Compatibilidad: backend legacy usa 'assistant_response', el del repo
    // usa 'status' + 'assistant_response' + 'inferenced_by'
    return ChatResponse(
      status: json['status'] as String? ?? 'success',
      assistantResponse: json['assistant_response'] as String? ?? '',
      perfilUpdate: (json['perfil_update'] as List<dynamic>? ?? [])
          .map((e) => PerfilUpdateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      executedSkills: (json['executed_skills'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      inferencedBy: json['inferenced_by'] as String? ??
          json['model'] as String? ??
          'unknown',
    );
  }
}
