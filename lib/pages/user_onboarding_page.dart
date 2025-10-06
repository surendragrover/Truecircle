import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/dr_iris_avatar.dart';
import '../widgets/truecircle_logo.dart';

class UserOnboardingPage extends StatefulWidget {
  const UserOnboardingPage({super.key});

  @override
  State<UserOnboardingPage> createState() => _UserOnboardingPageState();
}

class _UserOnboardingPageState extends State<UserOnboardingPage> {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  int _currentPage = 0;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),

              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildContactInfoPage(),
                    _buildPrivacyExplanationPage(),
                    _buildCompletePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const TrueCircleLogo(
            size: 30,
            showText: false,
            style: LogoStyle.icon,
          ),
          const SizedBox(width: 12),
          // Language Toggle
          GestureDetector(
            onTap: () {
              setState(() {
                selectedLanguage =
                    selectedLanguage == 'English' ? 'Hindi' : 'English';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                selectedLanguage == 'English' ? 'EN' : 'हि',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Progress dots
          Expanded(
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        // Added scrollable container
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TrueCircle Logo/Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 80,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              selectedLanguage == 'English'
                  ? 'Welcome to TrueCircle!'
                  : 'TrueCircle में आपका स्वागत है!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              selectedLanguage == 'English'
                  ? 'Your AI-powered relationship advisor that works completely offline for your privacy and convenience.'
                  : 'आपका AI-संचालित रिश्ते सलाहकार जो आपकी गोपनीयता और सुविधा के लिए पूर्णतः ऑफलाइन काम करता है।',
              style: const TextStyle(
                fontSize: 16,
                color: Colors
                    .black87, // Changed from grey to black87 for better readability
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Key Features
            _buildFeatureItem(
              Icons.security,
              selectedLanguage == 'English'
                  ? 'Complete Privacy'
                  : 'पूर्ण गोपनीयता',
              selectedLanguage == 'English'
                  ? 'All data stays on your device'
                  : 'सभी डेटा आपके डिवाइस में रहता है',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              Icons.psychology,
              selectedLanguage == 'English' ? 'AI Therapy' : 'AI थेरेपी',
              selectedLanguage == 'English'
                  ? '24/7 Dr. Iris support'
                  : '24/7 डॉ. आइरिस सहायता',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              Icons.wifi_off,
              selectedLanguage == 'English'
                  ? 'Works Offline'
                  : 'ऑफलाइन काम करता है',
              selectedLanguage == 'English'
                  ? 'No internet required'
                  : 'इंटरनेट की आवश्यकता नहीं',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _nextPage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedLanguage == 'English' ? 'Get Started' : 'शुरू करें',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ), // Column closing bracket
      ), // SingleChildScrollView closing bracket
    ); // Padding closing bracket
  }

  Widget _buildContactInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedLanguage == 'English'
                ? 'Optional Contact Information'
                : 'वैकल्पिक संपर्क जानकारी',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.amber.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedLanguage == 'English'
                        ? 'Sharing your contact info is completely OPTIONAL. TrueCircle works fully offline, but having your info helps us:'
                        : 'आपकी संपर्क जानकारी देना पूर्णतः वैकल्पिक है। TrueCircle पूरी तरह ऑफलाइन काम करता है, लेकिन आपकी जानकारी से हमें मदद मिलती है:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Benefits of sharing contact
          _buildBenefitItem(
            Icons.emergency,
            selectedLanguage == 'English'
                ? 'Emergency Support'
                : 'आपातकालीन सहायता',
            selectedLanguage == 'English'
                ? 'Critical mental health crisis alerts'
                : 'गंभीर मानसिक स्वास्थ्य संकट अलर्ट',
          ),

          const SizedBox(height: 12),

          _buildBenefitItem(
            Icons.update,
            selectedLanguage == 'English'
                ? 'Important Updates'
                : 'महत्वपूर्ण अपडेट',
            selectedLanguage == 'English'
                ? 'New AI features & security patches'
                : 'नए AI फीचर्स और सिक्यूरिटी पैच',
          ),

          const SizedBox(height: 12),

          _buildBenefitItem(
            Icons.backup,
            selectedLanguage == 'English' ? 'Data Recovery' : 'डेटा रिकवरी',
            selectedLanguage == 'English'
                ? 'Help restore your data if device is lost'
                : 'डिवाइस खो जाने पर डेटा रिस्टोर करने में मदद',
          ),

          const SizedBox(height: 32),

          // Phone Number Input
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: selectedLanguage == 'English'
                  ? 'Phone Number (Optional)'
                  : 'फोन नंबर (वैकल्पिक)',
              hintText: selectedLanguage == 'English'
                  ? '+91 9876543210'
                  : '+91 9876543210',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _phoneController.text.length > 10
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
            ],
            onChanged: (value) {
              setState(() {
                // Simple validation for UI feedback
              });
            },
          ),

          const SizedBox(height: 16),

          // Name Input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: selectedLanguage == 'English'
                  ? 'Your Name (Optional)'
                  : 'आपका नाम (वैकल्पिक)',
              hintText: selectedLanguage == 'English'
                  ? 'How should Dr. Iris address you?'
                  : 'डॉ. आइरिस आपको कैसे संबोधित करें?',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const Spacer(),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _skipContactInfo(),
                  child: Text(
                    selectedLanguage == 'English'
                        ? 'Skip (Continue Offline)'
                        : 'छोड़ें (ऑफलाइन जारी रखें)',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _nextPage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    selectedLanguage == 'English' ? 'Continue' : 'आगे बढ़ें',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyExplanationPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedLanguage == 'English'
                ? 'Your Privacy Guarantee'
                : 'आपकी गोपनीयता की गारंटी',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined,
                    color: Colors.green.shade600, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedLanguage == 'English'
                        ? '100% Offline Privacy\nYour data NEVER leaves your device'
                        : '100% ऑफलाइन गोपनीयता\nआपका डेटा कभी भी आपके डिवाइस से बाहर नहीं जाता',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Points
          _buildPrivacyPoint(
            Icons.lock,
            selectedLanguage == 'English'
                ? 'Local Storage Only'
                : 'केवल स्थानीय भंडारण',
            selectedLanguage == 'English'
                ? 'All conversations with Dr. Iris stay on your phone'
                : 'डॉ. आइरिस के साथ सभी बातचीत आपके फोन में रहती है',
          ),

          const SizedBox(height: 16),

          _buildPrivacyPoint(
            Icons.wifi_off,
            selectedLanguage == 'English'
                ? 'No Internet Required'
                : 'इंटरनेट की जरूरत नहीं',
            selectedLanguage == 'English'
                ? 'AI therapy works completely offline'
                : 'AI थेरेपी पूर्णतः ऑफलाइन काम करती है',
          ),

          const SizedBox(height: 16),

          _buildPrivacyPoint(
            Icons.visibility_off,
            selectedLanguage == 'English'
                ? 'No Data Collection'
                : 'डेटा संग्रह नहीं',
            selectedLanguage == 'English'
                ? 'We cannot see or access your personal information'
                : 'हम आपकी व्यक्तिगत जानकारी देख या एक्सेस नहीं कर सकते',
          ),

          const SizedBox(height: 32),

          // Contact info usage explanation
          if (_phoneController.text.isNotEmpty ||
              _nameController.text.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Text(
                        selectedLanguage == 'English'
                            ? 'Contact Usage:'
                            : 'संपर्क का उपयोग:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedLanguage == 'English'
                        ? '• Emergency mental health support only\n• Critical security updates\n• Never shared with third parties\n• You can delete anytime in settings'
                        : '• केवल आपातकालीन मानसिक स्वास्थ्य सहायता\n• महत्वपूर्ण सुरक्षा अपडेट\n• कभी भी तीसरे पक्ष के साथ साझा नहीं\n• सेटिंग्स में कभी भी डिलीट कर सकते हैं',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _nextPage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                selectedLanguage == 'English'
                    ? 'I Understand & Continue'
                    : 'मैं समझता हूं और आगे बढ़ता हूं',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    final hasContactInfo =
        _phoneController.text.isNotEmpty || _nameController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            selectedLanguage == 'English' ? 'Setup Complete!' : 'सेटअप पूर्ण!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            selectedLanguage == 'English'
                ? 'TrueCircle is ready to help you with your relationships and emotional well-being.'
                : 'TrueCircle आपके रिश्तों और भावनात्मक कल्याण में मदद के लिए तैयार है।',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Setup Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildSummaryItem(
                  Icons.psychology,
                  selectedLanguage == 'English'
                      ? 'Dr. Iris AI Therapy'
                      : 'डॉ. आइरिस AI थेरेपी',
                  selectedLanguage == 'English'
                      ? 'Ready for 24/7 support'
                      : '24/7 सहायता के लिए तैयार',
                  Colors.blue,
                ),
                const Divider(),
                _buildSummaryItem(
                  Icons.security,
                  selectedLanguage == 'English'
                      ? 'Privacy Mode'
                      : 'गोपनीयता मोड',
                  selectedLanguage == 'English'
                      ? 'Complete offline protection'
                      : 'पूर्ण ऑफलाइन सुरक्षा',
                  Colors.green,
                ),
                const Divider(),
                _buildSummaryItem(
                  hasContactInfo ? Icons.phone : Icons.phone_disabled,
                  selectedLanguage == 'English'
                      ? 'Contact Info'
                      : 'संपर्क जानकारी',
                  hasContactInfo
                      ? (selectedLanguage == 'English'
                          ? 'Provided for emergency support'
                          : 'आपातकालीन सहायता के लिए दी गई')
                      : (selectedLanguage == 'English'
                          ? 'Not provided (Fully offline)'
                          : 'नहीं दी गई (पूर्णतः ऑफलाइन)'),
                  hasContactInfo ? Colors.orange : Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeOnboarding(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedLanguage == 'English'
                        ? 'Start Using TrueCircle'
                        : 'TrueCircle का उपयोग शुरू करें',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade600, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPoint(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        // Use Dr. Iris Avatar for therapy-related items
        title.contains('Dr. Iris') || title.contains('डॉ. आइरिस')
            ? DrIrisAvatar(
                size: 24,
                showName: false,
                isHindi: selectedLanguage == 'हिन्दी',
              )
            : Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipContactInfo() {
    // Clear contact info and move to privacy page
    _phoneController.clear();
    _nameController.clear();
    _nextPage();
  }

  void _completeOnboarding() async {
    // Save user preferences locally
    await _saveUserPreferences();

    // Navigate to main app
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Mark onboarding as completed
      await prefs.setBool('is_first_time', false);

      // Save user data if provided
      if (_nameController.text.isNotEmpty) {
        await prefs.setString('user_name', _nameController.text);
      }

      if (_phoneController.text.isNotEmpty) {
        await prefs.setString('user_phone', _phoneController.text);
        await prefs.setBool('emergency_contact_provided', true);
      }

      // Save language preference
      await prefs.setString('preferred_language', selectedLanguage);

      // Save setup timestamp
      await prefs.setString(
          'setup_completed_at', DateTime.now().toIso8601String());

      debugPrint('✅ User preferences saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving user preferences: $e');
      // Continue anyway - user can set preferences later
    }
  }
}
