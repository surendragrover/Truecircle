import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:audioplayers/audioplayers.dart';
import '../root_shell.dart';
import '../services/coin_reward_service.dart';

class DrIrisWelcomePage extends StatefulWidget {
  final bool isFirstTime;
  const DrIrisWelcomePage({super.key, this.isFirstTime = false});

  @override
  State<DrIrisWelcomePage> createState() => _DrIrisWelcomePageState();
}

class _DrIrisWelcomePageState extends State<DrIrisWelcomePage> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Auto-play welcome audio
    _playWelcomeAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playWelcomeAudio() async {
    try {
      // Play Dr. Iris welcome audio file
      await _audioPlayer.play(AssetSource('audio/dr_iris_welcome.mp3'));

      _audioPlayer.onPlayerComplete.listen((_) {
        // Audio completed
      });
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  void _showWallet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/TrueCircle_Coin.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 32,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Wallet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Current Balance
            Container(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<int>(
                future: CoinRewardService.instance.getUserCoinsCount(),
                builder: (context, snapshot) {
                  final coins = snapshot.data ?? 0;
                  return Column(
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/TrueCircle_Coin.png',
                            width: 28,
                            height: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                                size: 28,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$coins Coins',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            // Information Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletInfoSection('💰 How to Earn Coins', [
                      'Daily login: 1 coin per day',
                      'Complete a full entry: 1 coin',
                      'Note: No rewards for chatting with Dr. Iris',
                    ]),
                    const SizedBox(height: 20),
                    _buildWalletInfoSection('🛍️ How to Spend Coins', [
                      '1 Coin = ₹1 shopping discount',
                      'Use at marketplace for premium features',
                      'Redeem for exclusive content',
                      'Save up for special rewards',
                    ]),
                    const SizedBox(height: 20),
                    _buildWalletInfoSection('📊 Coin Types', [
                      'Available coins: ready to spend',
                      'Total coins: lifetime earnings',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfoSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Expanded(child: Text(point)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.isFirstTime
          ? null
          : AppBar(
              title: const Text('🤖 Dr. Iris'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                // User Wallet - Coin Display
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showWallet(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/TrueCircle_Coin.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 20,
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        FutureBuilder<int>(
                          future: CoinRewardService.instance
                              .getUserCoinsCount(),
                          builder: (context, snapshot) {
                            final coins = snapshot.data ?? 0;
                            return Text(
                              '$coins',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Dr. Iris Welcome Header - Rainbow 🌈
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6), // Purple
                        Color(0xFFEC4899), // Pink
                        Color(0xFF3B82F6), // Blue
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🤖 Dr. Iris Welcome! 🌈',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Privacy Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      size: 32,
                      color: const Color(0xFF10B981), // Emerald Green 🔒
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🔒 Your emotions never leave your phone! 🔒',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dr. Iris Introduction
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dr. Iris Avatar �
                    ClipOval(
                      child: Image.asset(
                        'assets/images/Avatar.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology_alt,
                              size: 40,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '💝 Dr. Iris, Your Emotional Companion 💝',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hello! I\'m Dr. Iris - your emotional companion. I\'m here to guide you gently through your thoughts and relationships.',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tips Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '💡 Tips for better replies',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• Be specific about what you need right now.'),
                      Text('• One small question at a time works best.'),
                      Text('• If stuck, start with "I feel … and I need …".'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Navigation Buttons - Rainbow Actions 🌈
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Mark welcomed and navigate to home without check-in
                    final nav = Navigator.of(context);
                    try {
                      final box = await Hive.openBox('app_prefs');
                      await box.put('dr_iris_welcomed', true);
                    } catch (e) {
                      debugPrint('Hive error: $e');
                    }
                    if (!mounted) return;
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RootShell()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('🏠 Skip to Home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6), // Sky Blue
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
