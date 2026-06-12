import 'package:flutter/material.dart';
import '../../services/skills_service.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({Key? key}) : super(key: key);

  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SkillsService _skillsService = SkillsService();
  List<Map<String, dynamic>> _historial = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _isLoading = true);
    try {
      _historial = await _skillsService.leer_historial_skills();
    } catch (e) {
      _historial = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDisponiblesTab() {
    final disponibles = [
      'agenda_crear',
      'notificacion_enviar',
      'web_search',
      'memoria_recordar',
      'memoria_olvidar'
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: disponibles.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.build_circle_outlined, color: Color(0xFF4C8CFA)),
          title: Text(disponibles[index], style: const TextStyle(color: Colors.white, fontFamily: 'Inter')),
          subtitle: const Text('Skill Inyectable Automática', style: TextStyle(color: Colors.white54, fontFamily: 'Inter', fontSize: 12)),
          trailing: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
        );
      },
    );
  }

  Widget _buildHistorialTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4C8CFA)));
    }
    if (_historial.isEmpty) {
      return const Center(
        child: Text(
          '[SIN ACTIVIDAD LÓGICA]\nNo se han ejecutado Skills recientemente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontFamily: 'Inter'),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historial.length,
      itemBuilder: (context, index) {
        final item = _historial[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['skill'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                  Text(
                    item['timestamp']?.split('T')[0] ?? '',
                    style: const TextStyle(color: Colors.white30, fontFamily: 'Inter', fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item['result'].toString(),
                style: const TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfiguracionTab() {
    return const Center(
      child: Text(
        '[CONFIGURACIÓN SOBERANA]\nDirectivas de invocación protegidas.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontFamily: 'Inter'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('SKILL PLATFORM', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4C8CFA),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white30,
          labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'DISPONIBLES'),
            Tab(text: 'HISTORIAL'),
            Tab(text: 'CONFIG'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDisponiblesTab(),
          _buildHistorialTab(),
          _buildConfiguracionTab(),
        ],
      ),
    );
  }
}
