import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/secure_storage_service.dart';
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

  List<File> _vaultFiles = [];
  bool _isLoading = true;

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

  Widget _buildDocumentsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_vaultFiles.isEmpty) {
      return const Center(
        child: Text(
          'Bóveda vacía. Toca \'Editor\' para crear tu primer documento.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontFamily: 'Inter'),
        ),
      );
    }
    return ListView.builder(
      itemCount: _vaultFiles.length,
      itemBuilder: (context, index) {
        final file = _vaultFiles[index];
        final name = file.path.split('/').last;
        return ListTile(
          leading: const Icon(Icons.description_outlined, color: Colors.white54),
          title: Text(name, style: const TextStyle(color: Colors.white, fontFamily: 'Inter')),
        );
      },
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
        title: const Text('NANO-OBSIDIAN', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFiles,
            )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D0D12),
        unselectedItemColor: Colors.white30,
        selectedItemColor: const Color(0xFF4C8CFA),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) _loadFiles();
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: ''),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
