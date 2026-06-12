import 'package:flutter/material.dart';
import '../../services/secure_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  String _endpoint = 'europe-west3.run.app (Stateless)';

  Future<void> _purgarBoveda() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.red, width: 1)),
        title: const Text('ADVERTENCIA CRÍTICA', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('Esto ejecutará un borrado criptográfico irreversible de todos los documentos y vectores en la bóveda local. ¿Proceder?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('PURGAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      )
    );

    if (confirm == true) {
      // Proceder con wipe. Simplemente borramos todos los archivos
      final files = await _storageService.listVaultFiles();
      for (var file in files) {
        await file.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bóveda local purgada exitosamente.'), backgroundColor: Colors.red)
      );
    }
  }

  Future<void> _changeEndpoint() async {
    final TextEditingController controller = TextEditingController(text: _endpoint);
    final String? newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFD4AF37), width: 1)),
          title: const Text('Rúteador VPS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('GUARDAR', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );

    if (newValue != null && newValue.isNotEmpty) {
      setState(() {
        _endpoint = newValue;
      });
    }
  }

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
          _buildSettingsTile(Icons.wifi, 'Nodo VPS Actual', _endpoint, onTap: _changeEndpoint),
          _buildSettingsTile(Icons.speed, 'Tolerancia de Latencia TCP', 'Estricto (30s timeout)'),
          _buildSettingsTile(Icons.memory, 'Memoria Asignada (Local RAG)', '512 MB (Automático)'),
          
          const SizedBox(height: 32),
          _buildSectionHeader('SEGURIDAD CRIPTOGRÁFICA'),
          _buildSettingsTile(Icons.lock_outline, 'Algoritmo de Bóveda', 'AES-256 (Symmetric)'),
          _buildSettingsTile(Icons.key, 'Rotación de Llave Maestra', 'Manual (No recomendado)'),
          _buildSettingsTile(
            Icons.delete_forever, 
            'Purgar Bóveda (Wipe)', 
            'Destrucción total de vectores',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: _purgarBoveda
          ),
          
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

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {Color? iconColor, Color? textColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12)
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? Colors.white70),
          title: Text(title, style: TextStyle(color: textColor ?? Colors.white, fontSize: 14)),
          subtitle: Text(subtitle, style: TextStyle(color: textColor?.withOpacity(0.7) ?? Colors.white30, fontSize: 12)),
          trailing: Icon(Icons.chevron_right, color: textColor?.withOpacity(0.5) ?? Colors.white30),
        ),
      ),
    );
  }
}
