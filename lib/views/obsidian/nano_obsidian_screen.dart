import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/secure_storage_service.dart';
import '../../services/local_embedding_service.dart';
import 'note_editor_screen.dart';
import 'note_search_screen.dart';

class NanoObsidianScreen extends StatefulWidget {
  const NanoObsidianScreen({Key? key}) : super(key: key);

  @override
  _NanoObsidianScreenState createState() => _NanoObsidianScreenState();
}

class _NanoObsidianScreenState extends State<NanoObsidianScreen> {
  int _currentIndex = 0;
  final SecureStorageService _storageService = SecureStorageService();
  final LocalEmbeddingService _embeddingService = LocalEmbeddingService();

  List<File> _vaultFiles = [];
  bool _isLoading = true;
  bool _isInjecting = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      _vaultFiles = await _storageService.listVaultFiles();
    } catch (e) {
      _vaultFiles = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _injectarPlantillas() async {
    setState(() => _isInjecting = true);
    final plantillas = {
      '01_protocolo_salud.md': '# Protocolo de Salud\n1. Ayuno intermitente 16/8\n2. Entrenamiento de fuerza 4x semana\n3. Suplementación con Magnesio y Omega 3',
      '02_modelo_negocio.md': '# Modelo de Negocios SaaS\n* Ingresos Recurrentes Mensuales (MRR)\n* Costo de Adquisición de Clientes (CAC)\n* Lifetime Value de clientes (LTV)\nRegla de rentabilidad: LTV > 3 * CAC',
      '03_filosofia_estoica.md': '# Notas de Filosofía Estoica\nNo podemos controlar el mundo exterior, solo nuestra reacción ante él. La dicotomía del control es el pilar de la tranquilidad mental.',
      '04_claves_seguridad.md': '# Seguridad Personal y OPSEC\n- Usar administradores de contraseñas offline.\n- 2FA mediante llaves de hardware (YubiKey).\n- Evitar biometría para cruces fronterizos.',
      '05_receta_nutricion.md': '# Receta: Batido de Recuperación\n- 40g Proteína Isolatada\n- 1 Banana\n- 1 Cucharada Mantequilla de Maní\n- Leche de Almendras (300ml)\nLicuar y servir frío.',
      '06_bitacora_mensual.md': '# Bitácora de Septiembre\nEste mes el foco principal es el despliegue a producción de Fénix OS. Reducir ruido digital y ejecutar deep work de 4 horas diarias.',
    };

    try {
      await _embeddingService.init_database();
      await _embeddingService.init_model();
      
      for (var entry in plantillas.entries) {
        final id = DateTime.now().millisecondsSinceEpoch.toString() + '_' + entry.key;
        await _storageService.writeEncryptedMarkdown(id, entry.value);
        final docVector = await _embeddingService.generar_vector(entry.value);
        await _embeddingService.guardar_documento(id, docVector);
      }
      await _loadFiles();
    } catch (e) {
      // Ignorar fallback si falla el embedding
      await _loadFiles();
    } finally {
      if (mounted) setState(() => _isInjecting = false);
    }
  }

  Widget _buildDocumentsTab() {
    if (_isLoading || _isInjecting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            Text(_isInjecting ? 'INYECTANDO CONOCIMIENTO...' : 'DESCIFRANDO BÓVEDA...', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 2)),
          ],
        ),
      );
    }
    
    if (_vaultFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 24),
            const Text('BÓVEDA VACÍA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Toca el botón inferior para inyectar 6 plantillas de conocimiento experto (RAG) listas para vectorizarse en RAM.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.flash_on, color: Colors.black),
              label: const Text('INYECTAR PLANTILLAS (DE-MOCKING)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _injectarPlantillas,
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A24),
            border: Border(bottom: BorderSide(color: Colors.white12))
          ),
          child: const Row(
            children: [
              Icon(Icons.memory, color: Color(0xFFD4AF37), size: 16),
              SizedBox(width: 8),
              Text('CONOCIMIENTO USADO EN RAM', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _vaultFiles.length,
            itemBuilder: (context, index) {
              final file = _vaultFiles[index];
              final name = file.path.split('/').last.replaceAll('.aes', '');
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.description, color: Color(0xFFD4AF37), size: 20),
                  ),
                  title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Cifrado AES-256 • Vectorizado', style: TextStyle(color: Colors.white30, fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                  onTap: () {}, // Future UI navigation
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildDocumentsTab(),
      const NoteEditorScreen(),
      const NoteSearchScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 20),
            const SizedBox(width: 8),
            const Text('NANO-OBSIDIAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
              onPressed: _loadFiles,
            )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12))
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0D0D12),
          unselectedItemColor: Colors.white30,
          selectedItemColor: const Color(0xFFD4AF37),
          currentIndex: _currentIndex,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 0) _loadFiles();
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), activeIcon: Icon(Icons.folder_copy), label: 'Bóveda'),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note), label: 'Editor'),
            BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Búsqueda Neuronal'),
          ],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
