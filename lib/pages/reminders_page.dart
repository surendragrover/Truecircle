import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class MoodReminder extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  TimeOfDay time;

  @HiveField(2)
  List<int> weekdays; // 1-7 (Monday-Sunday)

  @HiveField(3)
  bool isActive;

  @HiveField(4)
  String message;

  @HiveField(5)
  DateTime createdAt;

  MoodReminder({
    required this.title,
    required this.time,
    required this.weekdays,
    this.isActive = true,
    this.message = 'Time to check in with your mood!',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'time': '${time.hour}:${time.minute}',
        'weekdays': weekdays,
        'isActive': isActive,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };
}

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late Box<MoodReminder> _remindersBox;
  List<MoodReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRemindersBox();
  }

  Future<void> _initRemindersBox() async {
    try {
      _remindersBox = await Hive.openBox<MoodReminder>('mood_reminders');
      setState(() {
        _reminders = _remindersBox.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _reminders = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mood Reminders')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateReminderDialog,
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No reminders set',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create reminders to build a consistent mood tracking habit',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreateReminderDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Reminder'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(MoodReminder reminder, int index) {
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) {
                    reminder.isActive = value;
                    reminder.save();
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            value ? 'Reminder enabled' : 'Reminder disabled'),
                      ),
                    );
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditReminderDialog(reminder, index);
                    } else if (value == 'delete') {
                      _deleteReminder(reminder);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Days of week
            Row(
              children: List.generate(7, (dayIndex) {
                final isSelected = reminder.weekdays.contains(dayIndex + 1);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      weekdayNames[dayIndex],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),
            Text(
              reminder.message,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),

            if (!reminder.isActive)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DISABLED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateReminderDialog() {
    _showReminderDialog();
  }

  void _showEditReminderDialog(MoodReminder reminder, int index) {
    _showReminderDialog(reminder: reminder, index: index);
  }

  void _showReminderDialog({MoodReminder? reminder, int? index}) {
    final titleController = TextEditingController(text: reminder?.title ?? '');
    final messageController = TextEditingController(
        text: reminder?.message ?? 'Time to check in with your mood!');
    TimeOfDay selectedTime = reminder?.time ?? TimeOfDay.now();
    List<int> selectedWeekdays =
        List.from(reminder?.weekdays ?? [1, 2, 3, 4, 5]); // Default: Weekdays

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reminder == null ? 'Create Reminder' : 'Edit Reminder'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Picker
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Time'),
                  subtitle: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Days of week selection
                const Text(
                  'Repeat on:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .asMap()
                      .entries
                      .map((entry) {
                    final dayIndex = entry.key + 1;
                    final dayLabel = entry.value;
                    final isSelected = selectedWeekdays.contains(dayIndex);

                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected) {
                            selectedWeekdays.remove(dayIndex);
                          } else {
                            selectedWeekdays.add(dayIndex);
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            dayLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
              if (titleController.text.isNotEmpty &&
                  selectedWeekdays.isNotEmpty) {
                _saveReminder(
                  title: titleController.text,
                  time: selectedTime,
                  weekdays: selectedWeekdays,
                  message: messageController.text,
                  reminder: reminder,
                  index: index,
                );
                Navigator.pop(context);
              }
            },
            child: Text(reminder == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _saveReminder({
    required String title,
    required TimeOfDay time,
    required List<int> weekdays,
    required String message,
    MoodReminder? reminder,
    int? index,
  }) {
    if (reminder == null) {
      // Create new reminder
      final newReminder = MoodReminder(
        title: title,
        time: time,
        weekdays: weekdays,
        message: message,
        createdAt: DateTime.now(),
      );

      try {
        _remindersBox.add(newReminder);
        setState(() {
          _reminders.add(newReminder);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder created successfully!')),
        );
      } catch (e) {
        setState(() {
          _reminders.add(newReminder);
        });
      }
    } else {
      // Update existing reminder
      reminder.title = title;
      reminder.time = time;
      reminder.weekdays = weekdays;
      reminder.message = message;
      reminder.save();

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder updated successfully!')),
      );
    }
  }

  void _deleteReminder(MoodReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              reminder.delete();
              setState(() {
                _reminders.remove(reminder);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder deleted')),
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
