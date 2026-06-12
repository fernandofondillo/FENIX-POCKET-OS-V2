import 'package:flutter/material.dart';
import '../../services/local_embedding_service.dart';

class NoteSearchScreen extends StatefulWidget {
  const NoteSearchScreen({Key? key}) : super(key: key);

  @override
  _NoteSearchScreenState createState() => _NoteSearchScreenState();
}

class _NoteSearchScreenState extends State<NoteSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocalEmbeddingService _embeddingService = LocalEmbeddingService();
  
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results.clear();
    });

    try {
      // 1. Convertir la query del usuario en un vector semántico
      final queryVector = await _embeddingService.generar_vector(query);
      
      // 2. Ejecutar la similitud de cosenos en SQLite local
      final topK = await _embeddingService.buscar_top_k(queryVector, k: 5);
      
      setState(() {
        _results = topK;
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: const InputDecoration(
                      hintText: 'Búsqueda semántica...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.travel_explore, color: Color(0xFF4C8CFA)),
                  onPressed: _performSearch,
                )
              ],
            ),
          ),
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: Color(0xFF4C8CFA)),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white12),
            itemBuilder: (context, index) {
              final item = _results[index];
              final double similitud = item['similarity'] ?? 0.0;
              final int matchPercent = (similitud * 100).clamp(0, 100).toInt();

              return ListTile(
                title: Text(
                  item['chapter'] ?? 'Desconocido', 
                  style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)
                ),
                subtitle: Text(
                  'UUID Doc: ${item['doc_id']}', 
                  style: const TextStyle(color: Colors.white54, fontFamily: 'Inter', fontSize: 12)
                ),
                trailing: Text(
                  '$matchPercent% MATCH', 
                  style: TextStyle(
                    color: matchPercent > 75 ? Colors.greenAccent : Colors.orangeAccent, 
                    fontFamily: 'Inter', 
                    fontWeight: FontWeight.bold
                  )
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
