import 'package:flutter/material.dart';
import '../models/relationship_contact.dart';
import '../models/communication_entry.dart';
import '../services/communication_tracker_service.dart';
import '../core/service_locator.dart';

/// Detailed conversation entry form with comprehensive relationship questions
class ConversationEntryPage extends StatefulWidget {
  final RelationshipContact? preSelectedContact;

  const ConversationEntryPage({super.key, this.preSelectedContact});

  @override
  State<ConversationEntryPage> createState() => _ConversationEntryPageState();
}

class _ConversationEntryPageState extends State<ConversationEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late CommunicationTrackerService _service;

  List<RelationshipContact> _contacts = [];
  RelationshipContact? _selectedContact;

  // Basic conversation details
  DateTime _conversationDate = DateTime.now();
  String _conversationType = 'in_person';
  int _conversationDuration = 30; // minutes

  // Core relationship questions (1-10 scales)
  int _overallQuality = 7;
  int _emotionalState = 7;
  int _loveLevel = 7;
  int _perceivedLoveLevel = 7;
  int _trustLevel = 7;
  int _intimacyLevel = 7;
  int _relationshipImpact = 0; // -5 to +5

  // Conflict and special moments
  bool _hadConflict = false;
  int _conflictSeverity = 0;
  bool _hadSpecialMoment = false;

  // Text fields
  final _conversationSummaryController = TextEditingController();
  final _conflictReasonController = TextEditingController();
  final _specialMomentController = TextEditingController();
  final _concernsController = TextEditingController();

  // Multi-select options
  final List<String> _selectedTopics = [];
  final List<String> _selectedEmotions = [];
  final List<String> _selectedPositives = [];
  final List<String> _selectedImprovements = [];

  final List<String> _conversationTypes = [
    'in_person',
    'phone_call',
    'video_call',
    'text_message',
  ];

  final List<String> _conversationTopics = [
    'Work/Career',
    'Family',
    'Health',
    'Future Plans',
    'Past Memories',
    'Feelings',
    'Dreams/Goals',
    'Current Events',
    'Hobbies',
    'Travel',
    'Money/Finances',
    'Relationships',
    'Personal Growth',
    'Daily Life',
    'Spiritual/Faith',
    'Entertainment',
    'Problems/Challenges',
    'Achievements',
  ];

  final List<String> _emotions = [
    'Happy',
    'Excited',
    'Content',
    'Grateful',
    'Loved',
    'Understood',
    'Peaceful',
    'Energized',
    'Sad',
    'Frustrated',
    'Anxious',
    'Hurt',
    'Angry',
    'Disappointed',
    'Lonely',
    'Confused',
    'Worried',
    'Stressed',
  ];

  final List<String> _positiveAspects = [
    'Great listening',
    'Showed empathy',
    'Made me laugh',
    'Gave good advice',
    'Shared openly',
    'Was supportive',
    'Remembered important details',
    'Asked thoughtful questions',
    'Made time for me',
    'Was fully present',
    'Expressed appreciation',
    'Showed affection',
    'Was understanding',
    'Helped solve problem',
    'Shared similar views',
    'Created fun moment',
  ];

  final List<String> _improvementAreas = [
    'Better listening needed',
    'More empathy',
    'Less criticism',
    'More appreciation',
    'Better timing',
    'More patience',
    'Less interrupting',
    'More attention',
    'Better communication',
    'More emotional support',
    'Less judgment',
    'More understanding',
    'Better conflict resolution',
    'More quality time',
    'More affection',
    'Better boundaries',
    'More honesty',
    'Less defensiveness',
  ];

  @override
  void initState() {
    super.initState();
    _service = ServiceLocator.instance.get<CommunicationTrackerService>();
    _selectedContact = widget.preSelectedContact;
    _loadContacts();
  }

  @override
  void dispose() {
    _conversationSummaryController.dispose();
    _conflictReasonController.dispose();
    _specialMomentController.dispose();
    _concernsController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    setState(() {
      _contacts = _service.getAllContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Conversation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicDetailsSection(),
              const SizedBox(height: 24),

              _buildRelationshipQualitySection(),
              const SizedBox(height: 24),

              _buildEmotionalAssessmentSection(),
              const SizedBox(height: 24),

              _buildConflictSection(),
              const SizedBox(height: 24),

              _buildSpecialMomentsSection(),
              const SizedBox(height: 24),

              _buildConversationDetailsSection(),
              const SizedBox(height: 24),

              _buildImpactAssessmentSection(),
              const SizedBox(height: 32),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Details'),

        // Contact Selection
        if (_selectedContact == null) ...[
          const Text(
            'Who did you talk with? *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<RelationshipContact>(
            initialValue: _selectedContact,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select a contact',
            ),
            items: _contacts.map((contact) {
              return DropdownMenuItem(
                value: contact,
                child: Text(contact.name),
              );
            }).toList(),
            onChanged: (contact) {
              setState(() => _selectedContact = contact);
            },
            validator: (value) {
              if (value == null) return 'Please select a contact';
              return null;
            },
          ),
          const SizedBox(height: 16),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    _selectedContact!.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedContact!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatRelationshipType(_selectedContact!.relationship),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedContact = null),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Date and Time
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'When did this conversation happen?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(_formatDate(_conversationDate)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How long? (minutes)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _conversationDuration.toString(),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                    onChanged: (value) {
                      _conversationDuration = int.tryParse(value) ?? 30;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Conversation Type
        const Text(
          'How did you communicate?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _conversationTypes.map((type) {
            final isSelected = _conversationType == type;
            return ChoiceChip(
              label: Text(_formatConversationType(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _conversationType = type);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRelationshipQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Relationship Assessment'),

        _buildSliderQuestion(
          'Overall conversation quality?',
          _overallQuality,
          (value) => setState(() => _overallQuality = value),
          description: 'How good was this conversation overall?',
        ),

        _buildSliderQuestion(
          'How much do you care about them?',
          _loveLevel,
          (value) => setState(() => _loveLevel = value),
          description: 'Your feelings of love/care for this person',
        ),

        _buildSliderQuestion(
          'How much do they care about you?',
          _perceivedLoveLevel,
          (value) => setState(() => _perceivedLoveLevel = value),
          description: 'How much you feel they love/care about you',
        ),

        _buildSliderQuestion(
          'Trust level right now?',
          _trustLevel,
          (value) => setState(() => _trustLevel = value),
          description: 'How much do you trust them currently?',
        ),

        _buildSliderQuestion(
          'Emotional closeness/intimacy?',
          _intimacyLevel,
          (value) => setState(() => _intimacyLevel = value),
          description: 'How emotionally close do you feel?',
        ),
      ],
    );
  }

  Widget _buildEmotionalAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Emotional State'),

        _buildSliderQuestion(
          'Your emotional state during conversation?',
          _emotionalState,
          (value) => setState(() => _emotionalState = value),
          description: '1 = Very negative, 10 = Very positive',
        ),

        const SizedBox(height: 16),
        const Text(
          'What emotions did you experience?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _emotions.map((emotion) {
            final isSelected = _selectedEmotions.contains(emotion);
            return FilterChip(
              label: Text(emotion),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEmotions.add(emotion);
                  } else {
                    _selectedEmotions.remove(emotion);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConflictSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Conflicts & Challenges'),

        // Conflict Toggle
        Row(
          children: [
            Switch(
              value: _hadConflict,
              onChanged: (value) {
                setState(() => _hadConflict = value);
                if (!value) {
                  _conflictReasonController.clear();
                  _conflictSeverity = 0;
                }
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Did you have any conflict or disagreement?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),

        if (_hadConflict) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _conflictReasonController,
            maxLines: 3,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'What was the conflict about?',
              hintText: 'Describe what caused the disagreement...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          _buildSliderQuestion(
            'How severe was the conflict?',
            _conflictSeverity,
            (value) => setState(() => _conflictSeverity = value),
            description: '1 = Minor disagreement, 10 = Major fight',
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialMomentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Special Moments'),

        // Special Moment Toggle
        Row(
          children: [
            Switch(
              value: _hadSpecialMoment,
              onChanged: (value) {
                setState(() => _hadSpecialMoment = value);
                if (!value) {
                  _specialMomentController.clear();
                }
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Was there a special or meaningful moment?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),

        if (_hadSpecialMoment) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialMomentController,
            maxLines: 3,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Describe the special moment',
              hintText: 'What made this moment special or meaningful?',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConversationDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Conversation Details'),

        // Topics Discussed
        const Text(
          'What topics did you discuss?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _conversationTopics.map((topic) {
            final isSelected = _selectedTopics.contains(topic);
            return FilterChip(
              label: Text(topic),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTopics.add(topic);
                  } else {
                    _selectedTopics.remove(topic);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Conversation Summary
        TextFormField(
          controller: _conversationSummaryController,
          maxLines: 4,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Conversation Summary',
            hintText:
                'Briefly describe what you talked about and how it went...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),

        // What went well
        const Text(
          'What went well in this conversation?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _positiveAspects.map((aspect) {
            final isSelected = _selectedPositives.contains(aspect);
            return FilterChip(
              label: Text(aspect),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPositives.add(aspect);
                  } else {
                    _selectedPositives.remove(aspect);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Areas for improvement
        const Text(
          'What could be improved in your communication?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _improvementAreas.map((area) {
            final isSelected = _selectedImprovements.contains(area);
            return FilterChip(
              label: Text(area),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedImprovements.add(area);
                  } else {
                    _selectedImprovements.remove(area);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImpactAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Impact & Concerns'),

        // Relationship Impact
        Text(
          'Impact on your relationship: ${_relationshipImpact > 0 ? '+' : ''}$_relationshipImpact',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _relationshipImpact.toDouble(),
          min: -5,
          max: 5,
          divisions: 10,
          onChanged: (value) {
            setState(() => _relationshipImpact = value.round());
          },
        ),
        Text(
          'Did this conversation help (+) or hurt (-) your relationship?',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Concerns or Worries
        TextFormField(
          controller: _concernsController,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Any concerns or worries?',
            hintText:
                'Anything that concerns you about this person or relationship?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderQuestion(
    String question,
    int value,
    Function(int) onChanged, {
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$question $value/10',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
        const SizedBox(height: 8),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (newValue) => onChanged(newValue.round()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveEntry,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Conversation Entry',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatRelationshipType(String relationship) {
    switch (relationship) {
      case 'family':
        return 'Family Member';
      case 'romantic_partner':
        return 'Romantic Partner';
      case 'friend':
        return 'Friend';
      case 'colleague':
        return 'Colleague';
      case 'neighbor':
        return 'Neighbor';
      case 'relative':
        return 'Relative';
      default:
        return 'Contact';
    }
  }

  String _formatConversationType(String type) {
    switch (type) {
      case 'in_person':
        return 'In Person';
      case 'phone_call':
        return 'Phone Call';
      case 'video_call':
        return 'Video Call';
      case 'text_message':
        return 'Text/Chat';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _conversationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _conversationDate = picked);
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contact'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final entry = CommunicationEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contactId: _selectedContact!.id,
        conversationDate: _conversationDate,
        conversationType: _conversationType,
        conversationDuration: _conversationDuration,
        overallQuality: _overallQuality,
        emotionalState: _emotionalState,
        loveLevel: _loveLevel,
        perceivedLoveLevel: _perceivedLoveLevel,
        hadConflict: _hadConflict,
        conflictReason: _hadConflict
            ? _conflictReasonController.text.trim()
            : null,
        conflictSeverity: _conflictSeverity,
        hadSpecialMoment: _hadSpecialMoment,
        specialMomentDescription: _hadSpecialMoment
            ? _specialMomentController.text.trim()
            : null,
        relationshipImpact: _relationshipImpact,
        topicsDiscussed: _selectedTopics,
        conversationSummary: _conversationSummaryController.text.trim(),
        emotionsExperienced: _selectedEmotions,
        trustLevel: _trustLevel,
        intimacyLevel: _intimacyLevel,
        concernsOrWorries: _concernsController.text.trim().isNotEmpty
            ? _concernsController.text.trim()
            : null,
        positiveAspects: _selectedPositives,
        improvementAreas: _selectedImprovements,
        createdAt: DateTime.now(),
      );

      await _service.saveCommunicationEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversation with ${_selectedContact!.name} saved!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
