import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/event_bus.dart';
import '../services/coin_reward_service.dart';
import './dream_model.dart';
import './dream_service.dart';

class DreamSpacePage extends StatefulWidget {
  const DreamSpacePage({super.key});

  @override
  State<DreamSpacePage> createState() => _DreamSpacePageState();
}

class _DreamSpacePageState extends State<DreamSpacePage> {
  final DreamService _dreamService = DreamService();
  final TextEditingController _dreamController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Future<List<Dream>> _dreamsFuture;

  final List<String> _starSounds = [
    'Music/celestial-harmony_95655.mp3',
    'Music/chime-of-crystal-bells.mp3',
    'Music/magic-magic-sound-2.mp3',
    'Music/soft-whispers_94600.mp3',
    'Music/twinkle.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  void _loadDreams() {
    setState(() {
      _dreamsFuture = _dreamService.getDreams();
    });
  }

  void _addDream() async {
    if (_dreamController.text.isNotEmpty) {
      await _dreamService.addDream(_dreamController.text);
      await CoinRewardService.instance.grantCoins(1);
      EventBus.instance.fire(const CoinRewardedEvent(1));
      _dreamController.clear();
      _loadDreams(); // Refresh the list
      FocusScope.of(context).unfocus();
    }
  }

  void _playStarSound(Dream dream) {
    final soundIndex = dream.id.hashCode.abs() % _starSounds.length;
    _audioPlayer.play(AssetSource(_starSounds[soundIndex]));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          dream.text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          dream.createdAt.toString(),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Sky of Your Mind'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000020), Color(0xFF000030)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Dream>>(
                future: _dreamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final dreams = snapshot.data ?? [];
                  if (dreams.isEmpty) {
                    return const Center(
                      child: Text(
                        'Your sky is clear.\nAdd a thought to create your first star.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white54),
                      ),
                    );
                  }

                  return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                      ),
                      itemCount: dreams.length,
                      itemBuilder: (context, index) {
                        return _buildStar(dreams[index]);
                      });
                },
              ),
            ),
            _buildDreamInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(Dream dream) {
    final random = Random(dream.id.hashCode);
    final size = 25.0 + random.nextDouble() * 15.0;
    final opacity = 0.6 + random.nextDouble() * 0.4;

    return GestureDetector(
      onTap: () => _playStarSound(dream),
      child: Icon(
        Icons.star,
        color: Colors.white.withOpacity(opacity),
        size: size,
      ),
    );
  }

  Widget _buildDreamInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _dreamController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a star to your sky...',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
            onPressed: _addDream,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dreamController.dispose();
    super.dispose();
  }
}
