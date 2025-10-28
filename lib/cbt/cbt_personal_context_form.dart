import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/truecircle_app_bar.dart';

class CBTPersonalContextForm extends StatefulWidget {
  const CBTPersonalContextForm({super.key});

  @override
  State<CBTPersonalContextForm> createState() => _CBTPersonalContextFormState();
}

class _CBTPersonalContextFormState extends State<CBTPersonalContextForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Thought Patterns Controllers
  final _negativeThoughtsController = TextEditingController();
  final _commonWorriesController = TextEditingController();
  final _selfTalkController = TextEditingController();
  final _catastrophicThinkingController = TextEditingController();

  // Triggers & Situations Controllers
  final _anxietyTriggersController = TextEditingController();
  final _stressfulSituationsController = TextEditingController();
  final _avoidanceBehaviorsController = TextEditingController();
  final _difficultRelationshipsController = TextEditingController();

  // Family Background Controllers
  final _familyMentalHealthController = TextEditingController();
  final _childhoodExperiencesController = TextEditingController();
  final _familyDynamicsController = TextEditingController();
  final _supportSystemController = TextEditingController();

  // Social Situations Controllers
  final _socialAnxietyController = TextEditingController();
  final _workStressController = TextEditingController();
  final _conflictHandlingController = TextEditingController();
  final _communicationIssuesController = TextEditingController();

  // Coping & Goals Controllers
  final _currentCopingController = TextEditingController();
  final _pastTherapyController = TextEditingController();
  final _cbtGoalsController = TextEditingController();
  final _changeMotivationController = TextEditingController();

  // Dropdown Values
  String _selectedDepressionLevel = 'Mild';
  String _selectedAnxietyLevel = 'Mild';
  String _selectedStressLevel = 'Moderate';
  String _selectedSelfEsteem = 'Moderate';
  String _selectedSocialConfidence = 'Moderate';
  String _selectedTherapyExperience = 'No previous therapy';
  String _selectedMotivationLevel = 'High';

  final List<String> _severityLevels = [
    'None',
    'Mild',
    'Moderate',
    'Severe',
    'Very Severe',
  ];
  final List<String> _confidenceLevels = [
    'Very Low',
    'Low',
    'Moderate',
    'High',
    'Very High',
  ];
  final List<String> _therapyLevels = [
    'No previous therapy',
    'Some counseling',
    'Previous CBT',
    'Long-term therapy',
    'Multiple therapies',
  ];
  final List<String> _motivationLevels = [
    'Very Low',
    'Low',
    'Moderate',
    'High',
    'Very High',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final box = await Hive.openBox('cbt_context');
      setState(() {
        // Thought Patterns
        _negativeThoughtsController.text = box.get(
          'negative_thoughts',
          defaultValue: '',
        );
        _commonWorriesController.text = box.get(
          'common_worries',
          defaultValue: '',
        );
        _selfTalkController.text = box.get('self_talk', defaultValue: '');
        _catastrophicThinkingController.text = box.get(
          'catastrophic_thinking',
          defaultValue: '',
        );

        // Triggers & Situations
        _anxietyTriggersController.text = box.get(
          'anxiety_triggers',
          defaultValue: '',
        );
        _stressfulSituationsController.text = box.get(
          'stressful_situations',
          defaultValue: '',
        );
        _avoidanceBehaviorsController.text = box.get(
          'avoidance_behaviors',
          defaultValue: '',
        );
        _difficultRelationshipsController.text = box.get(
          'difficult_relationships',
          defaultValue: '',
        );

        // Family Background
        _familyMentalHealthController.text = box.get(
          'family_mental_health',
          defaultValue: '',
        );
        _childhoodExperiencesController.text = box.get(
          'childhood_experiences',
          defaultValue: '',
        );
        _familyDynamicsController.text = box.get(
          'family_dynamics',
          defaultValue: '',
        );
        _supportSystemController.text = box.get(
          'support_system',
          defaultValue: '',
        );

        // Social Situations
        _socialAnxietyController.text = box.get(
          'social_anxiety',
          defaultValue: '',
        );
        _workStressController.text = box.get('work_stress', defaultValue: '');
        _conflictHandlingController.text = box.get(
          'conflict_handling',
          defaultValue: '',
        );
        _communicationIssuesController.text = box.get(
          'communication_issues',
          defaultValue: '',
        );

        // Coping & Goals
        _currentCopingController.text = box.get(
          'current_coping',
          defaultValue: '',
        );
        _pastTherapyController.text = box.get('past_therapy', defaultValue: '');
        _cbtGoalsController.text = box.get('cbt_goals', defaultValue: '');
        _changeMotivationController.text = box.get(
          'change_motivation',
          defaultValue: '',
        );

        // Dropdown Values
        _selectedDepressionLevel = box.get(
          'depression_level',
          defaultValue: 'Mild',
        );
        _selectedAnxietyLevel = box.get('anxiety_level', defaultValue: 'Mild');
        _selectedStressLevel = box.get(
          'stress_level',
          defaultValue: 'Moderate',
        );
        _selectedSelfEsteem = box.get('self_esteem', defaultValue: 'Moderate');
        _selectedSocialConfidence = box.get(
          'social_confidence',
          defaultValue: 'Moderate',
        );
        _selectedTherapyExperience = box.get(
          'therapy_experience',
          defaultValue: 'No previous therapy',
        );
        _selectedMotivationLevel = box.get(
          'motivation_level',
          defaultValue: 'High',
        );
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading CBT context data: $e');
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final box = await Hive.openBox('cbt_context');
      await box.putAll({
        // Thought Patterns
        'negative_thoughts': _negativeThoughtsController.text,
        'common_worries': _commonWorriesController.text,
        'self_talk': _selfTalkController.text,
        'catastrophic_thinking': _catastrophicThinkingController.text,

        // Triggers & Situations
        'anxiety_triggers': _anxietyTriggersController.text,
        'stressful_situations': _stressfulSituationsController.text,
        'avoidance_behaviors': _avoidanceBehaviorsController.text,
        'difficult_relationships': _difficultRelationshipsController.text,

        // Family Background
        'family_mental_health': _familyMentalHealthController.text,
        'childhood_experiences': _childhoodExperiencesController.text,
        'family_dynamics': _familyDynamicsController.text,
        'support_system': _supportSystemController.text,

        // Social Situations
        'social_anxiety': _socialAnxietyController.text,
        'work_stress': _workStressController.text,
        'conflict_handling': _conflictHandlingController.text,
        'communication_issues': _communicationIssuesController.text,

        // Coping & Goals
        'current_coping': _currentCopingController.text,
        'past_therapy': _pastTherapyController.text,
        'cbt_goals': _cbtGoalsController.text,
        'change_motivation': _changeMotivationController.text,

        // Dropdown Values
        'depression_level': _selectedDepressionLevel,
        'anxiety_level': _selectedAnxietyLevel,
        'stress_level': _selectedStressLevel,
        'self_esteem': _selectedSelfEsteem,
        'social_confidence': _selectedSocialConfidence,
        'therapy_experience': _selectedTherapyExperience,
        'motivation_level': _selectedMotivationLevel,

        'context_completed': true,
        'last_updated': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ CBT context saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving CBT context: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _negativeThoughtsController.dispose();
    _commonWorriesController.dispose();
    _selfTalkController.dispose();
    _catastrophicThinkingController.dispose();
    _anxietyTriggersController.dispose();
    _stressfulSituationsController.dispose();
    _avoidanceBehaviorsController.dispose();
    _difficultRelationshipsController.dispose();
    _familyMentalHealthController.dispose();
    _childhoodExperiencesController.dispose();
    _familyDynamicsController.dispose();
    _supportSystemController.dispose();
    _socialAnxietyController.dispose();
    _workStressController.dispose();
    _conflictHandlingController.dispose();
    _communicationIssuesController.dispose();
    _currentCopingController.dispose();
    _pastTherapyController.dispose();
    _cbtGoalsController.dispose();
    _changeMotivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'CBT Personal Context'),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 4) {
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
                if (details.stepIndex < 4)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Next'),
                  ),
                if (details.stepIndex == 4)
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
                    child: const Text('Complete Setup'),
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
            // Step 1: Thought Patterns
            Step(
              title: const Text('Thought Patterns'),
              content: _buildThoughtPatternsStep(),
              isActive: _currentStep == 0,
            ),

            // Step 2: Triggers & Situations
            Step(
              title: const Text('Triggers & Situations'),
              content: _buildTriggersStep(),
              isActive: _currentStep == 1,
            ),

            // Step 3: Family & Background
            Step(
              title: const Text('Family & Background'),
              content: _buildFamilyStep(),
              isActive: _currentStep == 2,
            ),

            // Step 4: Social Context
            Step(
              title: const Text('Social Context'),
              content: _buildSocialStep(),
              isActive: _currentStep == 3,
            ),

            // Step 5: Goals & Experience
            Step(
              title: const Text('Goals & Experience'),
              content: _buildGoalsStep(),
              isActive: _currentStep == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThoughtPatternsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Help us understand your thinking patterns for personalized CBT guidance:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDepressionLevel,
                decoration: const InputDecoration(
                  labelText: 'Depression Level',
                  border: OutlineInputBorder(),
                ),
                items: _severityLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDepressionLevel = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedAnxietyLevel,
                decoration: const InputDecoration(
                  labelText: 'Anxiety Level',
                  border: OutlineInputBorder(),
                ),
                items: _severityLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedAnxietyLevel = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _negativeThoughtsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Common Negative Thoughts',
            hintText: 'What negative thoughts frequently go through your mind?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please share your common negative thoughts';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _commonWorriesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'What Do You Worry About Most?',
            hintText: 'Family, work, health, future, relationships, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _selfTalkController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'How Do You Talk to Yourself?',
            hintText: 'Are you usually kind or critical to yourself?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _catastrophicThinkingController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Do You Jump to Worst-Case Scenarios?',
            hintText: 'Examples of when you assume the worst will happen',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTriggersStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identify what triggers your difficult emotions and behaviors:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _anxietyTriggersController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Anxiety Triggers',
            hintText:
                'Specific situations, people, or thoughts that make you anxious',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please identify your anxiety triggers';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _stressfulSituationsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Most Stressful Situations',
            hintText: 'Work deadlines, family conflicts, social events, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _avoidanceBehaviorsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'What Do You Avoid?',
            hintText:
                'Situations, people, or activities you avoid due to anxiety or fear',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _difficultRelationshipsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Difficult Relationships',
            hintText: 'People or relationship dynamics that cause you stress',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Family background helps us understand your context better:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _familyMentalHealthController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Family Mental Health History',
            hintText:
                'Any depression, anxiety, or other mental health issues in family?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _childhoodExperiencesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Relevant Childhood Experiences',
            hintText:
                'Major events, traumas, or patterns from childhood that still affect you',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _familyDynamicsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Current Family Dynamics',
            hintText:
                'How does your family interact? Any ongoing conflicts or stress?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _supportSystemController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Your Support System',
            hintText: 'Who can you rely on for emotional support?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your social situations and work environment impact your mental health:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSocialConfidence,
                decoration: const InputDecoration(
                  labelText: 'Social Confidence',
                  border: OutlineInputBorder(),
                ),
                items: _confidenceLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSocialConfidence = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSelfEsteem,
                decoration: const InputDecoration(
                  labelText: 'Self-Esteem',
                  border: OutlineInputBorder(),
                ),
                items: _confidenceLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSelfEsteem = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _socialAnxietyController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Social Anxiety Situations',
            hintText:
                'Speaking in groups, meeting new people, parties, presentations, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _workStressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Work/School Stress',
            hintText:
                'What aspects of work or school cause you the most stress?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _conflictHandlingController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'How Do You Handle Conflicts?',
            hintText: 'Avoid them, get angry, try to please everyone, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _communicationIssuesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Communication Challenges',
            hintText:
                'Difficulty expressing feelings, setting boundaries, etc.',
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
          'Finally, tell us about your goals and experience with therapy:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedTherapyExperience,
                decoration: const InputDecoration(
                  labelText: 'Therapy Experience',
                  border: OutlineInputBorder(),
                ),
                items: _therapyLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedTherapyExperience = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedMotivationLevel,
                decoration: const InputDecoration(
                  labelText: 'Motivation Level',
                  border: OutlineInputBorder(),
                ),
                items: _motivationLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedMotivationLevel = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _currentCopingController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Current Coping Strategies',
            hintText:
                'What do you currently do to manage stress and difficult emotions?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _pastTherapyController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Past Therapy Experience',
            hintText:
                'What worked? What didn\'t? Any specific techniques you liked?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _cbtGoalsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Your CBT Goals',
            hintText:
                'What do you hope to achieve through CBT? What changes do you want to see?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please share your CBT goals';
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _changeMotivationController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'What Motivates You to Change?',
            hintText: 'Family, career, personal happiness, health, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.teal.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Personalized CBT Approach',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Based on your responses, Dr. Iris will:\n'
                '• Provide CBT techniques tailored to your specific triggers\n'
                '• Consider your family and social context in guidance\n'
                '• Adapt exercises to your experience level\n'
                '• Focus on your personal goals and motivations\n'
                '• Build on your existing coping strategies',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
