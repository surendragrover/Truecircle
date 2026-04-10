import 'package:flutter/material.dart';

import '../../services/sos_service.dart';

class SosConsentFormScreen extends StatefulWidget {
  const SosConsentFormScreen({super.key});

  @override
  State<SosConsentFormScreen> createState() => _SosConsentFormScreenState();
}

class _SosConsentFormScreenState extends State<SosConsentFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _preferredName = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _allergies = TextEditingController();
  final TextEditingController _medicalConditions = TextEditingController();
  final TextEditingController _currentMedicines = TextEditingController();
  final TextEditingController _contactName = TextEditingController();
  final TextEditingController _contactRelation = TextEditingController();
  final TextEditingController _contactPhone = TextEditingController();
  final TextEditingController _contactAltPhone = TextEditingController();
  final TextEditingController _doctorName = TextEditingController();
  final TextEditingController _doctorPhone = TextEditingController();
  final TextEditingController _consentNote = TextEditingController();

  DateTime? _dob;
  String _countryCode = 'IN';
  String _bloodGroup = 'Unknown';
  bool _allowTrustedCall = true;
  bool _allowEmergencyCall = true;
  bool _allowShareMedicalProfile = true;
  bool _allowSmsAlert = false;
  bool _saving = false;

  static const List<String> _bloodGroups = <String>[
    'Unknown',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _preferredName.dispose();
    _city.dispose();
    _address.dispose();
    _allergies.dispose();
    _medicalConditions.dispose();
    _currentMedicines.dispose();
    _contactName.dispose();
    _contactRelation.dispose();
    _contactPhone.dispose();
    _contactAltPhone.dispose();
    _doctorName.dispose();
    _doctorPhone.dispose();
    _consentNote.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final Map<String, dynamic> profile = await SOSService.getSafetyProfile();
    final String savedCountry = await SOSService.getSavedCountryCode();
    if (!mounted) return;

    setState(() {
      _countryCode = (profile['country_code'] as String?) ?? savedCountry;
      _fullName.text = (profile['full_name'] as String?) ?? '';
      _preferredName.text = (profile['preferred_name'] as String?) ?? '';
      _city.text = (profile['city'] as String?) ?? '';
      _address.text = (profile['address'] as String?) ?? '';
      _bloodGroup = (profile['blood_group'] as String?) ?? 'Unknown';
      _allergies.text = (profile['medicine_allergies'] as String?) ?? '';
      _medicalConditions.text = (profile['medical_conditions'] as String?) ?? '';
      _currentMedicines.text = (profile['current_medications'] as String?) ?? '';
      _contactName.text = (profile['trusted_contact_name'] as String?) ?? '';
      _contactRelation.text =
          (profile['trusted_contact_relation'] as String?) ?? '';
      _contactPhone.text = (profile['trusted_contact_number'] as String?) ?? '';
      _contactAltPhone.text =
          (profile['trusted_contact_alt_number'] as String?) ?? '';
      _doctorName.text = (profile['doctor_name'] as String?) ?? '';
      _doctorPhone.text = (profile['doctor_number'] as String?) ?? '';
      _consentNote.text = (profile['consent_note'] as String?) ?? '';
      final String? dobIso = profile['date_of_birth_iso'] as String?;
      _dob = dobIso == null ? null : DateTime.tryParse(dobIso);
      _allowTrustedCall = (profile['allow_call_trusted_contact'] as bool?) ?? true;
      _allowEmergencyCall = (profile['allow_call_country_emergency'] as bool?) ?? true;
      _allowShareMedicalProfile =
          (profile['allow_share_medical_profile'] as bool?) ?? true;
      _allowSmsAlert = (profile['allow_sms_alert_to_trusted_contact'] as bool?) ?? false;
    });
  }

  Future<void> _pickDob() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 100, 1, 1);
    final DateTime lastDate = DateTime(now.year - 10, 12, 31);
    final DateTime initial = _dob ?? DateTime(now.year - 24, 1, 1);

    final DateTime? selected = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initial,
    );

    if (selected != null) {
      setState(() {
        _dob = selected;
      });
    }
  }

  String _dobLabel() {
    if (_dob == null) return 'Select date of birth';
    final DateTime d = _dob!;
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_allowTrustedCall && !_allowEmergencyCall) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least one SOS permission should stay ON (trusted contact or emergency service).',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    final Map<String, dynamic> profile = <String, dynamic>{
      'full_name': _fullName.text.trim(),
      'preferred_name': _preferredName.text.trim(),
      'country_code': _countryCode,
      'city': _city.text.trim(),
      'address': _address.text.trim(),
      'date_of_birth_iso': _dob?.toIso8601String(),
      'blood_group': _bloodGroup,
      'medicine_allergies': _allergies.text.trim(),
      'medical_conditions': _medicalConditions.text.trim(),
      'current_medications': _currentMedicines.text.trim(),
      'trusted_contact_name': _contactName.text.trim(),
      'trusted_contact_relation': _contactRelation.text.trim(),
      'trusted_contact_number': _contactPhone.text.trim(),
      'trusted_contact_alt_number': _contactAltPhone.text.trim(),
      'doctor_name': _doctorName.text.trim(),
      'doctor_number': _doctorPhone.text.trim(),
      'allow_call_trusted_contact': _allowTrustedCall,
      'allow_call_country_emergency': _allowEmergencyCall,
      'allow_share_medical_profile': _allowShareMedicalProfile,
      'allow_sms_alert_to_trusted_contact': _allowSmsAlert,
      'consent_note': _consentNote.text.trim(),
      'consent_updated_at': DateTime.now().toIso8601String(),
    };

    await SOSService.saveSafetyProfile(profile);
    await SOSService.saveEmergencyNumbersFor(_countryCode);

    if (!mounted) return;
    setState(() {
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safety backup profile saved. Dr Iris can use this only during SOS.'),
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool requiredField = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: requiredField
            ? (String? v) {
                if (v == null || v.trim().isEmpty) {
                  return 'This field is required.';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> countries = SOSService.supportedCountryCodes();
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Backup Setup')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB7D8FF)),
              ),
              child: const Text(
                'This form is only for emergency backup. Dr Iris uses this data only in SOS situations when your safety is the priority.',
                style: TextStyle(height: 1.35),
              ),
            ),
            const SizedBox(height: 14),
            _sectionTitle(
              'Basic Profile',
              'So the right person can receive the right support during SOS.',
            ),
            _textField(
              controller: _fullName,
              label: 'Full Name',
              requiredField: true,
            ),
            _textField(
              controller: _preferredName,
              label: 'Preferred Name (optional)',
              hint: 'What Dr Iris should call you',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<String>(
                initialValue: countries.contains(_countryCode)
                    ? _countryCode
                    : countries.first,
                items: countries
                    .map((String c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    _countryCode = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Country Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            _textField(
              controller: _city,
              label: 'City',
              requiredField: true,
            ),
            _textField(
              controller: _address,
              label: 'Address (optional but helpful)',
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton.icon(
                onPressed: _pickDob,
                icon: const Icon(Icons.cake_outlined),
                label: Text(_dobLabel()),
              ),
            ),
            const SizedBox(height: 8),
            _sectionTitle(
              'Medical Snapshot',
              'To give emergency responders quick context.',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<String>(
                initialValue: _bloodGroup,
                items: _bloodGroups
                    .map((String b) => DropdownMenuItem<String>(
                          value: b,
                          child: Text(b),
                        ))
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    _bloodGroup = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            _textField(
              controller: _allergies,
              label: 'Medicine Allergies',
              hint: 'e.g., Penicillin, Sulfa, None',
              requiredField: true,
            ),
            _textField(
              controller: _medicalConditions,
              label: 'Medical Conditions (optional)',
              maxLines: 2,
            ),
            _textField(
              controller: _currentMedicines,
              label: 'Current Medicines (optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            _sectionTitle(
              'Trusted Contact',
              'The close contact who can be called first during SOS.',
            ),
            _textField(
              controller: _contactName,
              label: 'Trusted Contact Name',
              requiredField: true,
            ),
            _textField(
              controller: _contactRelation,
              label: 'Relation',
              hint: 'e.g., Sister, Friend, Spouse',
              requiredField: true,
            ),
            _textField(
              controller: _contactPhone,
              label: 'Primary Phone Number',
              keyboardType: TextInputType.phone,
              requiredField: true,
            ),
            _textField(
              controller: _contactAltPhone,
              label: 'Alternate Phone (optional)',
              keyboardType: TextInputType.phone,
            ),
            _textField(
              controller: _doctorName,
              label: 'Doctor Name (optional)',
            ),
            _textField(
              controller: _doctorPhone,
              label: 'Doctor Phone (optional)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            _sectionTitle(
              'SOS Permissions',
              'You decide which actions are allowed during a crisis.',
            ),
            SwitchListTile.adaptive(
              value: _allowTrustedCall,
              onChanged: (bool v) => setState(() => _allowTrustedCall = v),
              title: const Text('Allow calling my trusted contact during SOS'),
            ),
            SwitchListTile.adaptive(
              value: _allowEmergencyCall,
              onChanged: (bool v) => setState(() => _allowEmergencyCall = v),
              title: const Text('Allow calling my country emergency number during SOS'),
            ),
            SwitchListTile.adaptive(
              value: _allowShareMedicalProfile,
              onChanged: (bool v) => setState(() => _allowShareMedicalProfile = v),
              title: const Text('Allow sharing my medical snapshot for emergency help'),
            ),
            SwitchListTile.adaptive(
              value: _allowSmsAlert,
              onChanged: (bool v) => setState(() => _allowSmsAlert = v),
              title: const Text('Allow SOS SMS alert to trusted contact'),
            ),
            _textField(
              controller: _consentNote,
              label: 'Anything Dr Iris should remember during SOS? (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: Icon(_saving ? Icons.hourglass_top : Icons.verified_user_outlined),
              label: Text(_saving ? 'Saving...' : 'Save Safety Backup Consent'),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can update or revoke this consent anytime from this form.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
