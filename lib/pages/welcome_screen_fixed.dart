import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  String _selectedLanguage = 'English';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _changeLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1A1A2E),
        ),
        child: DropdownButton<String>(
          value: _selectedLanguage,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _changeLanguage(newValue);
            }
          },
          items: ['English', 'Hindi']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          underline: Container(),
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final isSmallScreen = screenHeight < 600;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 48.0 : 24.0,
                      vertical: isSmallScreen ? 16.0 : 24.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Section - Bringing clarity text
                        Column(
                          children: [
                            SizedBox(height: isSmallScreen ? 10 : 20),
                            const Text(
                              'Bringing clarity',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // Center Section - Logo and welcome text
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: isWeb ? 140 : 120,
                                height: isWeb ? 140 : 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(isWeb ? 70 : 60),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(isWeb ? 70 : 60),
                                  child: Image.asset(
                                    'assets/images/truecircle_logo.png', // Fixed logo path
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(isWeb ? 70 : 60),
                                        ),
                                        child: Icon(
                                          Icons.psychology,
                                          size: isWeb ? 70 : 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              Text(
                                'TrueCircle',
                                style: TextStyle(
                                  fontSize: isWeb ? 36 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 12 : 16),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: isWeb ? 64 : 0),
                                child: Text(
                                  _selectedLanguage == 'Hindi'
                                      ? 'रिश्तों को समझें, भावनाओं को पहचानें'
                                      : 'Understanding relationships through emotional intelligence',
                                  style: TextStyle(
                                    fontSize: isWeb ? 18 : 16,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Section - Language selector and button
                        Column(
                          children: [
                            if (isWeb) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLanguageSelector(),
                                ],
                              ),
                            ] else ...[
                              _buildLanguageSelector(),
                            ],

                            SizedBox(height: isSmallScreen ? 24 : 32),

                            SizedBox(
                              width: isWeb ? 400 : double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _navigateToHome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1A1A2E),
                                  elevation: 8,
                                  shadowColor: Colors.black.withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  _selectedLanguage == 'Hindi'
                                      ? 'अपनी यात्रा शुरू करें'
                                      : 'Start your journey',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 16 : 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}