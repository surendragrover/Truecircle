import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/relationship_contact.dart';
import '../services/relationship_pulse_analyzer.dart';

/// Interactive relationship network visualization
/// Shows connections between contacts and their relationship strength
class RelationshipNetworkVisualization extends StatefulWidget {
  final List<RelationshipContact> contacts;
  final Map<String, RelationshipPulseScore> pulseScores;
  final Function(RelationshipContact) onContactTapped;

  const RelationshipNetworkVisualization({
    super.key,
    required this.contacts,
    required this.pulseScores,
    required this.onContactTapped,
  });

  @override
  State<RelationshipNetworkVisualization> createState() =>
      _RelationshipNetworkVisualizationState();
}

class _RelationshipNetworkVisualizationState
    extends State<RelationshipNetworkVisualization>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TransformationController _transformationController =
      TransformationController();

  RelationshipContact? _selectedContact;

  // Layout parameters
  final double _outerRadius = 200;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControlPanel(),
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.0,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: RelationshipNetworkPainter(
                  contacts: widget.contacts,
                  pulseScores: widget.pulseScores,
                  animationValue: _animationController.value,
                  selectedContact: _selectedContact,
                ),
                child: GestureDetector(onTapUp: _handleTap, child: Container()),
              ),
            ),
          ),
        ),
        if (_selectedContact != null) _buildSelectedContactInfo(),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Relationship Network',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${widget.contacts.length} connections mapped',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _resetView,
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Center View',
          ),
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
          ),
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContactInfo() {
    final contact = _selectedContact!;
    final pulseScore = widget.pulseScores[contact.id];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: pulseScore?.categoryColor ?? Colors.grey,
                child: Text(
                  contact.name[0].toUpperCase(),
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
                      contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatRelationshipType(contact.relationship),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (pulseScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pulseScore.categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pulseScore.overallScore.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Strength',
                  '${contact.relationshipStrength}/10',
                  Icons.favorite,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Importance',
                  '${contact.importanceLevel}/10',
                  Icons.star,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Priority',
                  contact.isPriority ? 'High' : 'Normal',
                  Icons.priority_high,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onContactTapped(contact),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => setState(() => _selectedContact = null),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
      ],
    );
  }

  void _handleTap(TapUpDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;

    // Convert to relative position within the canvas
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);

    // Find the closest contact to the tap position
    RelationshipContact? tappedContact;
    double minDistance = double.infinity;

    for (int i = 0; i < widget.contacts.length; i++) {
      final contact = widget.contacts[i];
      final contactPosition = _getContactPosition(
        i,
        widget.contacts.length,
        center,
      );
      final distance = (localPosition - contactPosition).distance;

      if (distance < 30 && distance < minDistance) {
        minDistance = distance;
        tappedContact = contact;
      }
    }

    if (tappedContact != null) {
      setState(() {
        _selectedContact = _selectedContact == tappedContact
            ? null
            : tappedContact;
      });
    }
  }

  Offset _getContactPosition(int index, int total, Offset center) {
    if (total == 0) return center;

    final angle = (2 * math.pi * index) / total;
    final radius = _outerRadius;

    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 3.0) {
      _transformationController.value = Matrix4.identity()
        ..scaleByDouble(currentScale * 1.2, currentScale * 1.2, 1.0, 1.0);
    }
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.5) {
      _transformationController.value = Matrix4.identity()
        ..scaleByDouble(currentScale * 0.8, currentScale * 0.8, 1.0, 1.0);
    }
  }

  String _formatRelationshipType(String type) {
    switch (type) {
      case 'romantic_partner':
        return 'Romantic Partner';
      case 'family':
        return 'Family';
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
}

/// Custom painter for drawing the relationship network
class RelationshipNetworkPainter extends CustomPainter {
  final List<RelationshipContact> contacts;
  final Map<String, RelationshipPulseScore> pulseScores;
  final double animationValue;
  final RelationshipContact? selectedContact;

  RelationshipNetworkPainter({
    required this.contacts,
    required this.pulseScores,
    required this.animationValue,
    this.selectedContact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) * 0.35;

    // Draw center (user)
    _drawUserCenter(canvas, center);

    // Draw connections and contacts
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      final contactPosition = _getContactPosition(
        i,
        contacts.length,
        center,
        outerRadius,
      );
      final pulseScore = pulseScores[contact.id];

      // Draw connection line
      _drawConnection(canvas, center, contactPosition, contact, pulseScore);

      // Draw contact node
      _drawContact(canvas, contactPosition, contact, pulseScore);
    }

    // Draw selection highlight
    if (selectedContact != null) {
      final index = contacts.indexOf(selectedContact!);
      if (index >= 0) {
        final position = _getContactPosition(
          index,
          contacts.length,
          center,
          outerRadius,
        );
        _drawSelectionHighlight(canvas, position);
      }
    }
  }

  void _drawUserCenter(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.purple.shade400
      ..style = PaintingStyle.fill;

    // Pulsing animation
    final pulseRadius = 25 + (math.sin(animationValue * 2 * math.pi) * 5);

    canvas.drawCircle(center, pulseRadius, paint);

    // User icon
    final iconPainter = TextPainter(
      text: const TextSpan(text: '👤', style: TextStyle(fontSize: 20)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );
  }

  void _drawConnection(
    Canvas canvas,
    Offset center,
    Offset contactPosition,
    RelationshipContact contact,
    RelationshipPulseScore? pulseScore,
  ) {
    final paint = Paint()
      ..strokeWidth = 2 + (contact.relationshipStrength / 10) * 3
      ..style = PaintingStyle.stroke;

    // Color based on relationship health
    if (pulseScore != null) {
      paint.color = pulseScore.categoryColor.withValues(alpha: 0.6);
    } else {
      paint.color = Colors.grey.withValues(alpha: 0.3);
    }

    // Animate connection strength
    final animatedStrokeWidth =
        paint.strokeWidth * (0.5 + 0.5 * math.sin(animationValue * math.pi));
    paint.strokeWidth = animatedStrokeWidth;

    canvas.drawLine(center, contactPosition, paint);

    // Draw strength indicators along the line
    if (contact.relationshipStrength >= 8) {
      _drawStrengthIndicators(canvas, center, contactPosition, paint.color);
    }
  }

  void _drawContact(
    Canvas canvas,
    Offset position,
    RelationshipContact contact,
    RelationshipPulseScore? pulseScore,
  ) {
    final radius = 20 + (contact.importanceLevel / 10) * 10;

    // Background circle
    final bgPaint = Paint()
      ..color = pulseScore?.categoryColor ?? Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = contact.isPriority ? Colors.yellow.shade600 : Colors.white
      ..strokeWidth = contact.isPriority ? 3 : 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, radius, borderPaint);

    // Contact initial
    final textPainter = TextPainter(
      text: TextSpan(
        text: contact.name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Relationship type indicator
    _drawRelationshipTypeIcon(canvas, position, contact.relationship, radius);
  }

  void _drawSelectionHighlight(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = Colors.yellow.shade400.withValues(alpha: 0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final pulseRadius = 35 + (math.sin(animationValue * 4 * math.pi) * 8);
    canvas.drawCircle(position, pulseRadius, paint);
  }

  void _drawStrengthIndicators(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    for (double i = 0.2; i <= 0.8; i += 0.2) {
      final pos = start + direction * distance * i;
      canvas.drawCircle(pos, 2, paint);
    }
  }

  void _drawRelationshipTypeIcon(
    Canvas canvas,
    Offset position,
    String relationship,
    double radius,
  ) {
    String icon;
    switch (relationship) {
      case 'romantic_partner':
        icon = '💕';
        break;
      case 'family':
        icon = '👨‍👩‍👧‍👦';
        break;
      case 'friend':
        icon = '🤝';
        break;
      case 'colleague':
        icon = '💼';
        break;
      case 'neighbor':
        icon = '🏠';
        break;
      case 'relative':
        icon = '👥';
        break;
      default:
        icon = '👤';
    }

    final iconPainter = TextPainter(
      text: TextSpan(text: icon, style: const TextStyle(fontSize: 12)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      position +
          Offset(radius * 0.7, -radius * 0.7) -
          Offset(iconPainter.width / 2, iconPainter.height / 2),
    );
  }

  Offset _getContactPosition(
    int index,
    int total,
    Offset center,
    double radius,
  ) {
    if (total == 0) return center;

    final angle = (2 * math.pi * index) / total - math.pi / 2; // Start from top

    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(RelationshipNetworkPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedContact != selectedContact ||
        oldDelegate.contacts.length != contacts.length;
  }
}
