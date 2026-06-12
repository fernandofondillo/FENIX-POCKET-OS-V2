import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('SYSTEM ARCHITECTURE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: const Color(0xFF0D0D12),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('RED Y RENDIMIENTO'),
          _buildSettingsTile(Icons.wifi, 'Nodo VPS Actual', 'europe-west3.run.app (Stateless)'),
          _buildSettingsTile(Icons.speed, 'Tolerancia de Latencia TCP', 'Estricto (30s timeout)'),
          _buildSettingsTile(Icons.memory, 'Memoria Asignada (Local RAG)', '512 MB (Automático)'),
          
          const SizedBox(height: 32),
          _buildSectionHeader('SEGURIDAD CRIPTOGRÁFICA'),
          _buildSettingsTile(Icons.lock_outline, 'Algoritmo de Bóveda', 'AES-256 (Symmetric)'),
          _buildSettingsTile(Icons.key, 'Rotación de Llave Maestra', 'Manual (No recomendado)'),
          _buildSettingsTile(Icons.delete_forever, 'Purgar Bóveda (Wipe)', 'Destrucción total de vectores'),
          
          const SizedBox(height: 32),
          _buildSectionHeader('CAPA LÓGICA (LLM)'),
          _buildSettingsTile(Icons.model_training, 'Cuota Token RAG', '1024 Tokens / Request'),
          _buildSettingsTile(Icons.psychology, 'Fallback Matemático TFLite', 'ACTIVO (Anti-Crash)'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12)
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      ),
    );
  }
}
