import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingTipsPage extends StatefulWidget {
  const BreathingTipsPage({super.key});

  @override
  State<BreathingTipsPage> createState() => _BreathingTipsPageState();
}

class _BreathingTipsPageState extends State<BreathingTipsPage> {
  List<dynamic> _sessions = [];
  bool _isHindi = false;

  @override
  void initState() {
    super.initState();
    _loadBreathingData();
  }

  Future<void> _loadBreathingData() async {
    final data = await rootBundle
        .loadString('Demo_data/Breathing_+Exercises_Demo_Data.json');
    setState(() {
      _sessions = json.decode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isHindi ? 'श्वास व्यायाम सुझाव' : 'Breathing Exercise Tips'),
        actions: [
          IconButton(
            icon: Icon(_isHindi ? Icons.language : Icons.translate),
            onPressed: () => setState(() => _isHindi = !_isHindi),
            tooltip: _isHindi ? 'Switch to English' : 'हिंदी में देखें',
          ),
        ],
      ),
      body: _sessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isHindi
                              ? session['technique_hindi']
                              : session['technique'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_isHindi ? 'अवधि: ' : 'Duration: '}${session['duration_minutes']} min',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isHindi
                              ? 'शुरू में तनाव: ${session['stress_before']} | बाद में तनाव: ${session['stress_after']}'
                              : 'Stress Before: ${session['stress_before']} | After: ${session['stress_after']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isHindi
                              ? 'प्रभावशीलता: ${session['effectiveness']}/10'
                              : 'Effectiveness: ${session['effectiveness']}/10',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isHindi
                              ? 'शारीरिक अनुभव: ${session['physical_sensation_hindi']}'
                              : 'Physical Sensation: ${session['physical_sensation']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isHindi
                              ? 'मानसिक स्पष्टता: ${session['mental_clarity_hindi']}'
                              : 'Mental Clarity: ${session['mental_clarity']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isHindi
                              ? 'ऊर्जा स्तर: ${session['energy_level_hindi']}'
                              : 'Energy Level: ${session['energy_level']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
