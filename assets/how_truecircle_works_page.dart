/* This asset file is intentionally empty to avoid analyzer errors.
Original content commented out below.
}

class _HowTrueCircleWorksPageState extends State<HowTrueCircleWorksPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const TrueCircleLogo(size: 32),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'How TrueCircle Works',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: CoralTheme.appBarGradient,
          ),
        ),
        actions: const [SizedBox(width: 16)],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'Overview'),
            const Tab(text: 'Features'),
            const Tab(text: 'Privacy'),
            const Tab(text: 'AI Technology'),
            const Tab(text: 'Getting Started'),
          ],
        ),
      ),
      body: Container(
        decoration: CoralTheme.background,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildFeaturesTab(),
            _buildPrivacyTab(),
            _buildAITechnologyTab(),
            _buildGettingStartedTab(),
          ],
        ),
      ),
      bottomNavigationBar: GlobalNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
          // Extend with more routing as needed
        },
        showBack: Navigator.of(context).canPop(),
        onBack: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: '🌟 What is TrueCircle?',
            content:
                '''TrueCircle is a revolutionary emotional AI app that helps you understand your relationships and mental health. It's a privacy‑first app that provides AI‑powered insights with cultural context.

✨ Key Highlights:
• 100% Privacy Protected - Your data stays on your device
• Cultural AI - Understands festivals and traditions
• Zero Permissions - No device permissions required
• Real-time Analysis - Instant emotional insights''',
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ColorSchemePreviewPage(),
                  ),
                );
              },
              icon: const Icon(Icons.palette, color: Colors.white),
              label: const Text(
                'View Color Scheme',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSectionCard(
            title: '🎯 Our Mission',
            content:
                '''TrueCircle's mission is to empower people with emotional intelligence and healthy relationships — without compromising privacy.

🌍 Vision:
"Make emotional wellness accessible while respecting privacy and cultural values"

💡 Values:
• Privacy First - Your information belongs only to you
• Cultural Sensitivity - Respect for cultural context
• Accessibility - Available for everyone
• Innovation - Utilize modern AI responsibly''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '🚀 TrueCircle\'s Impact',
            content:
                '''TrueCircle is not just an app — it's a movement for emotional wellness. People report significant improvements in their relationships.

📊 Examples:
• Better understanding of relationship patterns
• Increased emotional awareness
• Improved celebration experiences
• Strong privacy satisfaction

🎉 Stories:
"TrueCircle helped me strengthen emotional connections during festivals."
"I understood my relationship patterns and developed better communication skills."''',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureCard(
            icon: '🧠',
            title: 'Emotional Check-in',
            subtitle: 'Daily Emotional Assessment',
            description:
                '''Track your emotions daily and understand patterns. AI analyzes your mood changes and provides personalized insights.

✨ Features:
• Daily emotion logging
• Mood pattern analysis
• Emotional triggers identification
• Personalized recommendations
• Rich emotion vocabulary''',
          ),
          _buildFeatureCard(
            icon: '💕',
            title: 'Relationship Insights',
            subtitle: 'Deep Relationship Analysis',
            description:
                '''Comprehensive analysis of all your relationships. Understand which relationships are healthy and where improvement is needed.

🔍 Analysis Includes:
• Communication patterns
• Emotional compatibility
• Relationship strengths & weaknesses
• Cultural context consideration
• Festival bonding opportunities''',
          ),
          _buildFeatureCard(
            icon: '🎭',
            title: 'Cultural AI Dashboard',
            subtitle: 'Festival Intelligence',
            description:
                '''Understand relationships in the context of festivals. AI suggests how to strengthen emotional connections during celebrations.

🎉 Cultural Features:
• Festival-specific relationship tips
• Regional celebration insights
• Family bonding suggestions
• Gift-giving recommendations
• Traditional value integration''',
          ),
          _buildFeatureCard(
            icon: '👩‍⚕️',
            title: 'Dr. Iris AI Counselor',
            subtitle: 'Personal AI Advisor',
            description:
                '''24/7 available AI counselor that understands your emotional and relationship problems. Advice is grounded in well-known therapy techniques.

🩺 Counseling Features:
• Real-time emotional support
• Relationship problem solving
• Stress management techniques
• Cultural sensitivity
• Privacy-protected conversations''',
          ),
          _buildFeatureCard(
            icon: '📊',
            title: 'Wellness Tracking',
            subtitle: 'Comprehensive Health Tracking',
            description:
                '''Track your mental, emotional, and physical wellness. Sleep, mood, breathing exercises — everything in one place.

📈 Tracking Includes:
• Mood Journal (30-day data)
• Sleep Quality Analysis
• Breathing Exercise Progress
• Meditation Tracking
• Stress Level Monitoring''',
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrueCircleFeaturesListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt, color: Colors.white),
              label: const Text(
                'View Detailed Features List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: '🔒 Privacy-First Approach',
            content:
                '''At TrueCircle, your privacy is our top priority. The app is designed so your sensitive data never leaves your device.

🛡️ Privacy Features:
• Zero Data Collection – We don't collect personal data
• On-Device Processing – All AI runs locally
• No Server Storage – Nothing stored in the cloud
• No Dangerous Permissions – Works in a privacy-first offline mode
• Transparent by Design – Clear, simple controls''',
          ),
          // Note: Permission settings UI removed per privacy-first design.
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '🔐 Data Security Architecture',
            content:
                '''TrueCircle uses multiple layers of security to keep your data safe.

🏗️ Security Layers:
1. Local Encryption – Data encrypted on device
2. Hive Database – Secure local storage
3. Memory Protection – Careful in-memory handling
4. Network Isolation – Works offline by default
5. Code Hardening – Release builds are obfuscated

🎯 Privacy Benefits:
• No corporate data mining
• No targeted advertising
• Complete user control
• Privacy by design''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '✅ Privacy Guarantee',
            content: '''We guarantee that TrueCircle protects your privacy.

📝 Our Commitments:
• We never share your data
• No third‑party trackers
• No advertising identifiers
• Transparent, offline-by-default experience''',
          ),
        ],
      ),
    );
  }

  Widget _buildAITechnologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: '🤖 Advanced AI Technology',
            content:
                '''TrueCircle uses modern, privacy-friendly AI designed to respect cultural context while running fully on-device.

🧠 AI Capabilities:
• Natural Language Processing
• Emotion Recognition (50+ categories)
• Pattern Analysis for relationships
• Predictive insights
• Cultural context awareness''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '🎯 Cultural AI Innovation',
            content:
                '''Our Cultural AI goes beyond generic models and is tuned to understand celebrations, family dynamics, and tradition‑informed contexts.

🌟 Highlights:
• Festival emotional patterns
• Family dynamics
• Regional celebration insights
• Balance of traditional values in modern life''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '⚡ On-Device AI Processing',
            content:
                '''All AI processing happens on your device. After installation, platform‑specific models are available offline.

💻 Advantages:
• Real‑time processing
• Fully offline functionality
• Battery‑optimized
• Privacy protected
• Platform‑optimized''',
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: '🚀 Getting Started with TrueCircle',
            content:
                '''TrueCircle is simple to use. After installation, the app is ready in its privacy-first offline mode and works fully offline.

📱 Quick Start:
1. Install the app
2. Launch in Offline Mode (no permissions)
3. Set basic preferences
4. Do your first Emotional Check‑in

⏱️ Typical Time:
• Initial setup: ~30 seconds
• First check‑in: ~30 seconds''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '💡 Best Practices',
            content: '''Tips to get the most from TrueCircle:

📅 Daily Usage:
• Do a quick Emotional Check‑in (30 seconds)
• Weekly relationship review
• Track sleep and mood patterns

🎯 Pro Tips:
• Morning check‑ins provide clarity
• Chat with Dr. Iris weekly
• Practice breathing exercises

📊 Progress Tracking:
• Check weekly analytics
• Review monthly insights
• Set goals and monitor progress''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '🆘 Support & Help',
            content:
                '''If you need any help or have questions, we're here for you:

📞 Support Channels:
• In‑App Help – Complete guide inside the app
• Dr. Iris Chat – Ask the AI counselor
• FAQ Section – Answers to common questions
• Video Tutorials – Step‑by‑step guidance
• Community Forum – Connect with other users

🕐 Response Time:
• In‑App Help: Instant
• Dr. Iris: Real‑time 24/7
• Technical Issues: Resolved within 24 hours
• Feature Requests: Considered in next update

🌟 Community:
Join the TrueCircle community and share experiences with other users. Get valuable insights while maintaining privacy.''',
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Use root navigator to ensure this opens above any nested navigators
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const TrueCircleFAQPage(),
                  ),
                );
              },
              icon: const Icon(Icons.quiz_outlined, color: Colors.white),
              label: const Text(
                'View Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                // Mark that user has seen "How TrueCircle Works"
                try {
                  final box = Hive.isBoxOpen(HiveBoxes.settings)
                      ? Hive.box(HiveBoxes.settings)
                      : await Hive.openBox(HiveBoxes.settings);
                  final phone = AuthService().currentPhoneNumber;
                  await box.put('${phone ?? 'global'}_seen_how_works', true);
                } catch (e) {
                  debugPrint('Error marking seen_how_works: $e');
                }

                // Navigate to HomePage
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.rocket_launch, color: Colors.white),
              label: const Text(
                'Get Started with TrueCircle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.orange.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
