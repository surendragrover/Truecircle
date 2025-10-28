import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DetailedEmotionalIntakeForm extends StatefulWidget {
  const DetailedEmotionalIntakeForm({super.key});

  @override
  State<DetailedEmotionalIntakeForm> createState() =>
      _DetailedEmotionalIntakeFormState();
}

class _DetailedEmotionalIntakeFormState
    extends State<DetailedEmotionalIntakeForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();

  // Family & Relationships Controllers
  final _familyMembersController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _supportSystemController = TextEditingController();

  // Daily Life Controllers
  final _dailyRoutineController = TextEditingController();
  final _stressTriggersController = TextEditingController();
  final _copingMechanismsController = TextEditingController();

  // Emotional State Controllers
  final _currentMoodController = TextEditingController();
  final _recentChangesController = TextEditingController();
  final _emotionalGoalsController = TextEditingController();

  // Sleep Pattern Controllers
  final _sleepTimeController = TextEditingController();
  final _wakeTimeController = TextEditingController();
  final _sleepQualityController = TextEditingController();

  // Health & Wellness Controllers
  final _physicalHealthController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _exerciseHabitsController = TextEditingController();

  String _selectedGender = 'Prefer not to say';
  String _selectedMaritalStatus = 'Single';
  String _selectedSleepQuality = 'Average';
  String _selectedStressLevel = 'Moderate';
  String _selectedMoodFrequency = 'Sometimes';

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];
  final List<String> _maritalOptions = [
    'Single',
    'In a relationship',
    'Married',
    'Divorced',
    'Widowed',
  ];
  final List<String> _sleepQualityOptions = [
    'Excellent',
    'Good',
    'Average',
    'Poor',
    'Very Poor',
  ];
  final List<String> _stressLevelOptions = [
    'Very Low',
    'Low',
    'Moderate',
    'High',
    'Very High',
  ];
  final List<String> _moodFrequencyOptions = [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Always',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final box = await Hive.openBox('emotional_intake');
      setState(() {
        _nameController.text = box.get('name', defaultValue: '');
        _ageController.text = box.get('age', defaultValue: '');
        _occupationController.text = box.get('occupation', defaultValue: '');
        _selectedGender = box.get('gender', defaultValue: 'Prefer not to say');
        _selectedMaritalStatus = box.get(
          'marital_status',
          defaultValue: 'Single',
        );

        _familyMembersController.text = box.get(
          'family_members',
          defaultValue: '',
        );
        _relationshipStatusController.text = box.get(
          'relationship_details',
          defaultValue: '',
        );
        _supportSystemController.text = box.get(
          'support_system',
          defaultValue: '',
        );

        _dailyRoutineController.text = box.get(
          'daily_routine',
          defaultValue: '',
        );
        _stressTriggersController.text = box.get(
          'stress_triggers',
          defaultValue: '',
        );
        _copingMechanismsController.text = box.get(
          'coping_mechanisms',
          defaultValue: '',
        );

        _currentMoodController.text = box.get('current_mood', defaultValue: '');
        _recentChangesController.text = box.get(
          'recent_changes',
          defaultValue: '',
        );
        _emotionalGoalsController.text = box.get(
          'emotional_goals',
          defaultValue: '',
        );

        _sleepTimeController.text = box.get('sleep_time', defaultValue: '');
        _wakeTimeController.text = box.get('wake_time', defaultValue: '');
        _selectedSleepQuality = box.get(
          'sleep_quality',
          defaultValue: 'Average',
        );

        _physicalHealthController.text = box.get(
          'physical_health',
          defaultValue: '',
        );
        _medicationsController.text = box.get('medications', defaultValue: '');
        _exerciseHabitsController.text = box.get(
          'exercise_habits',
          defaultValue: '',
        );

        _selectedStressLevel = box.get(
          'stress_level',
          defaultValue: 'Moderate',
        );
        _selectedMoodFrequency = box.get(
          'mood_frequency',
          defaultValue: 'Sometimes',
        );
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading existing data: $e');
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final box = await Hive.openBox('emotional_intake');
      await box.putAll({
        'name': _nameController.text,
        'age': _ageController.text,
        'occupation': _occupationController.text,
        'gender': _selectedGender,
        'marital_status': _selectedMaritalStatus,

        'family_members': _familyMembersController.text,
        'relationship_details': _relationshipStatusController.text,
        'support_system': _supportSystemController.text,

        'daily_routine': _dailyRoutineController.text,
        'stress_triggers': _stressTriggersController.text,
        'coping_mechanisms': _copingMechanismsController.text,

        'current_mood': _currentMoodController.text,
        'recent_changes': _recentChangesController.text,
        'emotional_goals': _emotionalGoalsController.text,

        'sleep_time': _sleepTimeController.text,
        'wake_time': _wakeTimeController.text,
        'sleep_quality': _selectedSleepQuality,

        'physical_health': _physicalHealthController.text,
        'medications': _medicationsController.text,
        'exercise_habits': _exerciseHabitsController.text,

        'stress_level': _selectedStressLevel,
        'mood_frequency': _selectedMoodFrequency,

        'intake_completed': true,
        'last_updated': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Your information has been saved securely'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _familyMembersController.dispose();
    _relationshipStatusController.dispose();
    _supportSystemController.dispose();
    _dailyRoutineController.dispose();
    _stressTriggersController.dispose();
    _copingMechanismsController.dispose();
    _currentMoodController.dispose();
    _recentChangesController.dispose();
    _emotionalGoalsController.dispose();
    _sleepTimeController.dispose();
    _wakeTimeController.dispose();
    _sleepQualityController.dispose();
    _physicalHealthController.dispose();
    _medicationsController.dispose();
    _exerciseHabitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Emotional Assessment'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 5) {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex < 5)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Next'),
                  ),
                if (details.stepIndex == 5)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final navigator = Navigator.of(context);
                        await _saveData();
                        if (mounted) {
                          navigator.pop(true);
                        }
                      }
                    },
                    child: const Text('Complete Assessment'),
                  ),
                const SizedBox(width: 8),
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Previous'),
                  ),
              ],
            );
          },
          steps: [
            // Step 1: Personal Information
            Step(
              title: const Text('Personal Information'),
              content: _buildPersonalInfoStep(),
              isActive: _currentStep == 0,
            ),

            // Step 2: Family & Relationships
            Step(
              title: const Text('Family & Relationships'),
              content: _buildFamilyStep(),
              isActive: _currentStep == 1,
            ),

            // Step 3: Daily Life & Triggers
            Step(
              title: const Text('Daily Life & Triggers'),
              content: _buildDailyLifeStep(),
              isActive: _currentStep == 2,
            ),

            // Step 4: Current Emotional State
            Step(
              title: const Text('Current Emotional State'),
              content: _buildEmotionalStateStep(),
              isActive: _currentStep == 3,
            ),

            // Step 5: Sleep & Physical Health
            Step(
              title: const Text('Sleep & Physical Health'),
              content: _buildHealthStep(),
              isActive: _currentStep == 4,
            ),

            // Step 6: Goals & Preferences
            Step(
              title: const Text('Goals & Assessment'),
              content: _buildGoalsStep(),
              isActive: _currentStep == 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Help Dr. Iris understand you better by sharing some basic information:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name (optional)',
            hintText: 'How would you like Dr. Iris to address you?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your age';
                  final age = int.tryParse(value!);
                  if (age == null || age < 13 || age > 120) {
                    return 'Please enter a valid age (13-120)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _occupationController,
          decoration: const InputDecoration(
            labelText: 'Occupation/Role',
            hintText: 'Student, Engineer, Parent, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedMaritalStatus,
          decoration: const InputDecoration(
            labelText: 'Relationship Status',
            border: OutlineInputBorder(),
          ),
          items: _maritalOptions.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (value) => setState(() => _selectedMaritalStatus = value!),
        ),
      ],
    );
  }

  Widget _buildFamilyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell Dr. Iris about your relationships and support system:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _familyMembersController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Family Members',
            hintText:
                'Who do you live with? Parents, siblings, spouse, children?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _relationshipStatusController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Relationship Details',
            hintText:
                'How are your relationships with family/friends? Any conflicts?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _supportSystemController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Support System',
            hintText:
                'Who can you talk to when you need help? Friends, family, professionals?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyLifeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Help Dr. Iris understand your daily life and what affects your mood:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _dailyRoutineController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Daily Routine',
            hintText: 'What does a typical day look like for you?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _stressTriggersController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Stress Triggers',
            hintText:
                'What situations, people, or activities make you feel stressed or anxious?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please share what triggers your stress';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _copingMechanismsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Current Coping Methods',
            hintText:
                'How do you currently handle stress or difficult emotions?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedStressLevel,
          decoration: const InputDecoration(
            labelText: 'Current Stress Level',
            border: OutlineInputBorder(),
          ),
          items: _stressLevelOptions.map((level) {
            return DropdownMenuItem(value: level, child: Text(level));
          }).toList(),
          onChanged: (value) => setState(() => _selectedStressLevel = value!),
        ),
      ],
    );
  }

  Widget _buildEmotionalStateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share your current emotional state with Dr. Iris:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _currentMoodController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Current Mood & Feelings',
            hintText:
                'How are you feeling right now? What emotions are you experiencing?',
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
          controller: _recentChangesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Recent Life Changes',
            hintText:
                'Any major changes in your life recently? Job, relationships, health?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedMoodFrequency,
          decoration: const InputDecoration(
            labelText: 'How often do you feel down or stressed?',
            border: OutlineInputBorder(),
          ),
          items: _moodFrequencyOptions.map((frequency) {
            return DropdownMenuItem(value: frequency, child: Text(frequency));
          }).toList(),
          onChanged: (value) => setState(() => _selectedMoodFrequency = value!),
        ),
      ],
    );
  }

  Widget _buildHealthStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your sleep and physical health affect your mental wellbeing:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sleepTimeController,
                decoration: const InputDecoration(
                  labelText: 'Sleep Time',
                  hintText: 'e.g., 11:00 PM',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _wakeTimeController,
                decoration: const InputDecoration(
                  labelText: 'Wake Time',
                  hintText: 'e.g., 7:00 AM',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedSleepQuality,
          decoration: const InputDecoration(
            labelText: 'Sleep Quality',
            border: OutlineInputBorder(),
          ),
          items: _sleepQualityOptions.map((quality) {
            return DropdownMenuItem(value: quality, child: Text(quality));
          }).toList(),
          onChanged: (value) => setState(() => _selectedSleepQuality = value!),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _physicalHealthController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Physical Health',
            hintText: 'Any health conditions that might affect your mood?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _medicationsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Medications (optional)',
            hintText: 'Any medications you\'re currently taking?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _exerciseHabitsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Exercise & Activities',
            hintText: 'What physical activities do you do? How often?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Finally, tell Dr. Iris what you hope to achieve:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _emotionalGoalsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Your Emotional Wellness Goals',
            hintText:
                'What would you like to improve? How can Dr. Iris help you?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please share your goals for emotional wellness';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Dr. Iris AI Assessment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Based on your responses, Dr. Iris will:\n'
                '• Provide personalized emotional guidance\n'
                '• Suggest relevant CBT techniques\n'
                '• Monitor your progress over time\n'
                '• Offer support during difficult moments\n'
                '• Help you build better coping strategies',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your information is stored securely on your device and never shared.',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
