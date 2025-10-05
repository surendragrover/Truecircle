import 'package:flutter/material.dart';
import '../services/hypnotherapy_service.dart';
import '../models/cbt_models.dart';
import '../theme/coral_theme.dart';

class HypnotherapyPage extends StatefulWidget {
  final bool isHindi;
  const HypnotherapyPage({super.key, required this.isHindi});

  @override
  State<HypnotherapyPage> createState() => _HypnotherapyPageState();
}

class _HypnotherapyPageState extends State<HypnotherapyPage> {
  bool _loading = true;
  List<HypnotherapySessionLog> _sessions = [];
  final _service = HypnotherapyService.instance;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    setState(() {
      _sessions = _service.getSessions();
      _loading = false;
    });
    _service.addListener(_refresh);
  }

  void _refresh() {
    setState(() => _sessions = _service.getSessions());
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    super.dispose();
  }

  void _startSessionDialog() {
    final focusCtl = TextEditingController();
    int relaxation = 5;
    String scriptKey = 'calm_breath';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(widget.isHindi ? 'सेशन शुरू करें' : 'Start Session'),
              content: StatefulBuilder(builder: (ctx, setStateDlg) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: scriptKey,
                      items: const [
                        DropdownMenuItem(
                            value: 'calm_breath', child: Text('Calm Breath')),
                        DropdownMenuItem(
                            value: 'deep_sleep', child: Text('Deep Sleep')),
                        DropdownMenuItem(
                            value: 'confidence_anchor',
                            child: Text('Confidence Anchor')),
                      ],
                      onChanged: (v) {
                        if (v != null) setStateDlg(() => scriptKey = v);
                      },
                    ),
                    TextField(
                      controller: focusCtl,
                      decoration: InputDecoration(
                          labelText: widget.isHindi
                              ? 'फोकस / इरादा'
                              : 'Focus / Intent'),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.isHindi
                        ? 'आरंभ विश्राम (0-10)'
                        : 'Start Relaxation (0-10): $relaxation'),
                    Slider(
                        value: relaxation.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: relaxation.toString(),
                        onChanged: (v) {
                          setStateDlg(() => relaxation = v.round());
                        }),
                  ],
                );
              }),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(widget.isHindi ? 'रद्द' : 'Cancel')),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _service.startSession(
                          scriptKey: scriptKey,
                          relaxationBefore: relaxation,
                          focusIntent: focusCtl.text.trim());
                    },
                    child: Text(widget.isHindi ? 'शुरू' : 'Start'))
              ],
            ));
  }

  void _completeSession(HypnotherapySessionLog log) {
    int relaxation = log.relaxationRatingBefore;
    final notesCtl = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(widget.isHindi ? 'सेशन समाप्त' : 'Complete Session'),
              content: StatefulBuilder(builder: (ctx, setStateDlg) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.isHindi
                        ? 'समापन विश्राम (0-10)'
                        : 'End Relaxation (0-10): $relaxation'),
                    Slider(
                        value: relaxation.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: relaxation.toString(),
                        onChanged: (v) {
                          setStateDlg(() => relaxation = v.round());
                        }),
                    TextField(
                        controller: notesCtl,
                        decoration: InputDecoration(
                            labelText: widget.isHindi
                                ? 'नोट्स (वैकल्पिक)'
                                : 'Notes (optional)'))
                  ],
                );
              }),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(widget.isHindi ? 'रद्द' : 'Cancel')),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _service.completeSession(log.id,
                          relaxationAfter: relaxation,
                          notes: notesCtl.text.trim());
                    },
                    child: Text(widget.isHindi ? 'सेव' : 'Save'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHindi ? 'हिप्नोथेरेपी' : 'Hypnotherapy'),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: CoralTheme.appBarGradient)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startSessionDialog,
        child: const Icon(Icons.play_arrow),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Text(widget.isHindi
                      ? 'अभी तक कोई सेशन नहीं'
                      : 'No sessions yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (_, i) {
                    final s = _sessions[i];
                    final meta = _service.getScriptMetadata(s.scriptKey,
                        hindi: widget.isHindi);
                    final completed = s.completedAt != null;
                    final delta = completed
                        ? (s.relaxationRatingAfter - s.relaxationRatingBefore)
                        : null;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: CoralTheme.glowShadow(0.08),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(meta['title']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                                completed
                                    ? (widget.isHindi ? 'पूरा' : 'Done')
                                    : (widget.isHindi ? 'चल रहा' : 'Active'),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: completed
                                        ? Colors.green
                                        : Colors.orange)),
                          ]),
                          const SizedBox(height: 4),
                          Text(meta['desc']!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  height: 1.2)),
                          const SizedBox(height: 6),
                          Text(
                              widget.isHindi
                                  ? 'फोकस: ${s.focusIntent}'
                                  : 'Focus: ${s.focusIntent}',
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                              widget.isHindi
                                  ? 'आरंभ/समापन विश्राम: ${s.relaxationRatingBefore} → ${s.relaxationRatingAfter}'
                                  : 'Relaxation: ${s.relaxationRatingBefore} → ${s.relaxationRatingAfter}',
                              style: const TextStyle(fontSize: 11)),
                          if (delta != null)
                            Text(
                                widget.isHindi
                                    ? 'परिवर्तन: ${delta >= 0 ? '+' : ''}$delta'
                                    : 'Change: ${delta >= 0 ? '+' : ''}$delta',
                                style: const TextStyle(fontSize: 11)),
                          if (s.notes.isNotEmpty)
                            Text(s.notes,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black87)),
                          if (!completed)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                  onPressed: () => _completeSession(s),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: Text(
                                      widget.isHindi ? 'समाप्त' : 'Complete')),
                            )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
