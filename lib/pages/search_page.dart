import 'package:flutter/material.dart';
import '../models/emotion_entry.dart';
import '../services/emotion_service.dart';

class SearchPage extends StatefulWidget {
  final List<EmotionEntry> entries;
  final EmotionService emotionService;

  const SearchPage({
    super.key,
    required this.entries,
    required this.emotionService,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<EmotionEntry> _filteredEntries = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _filteredEntries = List.from(widget.entries);
  }

  void _filterEntries() {
    setState(() {
      _filteredEntries = widget.entries.where((entry) {
        if (_searchText.isNotEmpty) {
          final searchLower = _searchText.toLowerCase();
          if (!entry.emotion.toLowerCase().contains(searchLower) &&
              !(entry.note?.toLowerCase().contains(searchLower) ?? false)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchText = '';
      _searchController.clear();
      _filteredEntries = List.from(widget.entries);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withValues(alpha: 0.6),
                Colors.blue.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Dr. Iris Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear_all, color: Colors.white),
                        onPressed: _clearFilters,
                      ),
                    ],
                  ),
                ),

                // Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Search emotions or notes...',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () {
                                setState(() {
                                  _searchText = '';
                                  _searchController.clear();
                                  _filterEntries();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                        _filterEntries();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Results List
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No entries found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getIntensityColor(entry.intensity),
                                  child: Text(
                                    '${entry.intensity}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry.emotion,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (entry.note != null && entry.note!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.note!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 16, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      final originalIndex = widget.entries.indexOf(entry);
                                      if (originalIndex != -1) {
                                        await widget.emotionService.deleteEntry(originalIndex);
                                        setState(() {
                                          widget.entries.removeAt(originalIndex);
                                        });
                                        _filterEntries();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Entry deleted')),
                                          );
                                        }
                                      }
                                    } else if (value == 'edit') {
                                      _showEditDialog(entry);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
  }

  void _showEditDialog(EmotionEntry entry) {
    final emotionController = TextEditingController(text: entry.emotion);
    final noteController = TextEditingController(text: entry.note ?? '');
    int newIntensity = entry.intensity;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Emotion Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emotionController,
                  decoration: const InputDecoration(
                    labelText: 'Emotion',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Intensity: $newIntensity'),
                Slider(
                  value: newIntensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setDialogState(() {
                      newIntensity = value.round();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedEntry = EmotionEntry(
                  emotion: emotionController.text,
                  intensity: newIntensity,
                  timestamp: entry.timestamp,
                  note: noteController.text.isNotEmpty ? noteController.text : null,
                );

                final originalIndex = widget.entries.indexOf(entry);
                if (originalIndex != -1) {
                  await widget.emotionService.updateEntry(originalIndex, updatedEntry);
                  setState(() {
                    widget.entries[originalIndex] = updatedEntry;
                  });
                  _filterEntries();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry updated')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}