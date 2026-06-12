import 'package:flutter/material.dart';
import '../../services/perfil_db_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PerfilDbService _db = PerfilDbService();
  Map<String, dynamic> _perfil = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _db.initDb();
    final data = await _db.getPerfilCompleto();
    setState(() {
      _perfil = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('METABASE PROFILE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: const Color(0xFF0D0D12),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(
                child: Icon(Icons.diamond_outlined, size: 80, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('IDENTIDAD MATRIZ (EAV Engine)'),
              _buildMetricCard('Denominación Primaria', _perfil['nombre_usuario'] ?? 'N/A', Icons.person),
              _buildMetricCard('Rol Funcional', _perfil['profesion_activa'] ?? 'N/A', Icons.work_outline),
              _buildMetricCard('Metavariable (Objetivo)', _perfil['meta_dominante'] ?? 'N/A', Icons.flag_outlined),
              
              const SizedBox(height: 32),
              _buildSectionHeader('PARÁMETROS DEL SISTEMA'),
              _buildMetricCard('Estado de Configuración', _perfil['config_inicial'] ?? 'N/A', Icons.check_circle_outline),
              _buildMetricCard('Fecha Onboarding (UTC)', _perfil['fecha_onboarding'] ?? 'N/A', Icons.calendar_today),
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

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12)
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white30, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
