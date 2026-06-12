import 'package:flutter/material.dart';
import '../../services/secure_storage_service.dart';
import '../../services/local_embedding_service.dart';
import 'package:uuid/uuid.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({Key? key}) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final SecureStorageService _storageService = SecureStorageService();
  final LocalEmbeddingService _embeddingService = LocalEmbeddingService();
  bool _isSaving = false;

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() => _isSaving = true);
    
    try {
      final String filename = '${title.replaceAll(' ', '_').toLowerCase()}.md';
      final String docId = const Uuid().v4();
      
      // I/O: Guardar cifrado en disco
      await _storageService.writeEncryptedMarkdown(filename, content);
      
      // Vectorización: Indexar contenido usando TFLite + SQLite off-grid
      await _embeddingService.indexar_fragmento(docId, title, content);

      _titleController.clear();
      _contentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('[ENGRAVED] Documento cifrado e indexado localmente.', style: TextStyle(fontFamily: 'Inter')),
            backgroundColor: Color(0xFF0D0D12),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'Identificador del Documento...',
              hintStyle: TextStyle(color: Colors.white30),
              border: InputBorder.none,
            ),
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Redactar sintaxis Markdown...',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveNote,
              icon: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.shield_outlined),
              label: const Text('CIFRAR E INDEXAR', style: TextStyle(fontFamily: 'Inter', letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C8CFA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
