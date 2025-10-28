import 'package:flutter/material.dart';
import '../models/relationship_contact.dart';
import '../services/communication_tracker_service.dart';
import '../core/service_locator.dart';

/// Page for adding a new relationship contact
class AddContactPage extends StatefulWidget {
  final RelationshipContact? contactToEdit;

  const AddContactPage({super.key, this.contactToEdit});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  late CommunicationTrackerService _service;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  // Form values
  String _selectedRelationship = 'friend';
  int _importance = 5;
  int _currentStrength = 5;
  int _interactionFrequency = 7;
  bool _isPriority = false;
  List<String> _selectedTraits = [];
  List<String> _selectedInterests = [];
  List<String> _selectedCommPrefs = [];

  final List<String> _relationshipTypes = [
    'family',
    'romantic_partner',
    'friend',
    'colleague',
    'neighbor',
    'relative',
  ];

  final List<String> _personalityTraits = [
    'Kind',
    'Funny',
    'Caring',
    'Supportive',
    'Honest',
    'Reliable',
    'Creative',
    'Intelligent',
    'Outgoing',
    'Quiet',
    'Energetic',
    'Calm',
    'Optimistic',
    'Realistic',
    'Adventurous',
    'Cautious',
    'Generous',
    'Practical',
  ];

  final List<String> _commonInterests = [
    'Movies',
    'Music',
    'Sports',
    'Books',
    'Travel',
    'Food',
    'Gaming',
    'Art',
    'Technology',
    'Nature',
    'Photography',
    'Fitness',
    'Cooking',
    'Shopping',
    'Dancing',
    'Writing',
    'Learning',
    'Business',
  ];

  final List<String> _communicationPreferences = [
    'text',
    'call',
    'in_person',
    'video_call',
  ];

  @override
  void initState() {
    super.initState();
    _service = ServiceLocator.instance.get<CommunicationTrackerService>();

    // Pre-fill form if editing existing contact
    if (widget.contactToEdit != null) {
      final contact = widget.contactToEdit!;
      _nameController.text = contact.name;
      _phoneController.text = contact.phoneNumber ?? '';
      _notesController.text = contact.notes ?? '';
      _selectedRelationship = contact.relationship;
      _importance = contact.importance;
      _currentStrength = contact.currentRelationshipStrength;
      _interactionFrequency = contact.interactionFrequency;
      _isPriority = contact.isPriority;
      _selectedTraits = List<String>.from(contact.personalityTraits);
      _selectedInterests = List<String>.from(contact.commonInterests);
      _selectedCommPrefs = List<String>.from(contact.communicationPreferences);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Contact'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveContact,
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
              // Basic Information Section
              _buildSectionTitle('Basic Information'),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // Relationship Details Section
              _buildSectionTitle('Relationship Details'),
              _buildRelationshipSection(),
              const SizedBox(height: 24),

              // Personality & Interests Section
              _buildSectionTitle('Personality & Interests'),
              _buildPersonalitySection(),
              const SizedBox(height: 24),

              // Communication Preferences Section
              _buildSectionTitle('Communication Preferences'),
              _buildCommunicationSection(),
              const SizedBox(height: 24),

              // Additional Notes Section
              _buildSectionTitle('Additional Notes'),
              _buildNotesSection(),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContact,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Contact',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Name *',
            hintText: 'Enter their name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Optional',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Relationship Type
        const Text(
          'Relationship Type *',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _relationshipTypes.map((type) {
            final isSelected = _selectedRelationship == type;
            return ChoiceChip(
              label: Text(_formatRelationshipType(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedRelationship = type;
                    // Auto-set priority for family and romantic partners
                    if (type == 'family' || type == 'romantic_partner') {
                      _isPriority = true;
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Priority Toggle
        Row(
          children: [
            Switch(
              value: _isPriority,
              onChanged: (value) {
                setState(() => _isPriority = value);
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Priority Relationship',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        Text(
          'Priority relationships appear first and get special attention',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Importance Slider
        Text('Importance in your life: $_importance/10'),
        Slider(
          value: _importance.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (value) {
            setState(() => _importance = value.round());
          },
        ),
        const SizedBox(height: 16),

        // Current Relationship Strength
        Text('Current relationship strength: $_currentStrength/10'),
        Slider(
          value: _currentStrength.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (value) {
            setState(() => _currentStrength = value.round());
          },
        ),
        const SizedBox(height: 16),

        // Interaction Frequency
        Text(
          'Typical interaction frequency: Every $_interactionFrequency days',
        ),
        Slider(
          value: _interactionFrequency.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          onChanged: (value) {
            setState(() => _interactionFrequency = value.round());
          },
        ),
      ],
    );
  }

  Widget _buildPersonalitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personality Traits',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _personalityTraits.map((trait) {
            final isSelected = _selectedTraits.contains(trait);
            return FilterChip(
              label: Text(trait),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTraits.add(trait);
                  } else {
                    _selectedTraits.remove(trait);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        const Text(
          'Common Interests',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _commonInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommunicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Communication Methods',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _communicationPreferences.map((pref) {
            final isSelected = _selectedCommPrefs.contains(pref);
            return ChoiceChip(
              label: Text(_formatCommunicationType(pref)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (!_selectedCommPrefs.contains(pref)) {
                      _selectedCommPrefs.add(pref);
                    }
                  } else {
                    _selectedCommPrefs.remove(pref);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Additional Notes',
        hintText: 'Any special notes about this person or relationship...',
        border: OutlineInputBorder(),
      ),
    );
  }

  String _formatRelationshipType(String relationship) {
    switch (relationship) {
      case 'family':
        return 'Family';
      case 'romantic_partner':
        return 'Partner';
      case 'friend':
        return 'Friend';
      case 'colleague':
        return 'Colleague';
      case 'neighbor':
        return 'Neighbor';
      case 'relative':
        return 'Relative';
      default:
        return relationship;
    }
  }

  String _formatCommunicationType(String type) {
    switch (type) {
      case 'text':
        return 'Text/Chat';
      case 'call':
        return 'Phone Call';
      case 'in_person':
        return 'In Person';
      case 'video_call':
        return 'Video Call';
      default:
        return type;
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final contact = RelationshipContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        relationship: _selectedRelationship,
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        importance: _importance,
        currentRelationshipStrength: _currentStrength,
        personalityTraits: _selectedTraits,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        interactionFrequency: _interactionFrequency,
        commonInterests: _selectedInterests,
        communicationPreferences: _selectedCommPrefs,
        relationshipHistory: {},
        isPriority: _isPriority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.saveContact(contact);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${contact.name} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
