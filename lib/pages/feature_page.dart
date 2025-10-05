import 'package:flutter/material.dart';
import '../widgets/truecircle_logo.dart';
import '../services/json_data_service.dart';

// Consistent turquoise (firozi) palette for all feature pages
const Color _firoziPrimary = Color(0xFF00BFA5); // main background
const Color _firoziDark = Color(0xFF00695C); // app bar / strong containers
const Color _firoziMid = Color(0xFF007D6C); // mid tone blocks

class FeaturePage extends StatefulWidget {
  final Map<String, dynamic> feature;
  final bool isHindi;

  const FeaturePage({
    super.key,
    required this.feature,
    required this.isHindi,
  });

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  late Map<String, dynamic> feature;
  late bool isHindi;
  bool _isLoading = true;
  List<dynamic> _sampleData = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    feature = widget.feature;
    isHindi = widget.isHindi;
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final jsonService = JsonDataService.instance;
      List<dynamic> data = [];

      // Load appropriate data based on feature with timeout
      switch (feature['title']) {
        case 'Emotional Check-in':
          data = await jsonService.getEmotionalCheckInData().timeout(
                const Duration(seconds: 10),
                onTimeout: () => [],
              );
          break;
        case 'Mood Journal':
          final moodData = await jsonService.getMoodJournalData().timeout(
                const Duration(seconds: 10),
                onTimeout: () => {'entries': []},
              );
          data = moodData['entries'] ?? [];
          break;
        case 'Relationship Insights':
          data = await jsonService.getRelationshipData().timeout(
                const Duration(seconds: 10),
                onTimeout: () => [],
              );
          break;
        case 'Festival Reminders':
          final festivalData = await jsonService.getFestivalsData().timeout(
                const Duration(seconds: 10),
                onTimeout: () => {'festivals': []},
              );
          data = festivalData['festivals'] ?? [];
          break;
        case 'Meditation Guide':
          data = await jsonService.getMeditationData().timeout(
                const Duration(seconds: 10),
                onTimeout: () => [],
              );
          break;
        case 'Breathing Exercises':
          data = await jsonService.getBreathingData().timeout(
                const Duration(seconds: 10),
                onTimeout: () => [],
              );
          break;
        case 'Progress Tracker':
          // Generate mock progress data
          data = _getMockProgressData();
          break;
        default:
          data = []; // No specific data for this feature yet
      }

      if (mounted) {
        setState(() {
          _sampleData = data.toList(); // Show all entries
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading data: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _firoziPrimary, // Uniform firozi background
      appBar: AppBar(
        backgroundColor: _firoziDark, // Firozi dark
        elevation: 2,
        title: Row(
          children: [
            TrueCircleLogo(
              size: 35,
              showText: false,
              isHindi: isHindi,
              style: LogoStyle.compass,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isHindi ? feature['titleHi'] : feature['title'],
                style: const TextStyle(
                  color: Colors.black, // Jet black text
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Language Toggle
          IconButton(
            onPressed: () {
              setState(() {
                isHindi = !isHindi;
              });
            },
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            tooltip: isHindi ? 'English' : 'हिंदी',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_firoziDark, _firoziMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _firoziPrimary.withValues(alpha: 0.6),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_firoziPrimary, _firoziDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _firoziPrimary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Icon(
                      feature['icon'],
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHindi ? feature['titleHi'] : feature['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi
                        ? (feature['descriptionHi'] ??
                            feature['description'] ??
                            '')
                        : (feature['description'] ??
                            feature['descriptionHi'] ??
                            ''),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      feature['demoCount'] ?? '30 Days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Features Overview
            Text(
              isHindi ? 'फीचर्स' : 'Features',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureContent(),

            const SizedBox(height: 24),

            // Coming Soon Notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_firoziMid, _firoziDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.construction,
                    size: 48,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHindi
                        ? 'यह फीचर उपलब्ध है!\nअपने डेटा को ट्रैक करना शुरू करें।'
                        : 'This feature is available!\nStart tracking your data.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_firoziMid, _firoziDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                feature['icon'],
                color: feature['color'],
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isHindi
                      ? '${feature['titleHi']} (${_sampleData.length} entries)'
                      : '${feature['title']} (${_sampleData.length} entries)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show today's tip for meditation and breathing exercises
          if (feature['title'] == 'Meditation Guide')
            _buildTodaysMeditationTip(),
          if (feature['title'] == 'Breathing Exercises')
            _buildTodaysBreathingTip(),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            )
          else if (_sampleData.isEmpty)
            Text(
              isHindi ? 'कोई डेटा उपलब्ध नहीं है।' : 'No data available.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            )
          else
            SizedBox(
              height: 400, // Fixed height for scroll performance
              child: ListView.builder(
                itemCount: _sampleData.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = _sampleData[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_firoziDark, _firoziMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_firoziPrimary, _firoziDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            feature['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getItemTitle(item),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getItemSubtitle(item),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getItemTitle(dynamic item) {
    // Extract title based on data structure
    if (item is Map<String, dynamic>) {
      // For Progress Tracker
      if (item['value'] != null) {
        final title =
            isHindi ? (item['title_hindi'] ?? item['title']) : item['title'];
        final value =
            isHindi ? (item['value_hindi'] ?? item['value']) : item['value'];
        return '$title: $value';
      }
      return item['title'] ??
          item['name'] ??
          item['festival_name'] ??
          item['date'] ??
          'Item';
    }
    return 'Data Entry';
  }

  String _getItemSubtitle(dynamic item) {
    // Extract subtitle based on data structure
    if (item is Map<String, dynamic>) {
      // For Progress Tracker
      if (item['progress'] != null) {
        final description = isHindi
            ? (item['description_hindi'] ?? item['description'])
            : item['description'];
        final progress = ((item['progress'] ?? 0.0) * 100).toInt();
        return '$description • $progress% progress';
      }
      return item['description'] ??
          item['mood'] ??
          item['emotion'] ??
          item['date'] ??
          'No description';
    }
    return 'Entry details';
  }

  Widget _buildTodaysMeditationTip() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: JsonDataService.instance.getTodaysMeditationTip(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

        final tip = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.today, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'आज का ध्यान अभ्यास' : 'Today\'s Meditation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and Duration
              Text(
                isHindi
                    ? (tip['title_hindi'] ??
                        tip['title'] ??
                        'Meditation Session')
                    : (tip['title'] ??
                        tip['title_hindi'] ??
                        'Meditation Session'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHindi
                      ? '${tip['duration_minutes']} मिनट • ${tip['type_hindi'] ?? tip['type']} • ${tip['difficulty']}'
                      : '${tip['duration_minutes']} minutes • ${tip['type'] ?? tip['type_hindi']} • ${tip['difficulty']}',
                  style: TextStyle(
                    color: Colors.green[100],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              if (tip['description_hindi'] != null ||
                  tip['description'] != null) ...[
                Text(
                  isHindi ? 'विवरण:' : 'Description:',
                  style: TextStyle(
                    color: Colors.green[100],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi
                      ? (tip['description_hindi'] ?? tip['description'] ?? '')
                      : (tip['description'] ?? tip['description_hindi'] ?? ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Step-by-step instructions
              Text(
                isHindi ? 'ध्यान के चरण:' : 'Meditation Steps:',
                style: TextStyle(
                  color: Colors.green[100],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Instructions based on meditation type
              ..._getMeditationSteps(tip, isHindi),

              const SizedBox(height: 12),

              // Mantra information for mantra meditation
              if (tip['mantra'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.green[100], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isHindi ? 'मंत्र:' : 'Mantra:',
                            style: TextStyle(
                              color: Colors.green[100],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[800]!.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tip['mantra'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (tip['mantra_meaning'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          isHindi ? 'अर्थ:' : 'Meaning:',
                          style: TextStyle(
                            color: Colors.green[100],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['mantra_meaning'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (tip['mantra_repetitions'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.repeat,
                                color: Colors.green[100], size: 14),
                            const SizedBox(width: 4),
                            Text(
                              isHindi
                                  ? 'जप संख्या: ${tip['mantra_repetitions']} बार'
                                  : 'Repetitions: ${tip['mantra_repetitions']} times',
                              style: TextStyle(
                                color: Colors.green[100],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Mood Effect
              if (tip['mood_effect_hindi'] != null ||
                  tip['mood_effect'] != null) ...[
                Row(
                  children: [
                    Icon(Icons.mood, color: Colors.green[100], size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isHindi
                            ? 'प्रभाव: ${tip['mood_effect_hindi'] ?? tip['mood_effect'] ?? ''}'
                            : 'Effect: ${tip['mood_effect'] ?? tip['mood_effect_hindi'] ?? ''}',
                        style: TextStyle(
                          color: Colors.green[100],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getMeditationSteps(Map<String, dynamic> tip, bool isHindi) {
    final type = tip['type']?.toLowerCase() ?? '';

    List<String> steps = [];

    switch (type) {
      case 'pranayama':
        steps = isHindi
            ? [
                '1. आराम से बैठें, रीढ़ सीधी रखें',
                '2. आंखें बंद करें और सामान्य सांस लें',
                '3. नाक से धीरे-धीरे सांस अंदर लें (4 गिनती)',
                '4. सांस को रोकें (4 गिनती)',
                '5. मुंह से धीरे-धीरे सांस छोड़ें (6 गिनती)',
                '6. इस प्रक्रिया को ${tip['duration_minutes']} मिनट तक दोहराएं'
              ]
            : [
                '1. Sit comfortably with spine straight',
                '2. Close eyes and breathe normally',
                '3. Inhale slowly through nose (count 4)',
                '4. Hold breath (count 4)',
                '5. Exhale slowly through mouth (count 6)',
                '6. Repeat for ${tip['duration_minutes']} minutes'
              ];
        break;

      case 'mindfulness':
        steps = isHindi
            ? [
                '1. शांत जगह में आराम से बैठें',
                '2. आंखें बंद करें या अधखुली रखें',
                '3. अपनी सांस पर ध्यान दें',
                '4. विचारों को आने-जाने दें, उन्हें रोकने की कोशिश न करें',
                '5. जब मन भटके तो वापस सांस पर ध्यान लाएं',
                '6. ${tip['duration_minutes']} मिनट तक इसी अवस्था में रहें'
              ]
            : [
                '1. Sit comfortably in quiet place',
                '2. Close eyes or keep them half-open',
                '3. Focus on your breathing',
                '4. Let thoughts come and go without resistance',
                '5. When mind wanders, gently return to breath',
                '6. Continue for ${tip['duration_minutes']} minutes'
              ];
        break;

      case 'loving-kindness':
        steps = isHindi
            ? [
                '1. आराम से बैठें और आंखें बंद करें',
                '2. अपने लिए प्रेम की भावना लाएं',
                '3. "मैं खुश रहूं, स्वस्थ रहूं" कहें',
                '4. अपने प्रियजनों के लिए यही भावना भेजें',
                '5. सभी जीवों के लिए प्रेम और करुणा की भावना रखें',
                '6. ${tip['duration_minutes']} मिनट तक इस अभ्यास को जारी रखें'
              ]
            : [
                '1. Sit comfortably and close eyes',
                '2. Generate feelings of love for yourself',
                '3. Say "May I be happy, may I be healthy"',
                '4. Send same feelings to loved ones',
                '5. Extend love and compassion to all beings',
                '6. Continue practice for ${tip['duration_minutes']} minutes'
              ];
        break;

      case 'body scan':
        steps = isHindi
            ? [
                '1. लेटें या आराम से बैठें',
                '2. आंखें बंद करें और गहरी सांस लें',
                '3. पैर की उंगलियों से शुरू करें',
                '4. शरीर के हर हिस्से पर ध्यान दें',
                '5. तनाव महसूस करें और उसे छोड़ दें',
                '6. सिर तक पहुंचने तक यह प्रक्रिया जारी रखें'
              ]
            : [
                '1. Lie down or sit comfortably',
                '2. Close eyes and take deep breaths',
                '3. Start from your toes',
                '4. Focus attention on each body part',
                '5. Feel tension and let it go',
                '6. Continue until you reach the top of head'
              ];
        break;

      case 'mantra meditation':
        final mantra = tip['mantra'] ?? (isHindi ? 'ॐ' : 'Om');
        final repetitions = tip['mantra_repetitions'] ?? 108;
        steps = isHindi
            ? [
                '1. आराम से बैठें, रीढ़ सीधी रखें',
                '2. आंखें बंद करें और गहरी सांस लें',
                '3. अपने मन को शांत करें',
                '4. मंत्र "$mantra" को मन में या धीरे से बोलें',
                '5. मंत्र की ध्वनि और कंपन पर ध्यान दें',
                '6. $repetitions बार मंत्र जप करें',
                '7. ${tip['duration_minutes']} मिनट तक या मन की शांति तक जारी रखें'
              ]
            : [
                '1. Sit comfortably with spine straight',
                '2. Close your eyes and take deep breaths',
                '3. Calm your mind',
                '4. Repeat the mantra "$mantra" mentally or softly',
                '5. Focus on the sound and vibration of the mantra',
                '6. Chant the mantra $repetitions times',
                '7. Continue for ${tip['duration_minutes']} minutes or until mind is peaceful'
              ];
        break;

      default:
        steps = isHindi
            ? [
                '1. शांत और आरामदायक जगह खोजें',
                '2. आराम से बैठें, रीढ़ सीधी रखें',
                '3. आंखें बंद करें',
                '4. अपनी सांस पर ध्यान दें',
                '5. मन को शांत रखने की कोशिश करें',
                '6. ${tip['duration_minutes']} मिनट तक इसी अवस्था में रहें'
              ]
            : [
                '1. Find quiet and comfortable place',
                '2. Sit comfortably with spine straight',
                '3. Close your eyes',
                '4. Focus on your breathing',
                '5. Try to keep mind calm',
                '6. Continue for ${tip['duration_minutes']} minutes'
              ];
    }

    return steps
        .map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildTodaysBreathingTip() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: JsonDataService.instance.getTodaysBreathingTip(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

        final tip = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[400]!, Colors.teal[600]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.today, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isHindi
                        ? 'आज का श्वास अभ्यास'
                        : 'Today\'s Breathing Exercise',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and Duration
              Text(
                isHindi
                    ? (tip['technique_hindi'] ??
                        tip['technique'] ??
                        'Breathing Technique')
                    : (tip['technique'] ??
                        tip['technique_hindi'] ??
                        'Breathing Technique'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isHindi
                          ? '${tip['duration_minutes']} मिनट'
                          : '${tip['duration_minutes']} minutes',
                      style: TextStyle(
                        color: Colors.teal[100],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return Icon(
                      index < (tip['effectiveness'] ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber[300],
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 4),
                  Text(
                    '${tip['effectiveness']}/5',
                    style: TextStyle(
                      color: Colors.teal[100],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step-by-step instructions
              Text(
                isHindi ? 'श्वास तकनीक के चरण:' : 'Breathing Steps:',
                style: TextStyle(
                  color: Colors.teal[100],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Instructions based on breathing technique
              ..._getBreathingSteps(tip, isHindi),

              const SizedBox(height: 12),

              // Benefits
              if (tip['physical_sensation_hindi'] != null ||
                  tip['mental_clarity_hindi'] != null ||
                  tip['physical_sensation'] != null ||
                  tip['mental_clarity'] != null) ...[
                Row(
                  children: [
                    Icon(Icons.healing, color: Colors.teal[100], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isHindi ? 'लाभ:' : 'Benefits:',
                      style: TextStyle(
                        color: Colors.teal[100],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (tip['physical_sensation_hindi'] != null ||
                    tip['physical_sensation'] != null)
                  Text(
                    isHindi
                        ? '• शारीरिक: ${tip['physical_sensation_hindi'] ?? tip['physical_sensation'] ?? ''}'
                        : '• Physical: ${tip['physical_sensation'] ?? tip['physical_sensation_hindi'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                if (tip['mental_clarity_hindi'] != null ||
                    tip['mental_clarity'] != null)
                  Text(
                    isHindi
                        ? '• मानसिक: ${tip['mental_clarity_hindi'] ?? tip['mental_clarity'] ?? ''}'
                        : '• Mental: ${tip['mental_clarity'] ?? tip['mental_clarity_hindi'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getBreathingSteps(Map<String, dynamic> tip, bool isHindi) {
    final technique = tip['technique']?.toLowerCase() ?? '';

    List<String> steps = [];

    switch (technique) {
      case 'anulom-vilom':
        steps = isHindi
            ? [
                '1. पद्मासन या सुखासन में बैठें',
                '2. दाएं हाथ से नासिका मुद्रा बनाएं',
                '3. अंगूठे से दाईं नासिका बंद करें',
                '4. बाईं नासिका से 4 गिनती तक सांस लें',
                '5. दोनों नासिका बंद करके 2 गिनती रोकें',
                '6. दाईं नासिका से 4 गिनती तक सांस छोड़ें',
                '7. ${tip['duration_minutes']} मिनट तक दोहराएं'
              ]
            : [
                '1. Sit in Padmasana or comfortable position',
                '2. Make Nasika mudra with right hand',
                '3. Close right nostril with thumb',
                '4. Inhale through left nostril (count 4)',
                '5. Close both nostrils, hold (count 2)',
                '6. Exhale through right nostril (count 4)',
                '7. Repeat for ${tip['duration_minutes']} minutes'
              ];
        break;

      case 'bhramari':
        steps = isHindi
            ? [
                '1. शांत स्थान पर आराम से बैठें',
                '2. अंगूठों से कान बंद करें',
                '3. तर्जनी उंगलियों को आंखों के ऊपर रखें',
                '4. बाकी उंगलियों को चेहरे पर रखें',
                '5. गहरी सांस लें',
                '6. सांस छोड़ते समय "हम्म्म" की आवाज करें',
                '7. ${tip['duration_minutes']} मिनट तक करें'
              ]
            : [
                '1. Sit comfortably in quiet place',
                '2. Close ears with thumbs',
                '3. Place index fingers above eyes',
                '4. Rest other fingers on face',
                '5. Take deep breath',
                '6. Make "Hmmm" sound while exhaling',
                '7. Continue for ${tip['duration_minutes']} minutes'
              ];
        break;

      case 'kapalbhati':
        steps = isHindi
            ? [
                '1. पद्मासन में बैठें, रीढ़ सीधी रखें',
                '2. दोनों हाथ घुटनों पर रखें',
                '3. तेज़ी से पेट को अंदर करके सांस छोड़ें',
                '4. सांस अंदर लेना अपने आप होगा',
                '5. 10-15 बार तेज़ी से करें',
                '6. फिर सामान्य सांस लें',
                '7. यह चक्र ${tip['duration_minutes']} मिनट तक दोहराएं'
              ]
            : [
                '1. Sit in Padmasana, spine straight',
                '2. Place hands on knees',
                '3. Forcefully contract belly and exhale',
                '4. Inhalation will happen automatically',
                '5. Do 10-15 rapid breaths',
                '6. Then breathe normally',
                '7. Repeat cycles for ${tip['duration_minutes']} minutes'
              ];
        break;

      case '4-7-8 breathing':
        steps = isHindi
            ? [
                '1. आराम से बैठें या लेटें',
                '2. जीभ को तालू से लगाएं',
                '3. मुंह से पूरी सांस छोड़ें',
                '4. नाक से 4 गिनती तक सांस लें',
                '5. 7 गिनती तक सांस रोकें',
                '6. मुंह से 8 गिनती तक सांस छोड़ें',
                '7. यह चक्र 4 बार दोहराएं'
              ]
            : [
                '1. Sit or lie down comfortably',
                '2. Touch tongue to roof of mouth',
                '3. Exhale completely through mouth',
                '4. Inhale through nose (count 4)',
                '5. Hold breath (count 7)',
                '6. Exhale through mouth (count 8)',
                '7. Repeat cycle 4 times'
              ];
        break;

      case 'box breathing':
        steps = isHindi
            ? [
                '1. आराम से बैठें, पीठ सीधी रखें',
                '2. नाक से 4 गिनती तक सांस लें',
                '3. 4 गिनती तक सांस रोकें',
                '4. 4 गिनती तक सांस छोड़ें',
                '5. 4 गिनती तक रुकें',
                '6. यह बॉक्स पैटर्न बनता है',
                '7. ${tip['duration_minutes']} मिनट तक जारी रखें'
              ]
            : [
                '1. Sit comfortably, back straight',
                '2. Inhale through nose (count 4)',
                '3. Hold breath (count 4)',
                '4. Exhale (count 4)',
                '5. Hold empty (count 4)',
                '6. This creates box pattern',
                '7. Continue for ${tip['duration_minutes']} minutes'
              ];
        break;

      default:
        steps = isHindi
            ? [
                '1. शांत और आरामदायक जगह खोजें',
                '2. आराम से बैठें या लेटें',
                '3. आंखें बंद करें',
                '4. धीरे-धीरे गहरी सांस लें',
                '5. सांस की गति पर ध्यान दें',
                '6. तनाव को सांस के साथ बाहर निकालें',
                '7. ${tip['duration_minutes']} मिनट तक जारी रखें'
              ]
            : [
                '1. Find quiet and comfortable space',
                '2. Sit or lie down comfortably',
                '3. Close your eyes',
                '4. Take slow, deep breaths',
                '5. Focus on rhythm of breathing',
                '6. Release tension with each exhale',
                '7. Continue for ${tip['duration_minutes']} minutes'
              ];
    }

    return steps
        .map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Map<String, dynamic>> _getMockProgressData() {
    return [
      {
        'title': 'Meditation Streak',
        'title_hindi': 'ध्यान की लकीर',
        'value': '7 days',
        'value_hindi': '7 दिन',
        'description': 'Daily meditation practice',
        'description_hindi': 'दैनिक ध्यान अभ्यास',
        'progress': 0.7,
        'icon': 'meditation',
        'color': 'green'
      },
      {
        'title': 'Mood Stability',
        'title_hindi': 'मूड स्थिरता',
        'value': '85%',
        'value_hindi': '85%',
        'description': 'Consistent emotional balance',
        'description_hindi': 'निरंतर भावनात्मक संतुलन',
        'progress': 0.85,
        'icon': 'mood',
        'color': 'blue'
      },
      {
        'title': 'Breathing Exercises',
        'title_hindi': 'श्वास अभ्यास',
        'value': '12 sessions',
        'value_hindi': '12 सत्र',
        'description': 'Weekly breathing practice',
        'description_hindi': 'साप्ताहिक श्वास अभ्यास',
        'progress': 0.6,
        'icon': 'air',
        'color': 'teal'
      },
      {
        'title': 'Sleep Quality',
        'title_hindi': 'नींद की गुणवत्ता',
        'value': '7.2 hrs avg',
        'value_hindi': '7.2 घंटे औसत',
        'description': 'Average sleep duration',
        'description_hindi': 'औसत नींद की अवधि',
        'progress': 0.9,
        'icon': 'sleep',
        'color': 'purple'
      },
      {
        'title': 'Emotional Check-ins',
        'title_hindi': 'भावनात्मक जांच',
        'value': '21 entries',
        'value_hindi': '21 प्रविष्टियां',
        'description': 'Monthly emotional tracking',
        'description_hindi': 'मासिक भावनात्मक ट्रैकिंग',
        'progress': 0.75,
        'icon': 'favorite',
        'color': 'red'
      },
      {
        'title': 'Festival Participation',
        'title_hindi': 'त्योहार भागीदारी',
        'value': '3 festivals',
        'value_hindi': '3 त्योहार',
        'description': 'Cultural events attended',
        'description_hindi': 'सांस्कृतिक कार्यक्रमों में भाग लिया',
        'progress': 0.4,
        'icon': 'celebration',
        'color': 'orange'
      },
      {
        'title': 'Relationship Health',
        'title_hindi': 'रिश्ते की सेहत',
        'value': '92% positive',
        'value_hindi': '92% सकारात्मक',
        'description': 'Healthy relationship interactions',
        'description_hindi': 'स्वस्थ रिश्ते की बातचीत',
        'progress': 0.92,
        'icon': 'people',
        'color': 'pink'
      },
      {
        'title': 'Stress Management',
        'title_hindi': 'तनाव प्रबंधन',
        'value': 'Low stress',
        'value_hindi': 'कम तनाव',
        'description': 'Effective stress coping',
        'description_hindi': 'प्रभावी तनाव का सामना',
        'progress': 0.8,
        'icon': 'spa',
        'color': 'cyan'
      }
    ];
  }
}
