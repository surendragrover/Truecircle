import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/emotion_entry.dart';

@HiveType(typeId: 1)
class MoodGoal extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int targetIntensity;

  @HiveField(3)
  int daysTarget;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String category; // 'mood', 'consistency', 'frequency'

  MoodGoal({
    required this.title,
    required this.description,
    required this.targetIntensity,
    required this.daysTarget,
    required this.createdAt,
    this.completedAt,
    this.isActive = true,
    this.category = 'mood',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'targetIntensity': targetIntensity,
        'daysTarget': daysTarget,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isActive': isActive,
        'category': category,
      };
}

class GoalsPage extends StatefulWidget {
  final List<EmotionEntry> entries;

  const GoalsPage({super.key, required this.entries});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late Box<MoodGoal> _goalsBox;
  List<MoodGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _initGoalsBox();
  }

  Future<void> _initGoalsBox() async {
    try {
      _goalsBox = await Hive.openBox<MoodGoal>('mood_goals');
      setState(() {
        _goals = _goalsBox.values.toList();
      });
    } catch (e) {
      // If there's an error opening the box, create a new one
      _goals = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGoals = _goals.where((g) => g.isActive).toList();
    final completedGoals = _goals.where((g) => !g.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGoalDialog,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Active (${activeGoals.length})'),
                Tab(text: 'Completed (${completedGoals.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGoalsList(activeGoals, true),
                  _buildGoalsList(completedGoals, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(List<MoodGoal> goals, bool isActive) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.flag : Icons.emoji_events,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active goals' : 'No completed goals',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              const Text('Tap + to create your first mood goal'),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final progress = _calculateGoalProgress(goal);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 16),
                                SizedBox(width: 8),
                                Text('Mark Complete'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'complete') {
                            _completeGoal(goal);
                          } else if (value == 'delete') {
                            _deleteGoal(goal);
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Goal details
                Row(
                  children: [
                    const Icon(Icons.flag, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('Target: ${goal.targetIntensity}/10 mood level'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('Duration: ${goal.daysTarget} days'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('Category: ${goal.category.toUpperCase()}'),
                  ],
                ),

                if (isActive) ...[
                  const SizedBox(height: 16),

                  // Progress section
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress: ${(progress['percentage'] * 100).toInt()}%',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress['percentage'],
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress['percentage'] >= 1.0
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${progress['achieved']}/${goal.daysTarget}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: progress['percentage'] >= 1.0
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    progress['message'],
                    style: TextStyle(
                      color: progress['percentage'] >= 1.0
                          ? Colors.green
                          : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Completed on ${goal.completedAt!.day}/${goal.completedAt!.month}/${goal.completedAt!.year}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateGoalProgress(MoodGoal goal) {
    final cutoffDate = goal.createdAt;
    final relevantEntries = widget.entries
        .where((entry) => entry.timestamp.isAfter(cutoffDate))
        .toList();

    int achievedDays = 0;
    String message = '';

    switch (goal.category) {
      case 'mood':
        // Count days where average mood >= target
        final dayGroups = <String, List<EmotionEntry>>{};
        for (final entry in relevantEntries) {
          final dayKey =
              '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
          dayGroups[dayKey] = (dayGroups[dayKey] ?? [])..add(entry);
        }

        for (final dayEntries in dayGroups.values) {
          final avgIntensity =
              dayEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
                  dayEntries.length;
          if (avgIntensity >= goal.targetIntensity) {
            achievedDays++;
          }
        }
        message = achievedDays >= goal.daysTarget
            ? 'Goal achieved! You\'ve maintained your target mood level.'
            : 'Keep tracking! ${goal.daysTarget - achievedDays} more days to go.';
        break;

      case 'consistency':
        // Count consecutive days with entries
        final dayGroups = <String, bool>{};
        for (final entry in relevantEntries) {
          final dayKey =
              '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
          dayGroups[dayKey] = true;
        }
        achievedDays = dayGroups.length;
        message = achievedDays >= goal.daysTarget
            ? 'Excellent consistency! You\'ve tracked your mood regularly.'
            : 'Track daily to build the habit. ${goal.daysTarget - achievedDays} more days needed.';
        break;

      case 'frequency':
        // Count total entries
        achievedDays = relevantEntries.length;
        message = achievedDays >= goal.daysTarget
            ? 'Great job! You\'ve been actively tracking your emotions.'
            : '${goal.daysTarget - achievedDays} more entries needed to reach your goal.';
        break;
    }

    return {
      'achieved': achievedDays,
      'percentage': (achievedDays / goal.daysTarget).clamp(0.0, 1.0),
      'message': message,
    };
  }

  void _showCreateGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int targetIntensity = 7;
    int daysTarget = 7;
    String category = 'mood';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Goal'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Goal Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mood', child: Text('Mood Level')),
                    DropdownMenuItem(
                        value: 'consistency', child: Text('Daily Tracking')),
                    DropdownMenuItem(
                        value: 'frequency', child: Text('Entry Frequency')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (category == 'mood') ...[
                  Text('Target Mood Level: $targetIntensity'),
                  Slider(
                    value: targetIntensity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) {
                      setDialogState(() {
                        targetIntensity = value.round();
                      });
                    },
                  ),
                ],
                Text(
                    '${category == 'frequency' ? 'Target Entries' : 'Duration'}: $daysTarget ${category == 'frequency' ? 'entries' : 'days'}'),
                Slider(
                  value: daysTarget.toDouble(),
                  min: 1,
                  max: category == 'frequency' ? 50 : 30,
                  divisions: category == 'frequency' ? 49 : 29,
                  onChanged: (value) {
                    setDialogState(() {
                      daysTarget = value.round();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _createGoal(
                  titleController.text,
                  descriptionController.text,
                  targetIntensity,
                  daysTarget,
                  category,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }

  void _createGoal(String title, String description, int targetIntensity,
      int daysTarget, String category) {
    final goal = MoodGoal(
      title: title,
      description: description,
      targetIntensity: targetIntensity,
      daysTarget: daysTarget,
      createdAt: DateTime.now(),
      category: category,
    );

    try {
      _goalsBox.add(goal);
      setState(() {
        _goals.add(goal);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal created successfully!')),
      );
    } catch (e) {
      // Handle error if box isn't available
      setState(() {
        _goals.add(goal);
      });
    }
  }

  void _completeGoal(MoodGoal goal) {
    goal.isActive = false;
    goal.completedAt = DateTime.now();
    goal.save();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Congratulations! Goal completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteGoal(MoodGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              goal.delete();
              setState(() {
                _goals.remove(goal);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
