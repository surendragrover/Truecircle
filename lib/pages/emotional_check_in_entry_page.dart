import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/on_device_ai_service.dart';
import '../services/ai_orchestrator_service.dart';
import '../core/service_locator.dart';

/// Emotional Check-In Entry Page
/// Allows user to enter current mood, feelings, notes. AI provides analysis & stress score.
class EmotionalCheckInEntryPage extends StatefulWidget {
  const EmotionalCheckInEntryPage({super.key});

  @override
  State<EmotionalCheckInEntryPage> createState() =>
      _EmotionalCheckInEntryPageState();
}

class _EmotionalCheckInEntryPageState extends State<EmotionalCheckInEntryPage> {
  final _formKey = GlobalKey<FormState>();
  double _moodScore = 5; // 1-10
  final TextEditingController _feelingsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isAnalyzing = false;
  String? _analysisResult; // AI summary
  String? _stressLevel; // Low/Medium/High
  OnDeviceAIService? _aiService;
  bool _aiReady = false;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _restorePrefs();
    _initAI();
  }

  Future<void> _restorePrefs() async {
    try {
      final box = await Hive.openBox('truecircle_settings');
      _language =
          box.get('home_language_pref', defaultValue: 'English') as String;
      setState(() {});
    } catch (_) {}
  }

  Future<void> _initAI() async {
    try {
      final settings = await Hive.openBox('truecircle_settings');
      final phone = settings.get('current_phone_number') as String?;
      final models = phone != null
          ? settings.get('${phone}_models_downloaded', defaultValue: false)
              as bool
          : false;
      if (models) {
        _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
        _aiReady = true;
      }
      setState(() {});
    } catch (_) {
      setState(() {
        _aiReady = false;
      });
    }
  }

  Future<void> _runAnalysis() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
      _stressLevel = null;
    });
    final text =
        '${_feelingsController.text}\nNotes: ${_notesController.text}\nMoodScore:${_moodScore.toStringAsFixed(0)}';
    try {
      if (_aiReady && _aiService != null) {
        final stress = await _aiService!.analyzeSentimentAndStress(text);
        final response = await _aiService!.generateDrIrisResponse(
            'Analyze this mood entry and give supportive feedback in ${_language == 'Hindi' ? 'Hindi' : 'English'}: $text');
        setState(() {
          _stressLevel = stress;
          _analysisResult = response;
        });
      } else {
        // Fallback deterministic sample analysis
        _stressLevel =
            _moodScore >= 7 ? 'Low' : (_moodScore >= 4 ? 'Medium' : 'High');
        _analysisResult = _language == 'Hindi'
            ? 'आपने जो भावनाएँ दर्ज की हैं उनसे लगता है कि आपकी स्थिति $_stressLevel stress स्तर में है। गहरी सांस लें और खुद को 5 मिनट का ब्रेक दें।'
            : 'Based on your entry you appear to be in $_stressLevel stress range. Take a deep breathing pause for 5 mins.';
        setState(() {});
      }
      await _persistEntry();
      // After persistence, refresh orchestrator immediately (if started)
      try {
        await AIOrchestratorService()
            .startIfPossible(); // ensure started if models just became ready
        await AIOrchestratorService().refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_language == 'Hindi'
                  ? 'AI अंतर्दृष्टि अपडेट की गई'
                  : 'AI insights updated'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (_) {}
    } catch (e) {
      setState(() {
        _analysisResult = 'Analysis failed: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _persistEntry() async {
    try {
      final box = await Hive.openBox('truecircle_emotional_entries');
      final entry = {
        'timestamp': DateTime.now().toIso8601String(),
        'mood_score': _moodScore.toInt(),
        'feelings': _feelingsController.text.trim(),
        'notes': _notesController.text.trim(),
        'stress': _stressLevel,
        'analysis': _analysisResult,
      };
      final existing =
          box.get('entries', defaultValue: <Map<String, dynamic>>[]) as List;
      existing.insert(0, entry);
      await box.put('entries', existing);
      // (Orchestrator refresh handled in _runAnalysis after persistence)
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant EmotionalCheckInEntryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _feelingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = _language == 'Hindi';
    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'Emotional Check-in' : 'Emotional Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  isHindi
                      ? 'आज आप कैसा महसूस कर रहे हैं?'
                      : 'How are you feeling today?',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(isHindi
                  ? 'मूड स्कोर (1 बहुत खराब, 10 उत्कृष्ट)'
                  : 'Mood Score (1 very low, 10 excellent)'),
              Slider(
                value: _moodScore,
                min: 1,
                max: 10,
                divisions: 9,
                label: _moodScore.toStringAsFixed(0),
                onChanged: (v) => setState(() => _moodScore = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _feelingsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isHindi
                      ? 'मुख्य भावनाएँ (कॉमा से अलग)'
                      : 'Primary feelings (comma separated)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (isHindi
                        ? 'कृपया कम से कम एक भावना लिखें'
                        : 'Enter at least one feeling')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: isHindi
                      ? 'नोट / क्या हो रहा है'
                      : 'Notes / What is happening',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isAnalyzing)
                const Center(child: CircularProgressIndicator()),
              if (!_isAnalyzing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _runAnalysis,
                    icon: const Icon(Icons.analytics),
                    label:
                        Text(isHindi ? 'AI विश्लेषण करें' : 'Run AI Analysis'),
                  ),
                ),
              const SizedBox(height: 24),
              if (_analysisResult != null) _buildAnalysisCard(isHindi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(bool isHindi) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isHindi ? 'AI विश्लेषण' : 'AI Analysis',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_stressLevel != null)
              Text(
                  isHindi
                      ? 'तनाव स्तर: $_stressLevel'
                      : 'Stress Level: $_stressLevel',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_analysisResult ?? ''),
            const SizedBox(height: 12),
            Text(
                isHindi
                    ? 'ध्यान दें: आपका डेटा डिवाइस से बाहर नहीं जाता।'
                    : 'Note: Your data never leaves your device.',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
