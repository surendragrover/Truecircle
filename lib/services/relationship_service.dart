
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'auth_service.dart'; // To get the current user

// Model Class for a Contact. It is now defined here to be used by other parts of the app.
class Contact {
  final String id;
  final String name;
  final String relationshipType;
  final String relationshipTypeHi;
  final String lastContacted;
  final String lastContactedHi;
  final String strength;

  const Contact({
    required this.id,
    required this.name,
    required this.relationshipType,
    required this.relationshipTypeHi,
    required this.lastContacted,
    required this.lastContactedHi,
    required this.strength,
  });

  // A factory constructor to create a Contact from Firebase data.
  factory Contact.fromMap(String id, Map<dynamic, dynamic> value) {
    return Contact(
      id: id,
      name: value['name'] ?? '',
      relationshipType: value['relationshipType'] ?? 'Unknown',
      relationshipTypeHi: value['relationshipTypeHi'] ?? 'अज्ञात',
      lastContacted: value['lastContacted'] ?? 'N/A',
      lastContactedHi: value['lastContactedHi'] ?? 'N/A',
      strength: value['strength'] ?? 'Medium',
    );
  }
}

// This service now manages data for the currently logged-in user.
class RelationshipService {
  late final DatabaseReference _contactsRef;
  final String? _userId;

  // The constructor now initializes the service for the specific user who is logged in.
  RelationshipService() : _userId = AuthService().currentUserId {
    if (_userId == null) {
      // This is a safeguard. In a correctly implemented app flow, this service
      // should only be instantiated after a user has successfully logged in.
      throw Exception("User not logged in. Cannot initialize RelationshipService.");
    }

    // The database path is now unique for each user.
    _contactsRef = FirebaseDatabase.instance.ref('users/$_userId/contacts');
    
    // As per the documentation, keep the data synced for offline use.
    _contactsRef.keepSynced(true);
  }

  // Fetches the user-specific list of contacts as a real-time stream.
  Stream<List<Contact>> getContactsStream() {
    return _contactsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) {
        return []; // Return an empty list if there's no data
      }
      final Map<dynamic, dynamic> dataMap = data as Map<dynamic, dynamic>;

      final List<Contact> contacts = [];
      dataMap.forEach((key, value) {
        if (value is Map) {
          // Use the factory constructor to create Contact objects
          contacts.add(Contact.fromMap(key, value));
        }
      });
      return contacts;
    });
  }

  // Seeds the database with dummy data for the currently logged-in user.
  Future<void> seedDatabaseWithDummyData() async {
    final Map<String, Map<String, dynamic>> dummyData = {
      'contact_1': {
        'name': 'Amit Kumar (Personal)',
        'relationshipType': 'Friend',
        'relationshipTypeHi': 'दोस्त',
        'lastContacted': '2 days ago',
        'lastContactedHi': '2 दिन पहले',
        'strength': 'Strong',
      },
      'contact_2': {
        'name': 'Priya Sharma (Personal)',
        'relationshipType': 'Family',
        'relationshipTypeHi': 'परिवार',
        'lastContacted': '1 week ago',
        'lastContactedHi': '1 हफ्ता पहले',
        'strength': 'Medium',
      },
    };
    try {
      // This will overwrite any existing contacts for the user with the dummy set.
      await _contactsRef.set(dummyData);
      print("Database for user $_userId seeded successfully!");
    } catch (e) {
      print("Error seeding database for user $_userId: $e");
    }
  }
}
