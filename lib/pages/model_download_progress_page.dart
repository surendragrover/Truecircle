import 'package:flutter/material.dart';
import 'dart:async';

import '../widgets/truecircle_logo.dart';
import '../services/ai_model_download_service.dart';
import '../theme/coral_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/loyalty_points_service.dart';

/// Model Download Progress Page
/// यह page number verification के बाद show होती है और user को wait कराती है
/// जब तक AI models download नहीं हो जाते
class ModelDownloadProgressPage extends StatefulWidget {
  const ModelDownloadProgressPage({super.key});

  @override
  State<ModelDownloadProgressPage> createState() => _ModelDownloadProgressPageState();
}

class _ModelDownloadProgressPageState extends State<ModelDownloadProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Timer? _downloadTimer;
  double _downloadProgress = 0.0;
  String _currentStep = '';
  String _platformInfo = '';
  bool _isDownloadComplete = false;
  bool _isHindi = true; // Default to Hindi for Indian users
  static const String _langPrefKey = 'model_download_language_pref';
  
  // AI Model Download Service
  final AIModelDownloadService _downloadService = AIModelDownloadService();
  StreamSubscription<double>? _progressSubscription;
  StreamSubscription<String>? _statusSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _restoreLanguagePref().then((_) => _detectPlatformAndStartDownload());
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _downloadTimer?.cancel();
    _progressSubscription?.cancel();
    _statusSubscription?.cancel();
    _downloadService.dispose();
    super.dispose();
  }
  
  void _detectPlatformAndStartDownload() {
    // Use actual platform detection from service
    final platformInfo = _downloadService.detectPlatform();
    _platformInfo = _isHindi 
        ? '${platformInfo.platform} के लिए ${platformInfo.modelName}'
        : '${platformInfo.modelName} for ${platformInfo.platform}';
    
    _startActualDownload();
  }

  Future<void> _restoreLanguagePref() async {
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      final stored = box.get(_langPrefKey) as bool?; // true = Hindi, false = English
      if (stored != null) {
        setState(() => _isHindi = stored);
      }
    } catch (_) {}
  }

  Future<void> _persistLanguagePref() async {
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      await box.put(_langPrefKey, _isHindi);
    } catch (_) {}
  }
  
  void _startActualDownload() async {
    // Check if models are already downloaded
    final alreadyDownloaded = await _downloadService.areModelsDownloaded();
    if (alreadyDownloaded) {
      setState(() {
        _currentStep = _isHindi ? 'Models पहले से downloaded हैं! ✅' : 'Models already downloaded! ✅';
        _downloadProgress = 1.0;
        _isDownloadComplete = true;
      });
        // Ensure Hive flag + sync
        _persistModelFlagAndSync();
      _navigateToNextPage();
      return;
    }

    // Subscribe to progress and status streams
    _progressSubscription = _downloadService.progressStream.listen((progress) {
      setState(() {
        _downloadProgress = progress;
        if (progress >= 1.0) {
          _isDownloadComplete = true;
          _progressController.forward();
        }
      });
    });

    _statusSubscription = _downloadService.statusStream.listen((status) {
      setState(() {
        _currentStep = status;
      });
    });

    // Start the actual download
    try {
      final success = await _downloadService.downloadModels();
      if (success) {
        setState(() {
          _currentStep = _isHindi ? 'Download पूरी हुई! ✅' : 'Download completed! ✅';
          _isDownloadComplete = true;
        });
        _persistModelFlagAndSync();
        _navigateToNextPage();
      } else {
        _handleDownloadError('Download failed');
      }
    } catch (e) {
      _handleDownloadError(e.toString());
    }
  }

  Future<void> _persistModelFlagAndSync() async {
    try {
      final auth = AuthService();
      final phone = auth.currentPhoneNumber;
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      await box.put('${phone ?? 'global'}_models_downloaded', true);

      // Trigger lightweight cloud sync (no sensitive data)
      final points = LoyaltyPointsService.instance.totalPoints;
      CloudSyncService.instance.syncUserState(
        loyaltyPoints: points,
        featuresCount: 0,
        modelsReady: true,
      );
    } catch (_) {
      // Silent fail
    }
  }

  void _handleDownloadError(String error) {
    setState(() {
      _currentStep = _isHindi 
          ? 'Download में समस्या: $error' 
          : 'Download error: $error';
      _downloadProgress = 0.0;
    });
    
    // Show retry option after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _showRetryDialog();
    });
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isHindi ? 'Download Failed' : 'Download Failed'),
        content: Text(_isHindi 
            ? 'Models download में समस्या हुई। दोबारा कोशिश करें?'
            : 'There was an issue downloading models. Retry?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNextPage(); // Skip download for now
            },
            child: Text(_isHindi ? 'बाद में' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startActualDownload(); // Retry download
            },
            child: Text(_isHindi ? 'दोबारा कोशिश करें' : 'Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToNextPage() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/how-truecircle-works');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: CoralTheme.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Language Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Switch(
                      value: _isHindi,
                      onChanged: (value) {
                        setState(() => _isHindi = value);
                        _persistLanguagePref();
                      },
                      activeThumbColor: CoralTheme.dark,
                      activeTrackColor: CoralTheme.base.withValues(alpha: 0.5),
                    ),
                    Text(
                      _isHindi ? 'हिं' : 'EN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Logo with pulse animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const TrueCircleLogo(size: 120),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Text(
                  _isHindi 
                      ? 'AI Models Download हो रहे हैं' 
                      : 'Downloading AI Models',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Platform info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    _platformInfo,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: CoralTheme.glowShadow(0.25),
                  ),
                  child: Column(
                    children: [
                      // Current step
                      Text(
                        _currentStep.isEmpty
                            ? (_isHindi ? 'शुरू कर रहे हैं...' : 'Starting...')
                            : _currentStep,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isDownloadComplete ? Colors.green : CoralTheme.dark,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Progress percentage
                      Text(
                        '${(_downloadProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isDownloadComplete ? Colors.green.shade700 : CoralTheme.dark,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Info message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: CoralTheme.translucentCard(alpha: 0.18, radius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isHindi
                            ? 'यह process सिर्फ एक बार होती है। Models download होने के बाद TrueCircle हमेशा offline काम करेगा।'
                            : 'This process happens only once. After models are downloaded, TrueCircle will work offline forever.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Bottom message
                if (!_isDownloadComplete) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _isHindi 
                            ? 'कृपया प्रतीक्षा करें...' 
                            : 'Please wait...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: CoralTheme.glowShadow(0.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              _isHindi 
                                  ? 'तैयार! आगे बढ़ें' 
                                  : 'Ready! Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CoralTheme.dark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => _navigateToNextPage(),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(_isHindi ? 'जारी रखें' : 'Continue'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}