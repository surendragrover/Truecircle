
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Emotional Check-in',
      'titleHi': 'भावनात्मक जांच',
      'subtitle': 'Track your daily emotions',
      'subtitleHi': 'अपनी दैनिक भावनाओं को ट्रैक करें',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'action': 'emotional_checkin',
    },
    {
      'title': 'Relationship Insights',
      'titleHi': 'रिश्ते की जानकारी',
      'subtitle': 'Analyze your connections',
      'subtitleHi': 'अपने रिश्तों का विश्लेषण करें',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'action': 'relationship_insights',
    },
    {
      'title': 'Mood Journal',
      'titleHi': 'मूड डायरी',
      'subtitle': 'Write your thoughts',
      'subtitleHi': 'अपने विचार लिखें',
      'icon': Icons.book,
      'color': Colors.indigo,
      'action': 'mood_journal',
    },
    {
      'title': 'Chat with Dr. Iris',
      'titleHi': 'डॉ. आइरिस से चैट',
      'subtitle': 'Talk to your AI-powered guide',
      'subtitleHi': 'अपने एआई-संचालित गाइड से बात करें',
      'icon': Icons.chat,
      'color': Colors.teal,
      'action': 'ai_chat',
    },
    {
      'title': 'Meditation Guide',
      'titleHi': 'ध्यान गाइड',
      'subtitle': 'Guided mindfulness sessions',
      'subtitleHi': 'निर्देशित माइंडफुलनेस सत्र',
      'icon': Icons.self_improvement,
      'color': Colors.green,
      'action': 'meditation',
    },
    {
      'title': 'Sleep Tracker',
      'titleHi': 'स्लीप ट्रैकर',
      'subtitle': 'Monitor your sleep patterns',
      'subtitleHi': 'अपने नींद के पैटर्न को मॉनिटर करें',
      'icon': Icons.bedtime,
      'color': Colors.blue,
      'action': 'sleep_tracker',
    },
    {
      'title': 'Communication Reminders',
      'titleHi': 'संचार अनुस्मारक',
      'subtitle': 'Get reminders to connect',
      'subtitleHi': 'जुड़ने के लिए अनुस्मारक प्राप्त करें',
      'icon': Icons.message,
      'color': Colors.amber,
      'action': 'communication_reminders',
    },
    {
      'title': 'Upcoming Festivals',
      'titleHi': 'आगामी त्यौहार',
      'subtitle': 'Stay updated on cultural events',
      'subtitleHi': 'सांस्कृतिक कार्यक्रमों पर अपडेट रहें',
      'icon': Icons.celebration,
      'color': Colors.orange,
      'action': 'upcoming_festivals',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8E24AA),
                Color(0xFFAB47BC),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dr. Iris',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your personal guide to emotional clarity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _features.length,
                      itemBuilder: (context, index) {
                        final feature = _features[index];
                        return _buildFeatureCard(feature);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF6A1B9A),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Handle feature tap if needed, for now, just decorative
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature['icon'],
                color: feature['color'],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                feature['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
