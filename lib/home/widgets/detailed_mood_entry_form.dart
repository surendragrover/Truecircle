import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DetailedMoodEntryForm extends StatefulWidget {
  const DetailedMoodEntryForm({super.key});

  @override
  State<DetailedMoodEntryForm> createState() => _DetailedMoodEntryFormState();
}

class _DetailedMoodEntryFormState extends State<DetailedMoodEntryForm> {
  final _formKey = GlobalKey<FormState>();

  // Basic Mood Controllers
  final _moodDescriptionController = TextEditingController();
  final _emotionsController = TextEditingController();
  final _triggersController = TextEditingController();
  final _thoughtsController = TextEditingController();

  // Family & Relationships Controllers
  final _familyInteractionsController = TextEditingController();
  final _friendInteractionsController = TextEditingController();
  final _workInteractionsController = TextEditingController();
  final _conflictsController = TextEditingController();
  final _supportReceivedController = TextEditingController();

  // Social & Environment Controllers
  final _socialSituationsController = TextEditingController();
  final _environmentController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _physicalSymptomsController = TextEditingController();

  // Coping & Future Controllers
  final _copingStrategiesController = TextEditingController();
  final _helpfulThingsController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _tomorrowPlansController = TextEditingController();

  // Dropdown Values
  String _selectedOverallMood = 'Neutral';
  final String _selectedEnergyLevel = 'Medium';
  final String _selectedAnxietyLevel = 'Low';
  final String _selectedStressLevel = 'Low';
  String _selectedSocialMood = 'Neutral';
  String _selectedFamilyRelations = 'Good';
  String _selectedWorkStress = 'Low';
  String _selectedSleepQuality = 'Good';

  // Rating Scales (1-10)
  double _moodRating = 5.0;
  double _anxietyRating = 3.0;
  double _stressRating = 3.0;
  double _energyRating = 5.0;
  double _socialConfidenceRating = 5.0;
  double _selfEsteem = 5.0;

  final List<String> _moodOptions = [
    'Very Low',
    'Low',
    'Neutral',
    'Good',
    'Very Good',
    'Excellent',
  ];
  final List<String> _levelOptions = [
    'Very Low',
    'Low',
    'Medium',
    'High',
    'Very High',
  ];
  final List<String> _relationOptions = [
    'Very Poor',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];
  final List<String> _qualityOptions = [
    'Very Poor',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _moodDescriptionController.dispose();
    _emotionsController.dispose();
    _triggersController.dispose();
    _thoughtsController.dispose();
    _familyInteractionsController.dispose();
    _friendInteractionsController.dispose();
    _workInteractionsController.dispose();
    _conflictsController.dispose();
    _supportReceivedController.dispose();
    _socialSituationsController.dispose();
    _environmentController.dispose();
    _activitiesController.dispose();
    _physicalSymptomsController.dispose();
    _copingStrategiesController.dispose();
    _helpfulThingsController.dispose();
    _gratitudeController.dispose();
    _tomorrowPlansController.dispose();
    super.dispose();
  }

  Future<void> _saveMoodEntry() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final box = await Hive.openBox('mood_entries');
      final entryId = DateTime.now().millisecondsSinceEpoch.toString();

      await box.put(entryId, {
        'id': entryId,
        'date': DateTime.now().toIso8601String(),

        // Basic Mood Data
        'overall_mood': _selectedOverallMood,
        'mood_rating': _moodRating,
        'mood_description': _moodDescriptionController.text,
        'emotions': _emotionsController.text,
        'triggers': _triggersController.text,
        'thoughts': _thoughtsController.text,

        // Mental State Ratings
        'anxiety_level': _selectedAnxietyLevel,
        'anxiety_rating': _anxietyRating,
        'stress_level': _selectedStressLevel,
        'stress_rating': _stressRating,
        'energy_level': _selectedEnergyLevel,
        'energy_rating': _energyRating,
        'social_confidence_rating': _socialConfidenceRating,
        'self_esteem_rating': _selfEsteem,

        // Family & Relationships
        'family_relations': _selectedFamilyRelations,
        'family_interactions': _familyInteractionsController.text,
        'friend_interactions': _friendInteractionsController.text,
        'work_interactions': _workInteractionsController.text,
        'conflicts': _conflictsController.text,
        'support_received': _supportReceivedController.text,
        'social_mood': _selectedSocialMood,

        // Environment & Activities
        'social_situations': _socialSituationsController.text,
        'environment': _environmentController.text,
        'activities': _activitiesController.text,
        'physical_symptoms': _physicalSymptomsController.text,

        // Work & External Stress
        'work_stress': _selectedWorkStress,
        'sleep_quality': _selectedSleepQuality,

        // Coping & Growth
        'coping_strategies': _copingStrategiesController.text,
        'helpful_things': _helpfulThingsController.text,
        'gratitude': _gratitudeController.text,
        'tomorrow_plans': _tomorrowPlansController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mood entry saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving mood entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Mood Journal'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Current Mood & Feelings', Icons.mood),
              _buildMoodSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Mental State Ratings', Icons.psychology),
              _buildMentalStateSection(),

              const SizedBox(height: 24),
              _buildSectionHeader(
                'Family & Close Relationships',
                Icons.family_restroom,
              ),
              _buildFamilySection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Friends & Social Life', Icons.group),
              _buildSocialSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Work & External Environment', Icons.work),
              _buildWorkSection(),

              const SizedBox(height: 24),
              _buildSectionHeader(
                'Physical & Environmental Factors',
                Icons.spa,
              ),
              _buildPhysicalSection(),

              const SizedBox(height: 24),
              _buildSectionHeader(
                'Coping & Positive Actions',
                Icons.self_improvement,
              ),
              _buildCopingSection(),

              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedOverallMood,
              decoration: const InputDecoration(
                labelText: 'Overall Mood',
                border: OutlineInputBorder(),
              ),
              items: _moodOptions.map((mood) {
                return DropdownMenuItem(value: mood, child: Text(mood));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedOverallMood = value!),
            ),
            const SizedBox(height: 16),

            _buildRatingSlider('Mood Rating (1-10)', _moodRating, (value) {
              setState(() => _moodRating = value);
            }),
            const SizedBox(height: 16),

            TextFormField(
              controller: _moodDescriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'How are you feeling right now?',
                hintText: 'Describe your current emotional state in detail...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please describe your current mood';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emotionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Specific Emotions',
                hintText: 'Happy, sad, anxious, excited, frustrated, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _triggersController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What triggered these feelings?',
                hintText:
                    'Specific events, conversations, thoughts, or situations...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _thoughtsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Current Thoughts',
                hintText: 'What thoughts are going through your mind?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentalStateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRatingSlider('Anxiety Level (1-10)', _anxietyRating, (value) {
              setState(() => _anxietyRating = value);
            }),
            const SizedBox(height: 16),

            _buildRatingSlider('Stress Level (1-10)', _stressRating, (value) {
              setState(() => _stressRating = value);
            }),
            const SizedBox(height: 16),

            _buildRatingSlider('Energy Level (1-10)', _energyRating, (value) {
              setState(() => _energyRating = value);
            }),
            const SizedBox(height: 16),

            _buildRatingSlider(
              'Social Confidence (1-10)',
              _socialConfidenceRating,
              (value) {
                setState(() => _socialConfidenceRating = value);
              },
            ),
            const SizedBox(height: 16),

            _buildRatingSlider('Self-Esteem (1-10)', _selfEsteem, (value) {
              setState(() => _selfEsteem = value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedFamilyRelations,
              decoration: const InputDecoration(
                labelText: 'Family Relations Today',
                border: OutlineInputBorder(),
              ),
              items: _relationOptions.map((relation) {
                return DropdownMenuItem(value: relation, child: Text(relation));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedFamilyRelations = value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _familyInteractionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Family Interactions Today',
                hintText:
                    'How did you interact with family members? Any conversations, conflicts, or positive moments?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _conflictsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Any Conflicts or Tensions?',
                hintText:
                    'Arguments, disagreements, or uncomfortable situations with family?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _supportReceivedController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Support Received',
                hintText:
                    'Did anyone offer help, comfort, or encouragement today?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _friendInteractionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Friend Interactions',
                hintText:
                    'How were your interactions with friends today? Messages, calls, meetings?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _socialSituationsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Social Situations',
                hintText:
                    'Any social events, gatherings, or awkward social moments?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedSocialMood,
              decoration: const InputDecoration(
                labelText: 'Social Mood',
                border: OutlineInputBorder(),
              ),
              items: _moodOptions.map((mood) {
                return DropdownMenuItem(value: mood, child: Text(mood));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedSocialMood = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedWorkStress,
              decoration: const InputDecoration(
                labelText: 'Work/Study Stress Level',
                border: OutlineInputBorder(),
              ),
              items: _levelOptions.map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedWorkStress = value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _workInteractionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Work/School Interactions',
                hintText:
                    'How were your interactions with colleagues, classmates, teachers, or boss?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _environmentController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Environment Impact',
                hintText:
                    'How did your surroundings affect your mood? (home, work, weather, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedSleepQuality,
              decoration: const InputDecoration(
                labelText: 'Sleep Quality Last Night',
                border: OutlineInputBorder(),
              ),
              items: _qualityOptions.map((quality) {
                return DropdownMenuItem(value: quality, child: Text(quality));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedSleepQuality = value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _activitiesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Activities Today',
                hintText:
                    'Exercise, hobbies, work, socializing, relaxing, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _physicalSymptomsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Physical Symptoms',
                hintText: 'Headaches, fatigue, tension, stomach issues, etc.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _copingStrategiesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Coping Strategies Used',
                hintText:
                    'What did you do to manage difficult emotions? Deep breathing, talking to someone, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _helpfulThingsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'What Helped Today?',
                hintText:
                    'Activities, people, or thoughts that improved your mood',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _gratitudeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Gratitude & Positives',
                hintText:
                    'What are you grateful for today? Any positive moments?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tomorrowPlansController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Plans for Tomorrow',
                hintText:
                    'How can you improve your mood tomorrow? Any specific goals?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.round()}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Slider(
          value: value,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveMoodEntry,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save Mood Entry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
