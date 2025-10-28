import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DetailedSleepEntryForm extends StatefulWidget {
  const DetailedSleepEntryForm({super.key});

  @override
  State<DetailedSleepEntryForm> createState() => _DetailedSleepEntryFormState();
}

class _DetailedSleepEntryFormState extends State<DetailedSleepEntryForm> {
  final _formKey = GlobalKey<FormState>();

  // Sleep Time Controllers
  final _bedTimeController = TextEditingController();
  final _sleepTimeController = TextEditingController();
  final _wakeTimeController = TextEditingController();
  final _getUpTimeController = TextEditingController();

  // Sleep Environment Controllers
  final _roomTemperatureController = TextEditingController();
  final _preSeepActivitiesController = TextEditingController();
  final _sleepDisruptionsController = TextEditingController();

  // Dreams & Sleep Quality Controllers
  final _dreamsController = TextEditingController();
  final _nightmaresController = TextEditingController();
  final _wakeUpFeelingsController = TextEditingController();
  final _caffeineController = TextEditingController();
  final _sleepAidsController = TextEditingController();

  // Dropdown Values
  String _selectedSleepQuality = 'Good';
  String _selectedRoomBrightness = 'Dark';
  String _selectedNoiseLevel = 'Quiet';
  String _selectedMattressComfort = 'Comfortable';
  String _selectedSleepPosition = 'Side';
  String _selectedMorningMood = 'Fresh';
  String _selectedDreamFrequency = 'Sometimes';
  String _selectedNightmareFrequency = 'Rarely';

  bool _hadCaffeine = false;
  bool _usedSleepAids = false;
  bool _exercisedToday = false;
  bool _stressedBeforeSleep = false;
  bool _usedElectronics = false;
  bool _hadHeavyMeal = false;

  final List<String> _sleepQualityOptions = [
    'Excellent',
    'Very Good',
    'Good',
    'Fair',
    'Poor',
    'Very Poor',
  ];
  final List<String> _brightnessOptions = [
    'Completely Dark',
    'Dark',
    'Dimly Lit',
    'Bright',
  ];
  final List<String> _noiseOptions = [
    'Silent',
    'Quiet',
    'Some Noise',
    'Noisy',
    'Very Noisy',
  ];
  final List<String> _comfortOptions = [
    'Very Comfortable',
    'Comfortable',
    'Acceptable',
    'Uncomfortable',
    'Very Uncomfortable',
  ];
  final List<String> _positionOptions = [
    'Back',
    'Side',
    'Stomach',
    'Mixed',
    'Unknown',
  ];
  final List<String> _moodOptions = [
    'Energetic',
    'Fresh',
    'Alert',
    'Groggy',
    'Tired',
    'Exhausted',
  ];
  final List<String> _frequencyOptions = [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Always',
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultTimes();
  }

  void _setDefaultTimes() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // Set default times
    _bedTimeController.text = '${yesterday.hour.toString().padLeft(2, '0')}:00';
    _sleepTimeController.text =
        '${(yesterday.hour + 1).toString().padLeft(2, '0')}:00';
    _wakeTimeController.text = '${now.hour.toString().padLeft(2, '0')}:00';
    _getUpTimeController.text =
        '${(now.hour + 1).toString().padLeft(2, '0')}:00';
  }

  Future<void> _saveSleepEntry() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final box = await Hive.openBox('sleep_entries');
      final entryId = DateTime.now().millisecondsSinceEpoch.toString();

      await box.put(entryId, {
        'id': entryId,
        'date': DateTime.now().toIso8601String(),

        // Sleep Times
        'bed_time': _bedTimeController.text,
        'sleep_time': _sleepTimeController.text,
        'wake_time': _wakeTimeController.text,
        'get_up_time': _getUpTimeController.text,

        // Sleep Quality & Environment
        'sleep_quality': _selectedSleepQuality,
        'room_brightness': _selectedRoomBrightness,
        'noise_level': _selectedNoiseLevel,
        'mattress_comfort': _selectedMattressComfort,
        'room_temperature': _roomTemperatureController.text,

        // Sleep Behavior
        'sleep_position': _selectedSleepPosition,
        'pre_sleep_activities': _preSeepActivitiesController.text,
        'sleep_disruptions': _sleepDisruptionsController.text,

        // Dreams & Morning
        'dream_frequency': _selectedDreamFrequency,
        'dreams_description': _dreamsController.text,
        'nightmare_frequency': _selectedNightmareFrequency,
        'nightmares_description': _nightmaresController.text,
        'morning_mood': _selectedMorningMood,
        'wake_up_feelings': _wakeUpFeelingsController.text,

        // Lifestyle Factors
        'had_caffeine': _hadCaffeine,
        'caffeine_details': _caffeineController.text,
        'used_sleep_aids': _usedSleepAids,
        'sleep_aids_details': _sleepAidsController.text,
        'exercised_today': _exercisedToday,
        'stressed_before_sleep': _stressedBeforeSleep,
        'used_electronics': _usedElectronics,
        'had_heavy_meal': _hadHeavyMeal,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sleep entry saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving sleep entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _bedTimeController.dispose();
    _sleepTimeController.dispose();
    _wakeTimeController.dispose();
    _getUpTimeController.dispose();
    _roomTemperatureController.dispose();
    _preSeepActivitiesController.dispose();
    _sleepDisruptionsController.dispose();
    _dreamsController.dispose();
    _nightmaresController.dispose();
    _wakeUpFeelingsController.dispose();
    _caffeineController.dispose();
    _sleepAidsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Sleep Entry'),
        backgroundColor: Colors.indigo,
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
              _buildSectionHeader('Sleep Timing', Icons.access_time),
              _buildSleepTimingSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Sleep Environment', Icons.hotel),
              _buildSleepEnvironmentSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Sleep Quality & Position', Icons.bed),
              _buildSleepQualitySection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Dreams & Nightmares', Icons.nights_stay),
              _buildDreamsSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Morning Experience', Icons.wb_sunny),
              _buildMorningSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Lifestyle Factors', Icons.fitness_center),
              _buildLifestyleSection(),

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
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTimingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Bed Time',
                      hintText: '22:30',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.bedtime),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sleepTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Actually Slept',
                      hintText: '23:00',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.hotel),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _wakeTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Wake Up Time',
                      hintText: '07:00',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.alarm),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _getUpTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Got Out of Bed',
                      hintText: '07:30',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.wb_sunny),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepEnvironmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedRoomBrightness,
              decoration: const InputDecoration(
                labelText: 'Room Brightness',
                border: OutlineInputBorder(),
              ),
              items: _brightnessOptions.map((brightness) {
                return DropdownMenuItem(
                  value: brightness,
                  child: Text(brightness),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedRoomBrightness = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedNoiseLevel,
              decoration: const InputDecoration(
                labelText: 'Room Noise Level',
                border: OutlineInputBorder(),
              ),
              items: _noiseOptions.map((noise) {
                return DropdownMenuItem(value: noise, child: Text(noise));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedNoiseLevel = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomTemperatureController,
              decoration: const InputDecoration(
                labelText: 'Room Temperature',
                hintText: 'Too hot, too cold, just right, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _preSeepActivitiesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Pre-Sleep Activities',
                hintText: 'What did you do before going to bed?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedSleepQuality,
              decoration: const InputDecoration(
                labelText: 'Sleep Quality',
                border: OutlineInputBorder(),
              ),
              items: _sleepQualityOptions.map((quality) {
                return DropdownMenuItem(value: quality, child: Text(quality));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedSleepQuality = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedMattressComfort,
              decoration: const InputDecoration(
                labelText: 'Mattress Comfort',
                border: OutlineInputBorder(),
              ),
              items: _comfortOptions.map((comfort) {
                return DropdownMenuItem(value: comfort, child: Text(comfort));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedMattressComfort = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSleepPosition,
              decoration: const InputDecoration(
                labelText: 'Sleep Position',
                border: OutlineInputBorder(),
              ),
              items: _positionOptions.map((position) {
                return DropdownMenuItem(value: position, child: Text(position));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedSleepPosition = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sleepDisruptionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Sleep Disruptions',
                hintText: 'Did anything wake you up? How many times?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDreamsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedDreamFrequency,
              decoration: const InputDecoration(
                labelText: 'Dream Frequency',
                border: OutlineInputBorder(),
              ),
              items: _frequencyOptions.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedDreamFrequency = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dreamsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Dreams Description',
                hintText: 'What did you dream about? How did it make you feel?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedNightmareFrequency,
              decoration: const InputDecoration(
                labelText: 'Nightmare Frequency',
                border: OutlineInputBorder(),
              ),
              items: _frequencyOptions.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedNightmareFrequency = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nightmaresController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nightmares Description',
                hintText: 'Any bad dreams or nightmares? What happened?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorningSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMorningMood,
              decoration: const InputDecoration(
                labelText: 'Morning Mood',
                border: OutlineInputBorder(),
              ),
              items: _moodOptions.map((mood) {
                return DropdownMenuItem(value: mood, child: Text(mood));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedMorningMood = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _wakeUpFeelingsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'How You Felt Upon Waking',
                hintText: 'Refreshed, tired, anxious, peaceful, etc.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Lifestyle checkboxes
            CheckboxListTile(
              title: const Text('Had caffeine'),
              value: _hadCaffeine,
              onChanged: (value) => setState(() => _hadCaffeine = value!),
            ),
            if (_hadCaffeine)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: TextFormField(
                  controller: _caffeineController,
                  decoration: const InputDecoration(
                    labelText: 'Caffeine Details',
                    hintText: 'What time? How much?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            CheckboxListTile(
              title: const Text('Used sleep aids'),
              value: _usedSleepAids,
              onChanged: (value) => setState(() => _usedSleepAids = value!),
            ),
            if (_usedSleepAids)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: TextFormField(
                  controller: _sleepAidsController,
                  decoration: const InputDecoration(
                    labelText: 'Sleep Aids Details',
                    hintText: 'What did you take?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            CheckboxListTile(
              title: const Text('Exercised today'),
              value: _exercisedToday,
              onChanged: (value) => setState(() => _exercisedToday = value!),
            ),

            CheckboxListTile(
              title: const Text('Felt stressed before sleep'),
              value: _stressedBeforeSleep,
              onChanged: (value) =>
                  setState(() => _stressedBeforeSleep = value!),
            ),

            CheckboxListTile(
              title: const Text('Used electronics before bed'),
              value: _usedElectronics,
              onChanged: (value) => setState(() => _usedElectronics = value!),
            ),

            CheckboxListTile(
              title: const Text('Had heavy meal before bed'),
              value: _hadHeavyMeal,
              onChanged: (value) => setState(() => _hadHeavyMeal = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveSleepEntry,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save Sleep Entry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
