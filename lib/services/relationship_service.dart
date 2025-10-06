import 'package:flutter/foundation.dart';
import 'auth_service.dart';

// Model Class for a Contact
class Contact {
  final String id;
  final String name;
  final String relationshipType;
  final String relationshipTypeHi;
  final DateTime lastInteractionDate;
  final int interactionFrequency;
  final double emotionalScore;

  Contact({
    required this.id,
    required this.name,
    required this.relationshipType,
    required this.relationshipTypeHi,
    required this.lastInteractionDate,
    required this.interactionFrequency,
    required this.emotionalScore,
  });

  // Added missing properties for compatibility
  String get lastContacted => lastInteractionDate.toString();
  String get lastContactedHi => lastContacted;
  double get strength => emotionalScore;
}

// Relationship Service - simplified for compatibility
class RelationshipService {
  final String? _userId;

  RelationshipService() : _userId = AuthService().currentUserId {
    if (_userId == null) {
      throw Exception("User not logged in. Cannot initialize RelationshipService.");
    }
  }

  Stream<List<Contact>> getContactsStream() {
    return Stream.value(<Contact>[]);
  }

  Future<void> seedDummyData() async {
    debugPrint("seedDummyData temporarily disabled");
  }
}
