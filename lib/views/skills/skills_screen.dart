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
      {'id': 'agenda_crear', 'desc': 'Inyección estructurada de eventos al calendario natal', 'version': 'v1.4'},
      {'id': 'notificacion_enviar', 'desc': 'Pulsos de alerta háptica/visual al ecosistema OS', 'version': 'v2.1'},
      {'id': 'web_search', 'desc': 'Rastreo perimetral DuckDuckGo Zero-Knowledge', 'version': 'v1.0'},
      {'id': 'memoria_recordar', 'desc': 'Inyección y destilación en EAV Local Engine', 'version': 'v3.0'},
      {'id': 'memoria_olvidar', 'desc': 'Purga criptográfica de rama léxica', 'version': 'v1.1'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: disponibles.length,
      itemBuilder: (context, index) {
        final sk = disponibles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12)
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.hub_outlined, color: Color(0xFFD4AF37), size: 28),
            title: Text(sk['id']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(sk['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(height: 4),
                Text(sk['version']!, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorialTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
    }
    if (_historial.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'REGISTRO INMACULADO',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            SizedBox(height: 8),
            Text(
              'No se han invocado subrutinas nativas aún.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _historial.length,
      itemBuilder: (context, index) {
        final item = _historial[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, color: Color(0xFFD4AF37), size: 16),
                      const SizedBox(width: 8),
                      Text(item['skill'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  Text(
                    item['timestamp']?.split('T')[0] ?? '',
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white12),
              ),
              Text(
                'RETORNO: ${item['result']}',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfiguracionTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person_outlined, size: 64, color: Color(0xFFD4AF37)),
          const SizedBox(height: 24),
          const Text(
            'DIRECTIVAS SOBERANAS MANTENIDAS',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Las habilidades solo son inyectadas en la Cápsula si esta posee los permisos habilitados localmente en SQLite.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, height: 1.5),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('SKILL PLATFORM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white30,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          tabs: const [
            Tab(text: 'DISPONIBLES'),
            Tab(text: 'HISTORIAL'),
            Tab(text: 'REGLAS'),
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
