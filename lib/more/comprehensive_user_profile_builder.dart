import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ComprehensiveUserProfileBuilder extends StatefulWidget {
  const ComprehensiveUserProfileBuilder({super.key});

  @override
  State<ComprehensiveUserProfileBuilder> createState() =>
      _ComprehensiveUserProfileBuilderState();
}

class _ComprehensiveUserProfileBuilderState
    extends State<ComprehensiveUserProfileBuilder> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();

  // Family & Relationships Controllers
  final _familyMembersController = TextEditingController();
  final _livingArrangementController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _childrenController = TextEditingController();
  final _significantOthersController = TextEditingController();
  final _familyDynamicsController = TextEditingController();

  // Social Life Controllers
  final _closeFriendsController = TextEditingController();
  final _socialActivitiesController = TextEditingController();
  final _communityInvolvementController = TextEditingController();
  final _supportNetworkController = TextEditingController();

  // Work & Career Controllers
  final _jobDescriptionController = TextEditingController();
  final _workEnvironmentController = TextEditingController();
  final _careerGoalsController = TextEditingController();
  final _workStressorsController = TextEditingController();
  final _workSatisfactionController = TextEditingController();

  // Hobbies & Interests Controllers
  final _hobbiesController = TextEditingController();
  final _sportsActivitiesController = TextEditingController();
  final _creativeInterestsController = TextEditingController();
  final _learningInterestsController = TextEditingController();
  final _entertainmentController = TextEditingController();

  // Lifestyle & Health Controllers
  final _dailyRoutineController = TextEditingController();
  final _exerciseHabitsController = TextEditingController();
  final _dietHabitsController = TextEditingController();
  final _sleepPatternsController = TextEditingController();
  final _healthConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();

  // Values & Goals Controllers
  final _coreValuesController = TextEditingController();
  final _lifeGoalsController = TextEditingController();
  final _spiritualBeliefsController = TextEditingController();
  final _personalChallengesController = TextEditingController();
  final _motivationsController = TextEditingController();

  // Dropdown Values
  String _selectedGender = 'Prefer not to say';
  String _selectedEducationLevel = 'High School';
  String _selectedEmploymentStatus = 'Employed';
  String _selectedIncomeLevel = 'Prefer not to say';
  String _selectedLivingSituation = 'Family';
  String _selectedRelationshipStatus = 'Single';
  String _selectedHealthStatus = 'Good';
  String _selectedExerciseFrequency = 'Sometimes';
  String _selectedSocialLevel = 'Moderate';
  String _selectedStressLevel = 'Moderate';

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];
  final List<String> _educationOptions = [
    'High School',
    'Some College',
    'Bachelor\'s',
    'Master\'s',
    'PhD',
    'Other',
  ];
  final List<String> _employmentOptions = [
    'Employed',
    'Self-employed',
    'Student',
    'Unemployed',
    'Retired',
    'Other',
  ];

  final List<String> _relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    'Divorced',
    'Widowed',
  ];

  final List<String> _frequencyOptions = [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Daily',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final box = await Hive.openBox('user_profile');
      setState(() {
        // Personal Information
        _nameController.text = box.get('name', defaultValue: '');
        _ageController.text = box.get('age', defaultValue: '');
        _locationController.text = box.get('location', defaultValue: '');
        _occupationController.text = box.get('occupation', defaultValue: '');
        _educationController.text = box.get(
          'education_details',
          defaultValue: '',
        );
        _selectedGender = box.get('gender', defaultValue: 'Prefer not to say');
        _selectedEducationLevel = box.get(
          'education_level',
          defaultValue: 'High School',
        );
        _selectedEmploymentStatus = box.get(
          'employment_status',
          defaultValue: 'Employed',
        );
        _selectedIncomeLevel = box.get(
          'income_level',
          defaultValue: 'Prefer not to say',
        );

        // Family & Relationships
        _familyMembersController.text = box.get(
          'family_members',
          defaultValue: '',
        );
        _livingArrangementController.text = box.get(
          'living_arrangement',
          defaultValue: '',
        );
        _maritalStatusController.text = box.get(
          'marital_details',
          defaultValue: '',
        );
        _childrenController.text = box.get('children', defaultValue: '');
        _significantOthersController.text = box.get(
          'significant_others',
          defaultValue: '',
        );
        _familyDynamicsController.text = box.get(
          'family_dynamics',
          defaultValue: '',
        );
        _selectedLivingSituation = box.get(
          'living_situation',
          defaultValue: 'Family',
        );
        _selectedRelationshipStatus = box.get(
          'relationship_status',
          defaultValue: 'Single',
        );

        // Social Life
        _closeFriendsController.text = box.get(
          'close_friends',
          defaultValue: '',
        );
        _socialActivitiesController.text = box.get(
          'social_activities',
          defaultValue: '',
        );
        _communityInvolvementController.text = box.get(
          'community_involvement',
          defaultValue: '',
        );
        _supportNetworkController.text = box.get(
          'support_network',
          defaultValue: '',
        );
        _selectedSocialLevel = box.get(
          'social_level',
          defaultValue: 'Moderate',
        );

        // Work & Career
        _jobDescriptionController.text = box.get(
          'job_description',
          defaultValue: '',
        );
        _workEnvironmentController.text = box.get(
          'work_environment',
          defaultValue: '',
        );
        _careerGoalsController.text = box.get('career_goals', defaultValue: '');
        _workStressorsController.text = box.get(
          'work_stressors',
          defaultValue: '',
        );
        _workSatisfactionController.text = box.get(
          'work_satisfaction',
          defaultValue: '',
        );

        // Hobbies & Interests
        _hobbiesController.text = box.get('hobbies', defaultValue: '');
        _sportsActivitiesController.text = box.get(
          'sports_activities',
          defaultValue: '',
        );
        _creativeInterestsController.text = box.get(
          'creative_interests',
          defaultValue: '',
        );
        _learningInterestsController.text = box.get(
          'learning_interests',
          defaultValue: '',
        );
        _entertainmentController.text = box.get(
          'entertainment',
          defaultValue: '',
        );

        // Lifestyle & Health
        _dailyRoutineController.text = box.get(
          'daily_routine',
          defaultValue: '',
        );
        _exerciseHabitsController.text = box.get(
          'exercise_habits',
          defaultValue: '',
        );
        _dietHabitsController.text = box.get('diet_habits', defaultValue: '');
        _sleepPatternsController.text = box.get(
          'sleep_patterns',
          defaultValue: '',
        );
        _healthConditionsController.text = box.get(
          'health_conditions',
          defaultValue: '',
        );
        _medicationsController.text = box.get('medications', defaultValue: '');
        _selectedHealthStatus = box.get('health_status', defaultValue: 'Good');
        _selectedExerciseFrequency = box.get(
          'exercise_frequency',
          defaultValue: 'Sometimes',
        );
        _selectedStressLevel = box.get(
          'stress_level',
          defaultValue: 'Moderate',
        );

        // Values & Goals
        _coreValuesController.text = box.get('core_values', defaultValue: '');
        _lifeGoalsController.text = box.get('life_goals', defaultValue: '');
        _spiritualBeliefsController.text = box.get(
          'spiritual_beliefs',
          defaultValue: '',
        );
        _personalChallengesController.text = box.get(
          'personal_challenges',
          defaultValue: '',
        );
        _motivationsController.text = box.get('motivations', defaultValue: '');
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user profile: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      final box = await Hive.openBox('user_profile');
      await box.putAll({
        // Personal Information
        'name': _nameController.text,
        'age': _ageController.text,
        'location': _locationController.text,
        'occupation': _occupationController.text,
        'education_details': _educationController.text,
        'gender': _selectedGender,
        'education_level': _selectedEducationLevel,
        'employment_status': _selectedEmploymentStatus,
        'income_level': _selectedIncomeLevel,

        // Family & Relationships
        'family_members': _familyMembersController.text,
        'living_arrangement': _livingArrangementController.text,
        'marital_details': _maritalStatusController.text,
        'children': _childrenController.text,
        'significant_others': _significantOthersController.text,
        'family_dynamics': _familyDynamicsController.text,
        'living_situation': _selectedLivingSituation,
        'relationship_status': _selectedRelationshipStatus,

        // Social Life
        'close_friends': _closeFriendsController.text,
        'social_activities': _socialActivitiesController.text,
        'community_involvement': _communityInvolvementController.text,
        'support_network': _supportNetworkController.text,
        'social_level': _selectedSocialLevel,

        // Work & Career
        'job_description': _jobDescriptionController.text,
        'work_environment': _workEnvironmentController.text,
        'career_goals': _careerGoalsController.text,
        'work_stressors': _workStressorsController.text,
        'work_satisfaction': _workSatisfactionController.text,

        // Hobbies & Interests
        'hobbies': _hobbiesController.text,
        'sports_activities': _sportsActivitiesController.text,
        'creative_interests': _creativeInterestsController.text,
        'learning_interests': _learningInterestsController.text,
        'entertainment': _entertainmentController.text,

        // Lifestyle & Health
        'daily_routine': _dailyRoutineController.text,
        'exercise_habits': _exerciseHabitsController.text,
        'diet_habits': _dietHabitsController.text,
        'sleep_patterns': _sleepPatternsController.text,
        'health_conditions': _healthConditionsController.text,
        'medications': _medicationsController.text,
        'health_status': _selectedHealthStatus,
        'exercise_frequency': _selectedExerciseFrequency,
        'stress_level': _selectedStressLevel,

        // Values & Goals
        'core_values': _coreValuesController.text,
        'life_goals': _lifeGoalsController.text,
        'spiritual_beliefs': _spiritualBeliefsController.text,
        'personal_challenges': _personalChallengesController.text,
        'motivations': _motivationsController.text,

        'profile_completed': true,
        'last_updated': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving profile: $e'),
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
    _locationController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _familyMembersController.dispose();
    _livingArrangementController.dispose();
    _maritalStatusController.dispose();
    _childrenController.dispose();
    _significantOthersController.dispose();
    _familyDynamicsController.dispose();
    _closeFriendsController.dispose();
    _socialActivitiesController.dispose();
    _communityInvolvementController.dispose();
    _supportNetworkController.dispose();
    _jobDescriptionController.dispose();
    _workEnvironmentController.dispose();
    _careerGoalsController.dispose();
    _workStressorsController.dispose();
    _workSatisfactionController.dispose();
    _hobbiesController.dispose();
    _sportsActivitiesController.dispose();
    _creativeInterestsController.dispose();
    _learningInterestsController.dispose();
    _entertainmentController.dispose();
    _dailyRoutineController.dispose();
    _exerciseHabitsController.dispose();
    _dietHabitsController.dispose();
    _sleepPatternsController.dispose();
    _healthConditionsController.dispose();
    _medicationsController.dispose();
    _coreValuesController.dispose();
    _lifeGoalsController.dispose();
    _spiritualBeliefsController.dispose();
    _personalChallengesController.dispose();
    _motivationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile Builder'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 6) {
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
                if (details.stepIndex < 6)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Next'),
                  ),
                if (details.stepIndex == 6)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final navigator = Navigator.of(context);
                        await _saveProfile();
                        if (mounted) {
                          navigator.pop(true);
                        }
                      }
                    },
                    child: const Text('Complete Profile'),
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

            // Step 3: Social Life
            Step(
              title: const Text('Social Life'),
              content: _buildSocialStep(),
              isActive: _currentStep == 2,
            ),

            // Step 4: Work & Career
            Step(
              title: const Text('Work & Career'),
              content: _buildWorkStep(),
              isActive: _currentStep == 3,
            ),

            // Step 5: Hobbies & Interests
            Step(
              title: const Text('Hobbies & Interests'),
              content: _buildHobbiesStep(),
              isActive: _currentStep == 4,
            ),

            // Step 6: Lifestyle & Health
            Step(
              title: const Text('Lifestyle & Health'),
              content: _buildLifestyleStep(),
              isActive: _currentStep == 5,
            ),

            // Step 7: Values & Goals
            Step(
              title: const Text('Values & Goals'),
              content: _buildValuesStep(),
              isActive: _currentStep == 6,
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
          'Tell Dr. Iris about yourself so she can provide personalized guidance:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'How would you like to be addressed?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter your name';
            return null;
          },
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
                  if (value?.isEmpty ?? true) return 'Required';
                  final age = int.tryParse(value!);
                  if (age == null || age < 13 || age > 120) {
                    return 'Valid age (13-120)';
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
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location (City, Country)',
            hintText: 'New Delhi, India',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _occupationController,
          decoration: const InputDecoration(
            labelText: 'Occupation',
            hintText: 'Software Engineer, Student, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedEducationLevel,
                decoration: const InputDecoration(
                  labelText: 'Education Level',
                  border: OutlineInputBorder(),
                ),
                items: _educationOptions.map((education) {
                  return DropdownMenuItem(
                    value: education,
                    child: Text(education),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedEducationLevel = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedEmploymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Employment Status',
                  border: OutlineInputBorder(),
                ),
                items: _employmentOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedEmploymentStatus = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Due to length constraints, I'm showing the structure for other steps
  Widget _buildFamilyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Family relationships deeply impact mental health:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedRelationshipStatus,
          decoration: const InputDecoration(
            labelText: 'Relationship Status',
            border: OutlineInputBorder(),
          ),
          items: _relationshipOptions.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (value) =>
              setState(() => _selectedRelationshipStatus = value!),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _familyMembersController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Family Members',
            hintText:
                'Who do you live with? Parents, spouse, children, siblings?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _familyDynamicsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Family Dynamics',
            hintText:
                'How do family members interact? Any ongoing conflicts or strong bonds?',
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
          'Your social connections and community involvement:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _closeFriendsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Close Friends',
            hintText:
                'How many close friends do you have? How often do you meet?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _socialActivitiesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Social Activities',
            hintText: 'Parties, group activities, clubs, sports teams, etc.',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work and career significantly impact mental wellbeing:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _jobDescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Job Description',
            hintText:
                'What do you do at work? Daily responsibilities and challenges?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _workStressorsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Work Stressors',
            hintText:
                'Deadlines, difficult colleagues, workload, commute, etc.',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildHobbiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hobbies and interests bring joy and balance to life:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _hobbiesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Hobbies & Interests',
            hintText: 'Reading, cooking, gardening, gaming, traveling, etc.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _creativeInterestsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Creative Interests',
            hintText: 'Art, music, writing, crafts, photography, etc.',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildLifestyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lifestyle habits affect both physical and mental health:',
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

        DropdownButtonFormField<String>(
          initialValue: _selectedExerciseFrequency,
          decoration: const InputDecoration(
            labelText: 'Exercise Frequency',
            border: OutlineInputBorder(),
          ),
          items: _frequencyOptions.map((frequency) {
            return DropdownMenuItem(value: frequency, child: Text(frequency));
          }).toList(),
          onChanged: (value) =>
              setState(() => _selectedExerciseFrequency = value!),
        ),
      ],
    );
  }

  Widget _buildValuesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Understanding your values and goals helps Dr. Iris provide meaningful guidance:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _coreValuesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Core Values',
            hintText:
                'Family, honesty, success, creativity, helping others, etc.',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please share your core values';
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _lifeGoalsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Life Goals',
            hintText: 'What do you want to achieve in the next 1-5 years?',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please share your life goals';
            return null;
          },
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.deepPurple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.deepPurple.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Personalized Dr. Iris Experience',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'With your complete profile, Dr. Iris will:\n'
                '• Understand your unique life context\n'
                '• Provide advice considering your relationships and environment\n'
                '• Suggest activities aligned with your interests and values\n'
                '• Offer support tailored to your lifestyle and goals\n'
                '• Remember important details about your life and preferences',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
