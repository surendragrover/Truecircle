
import 'package:flutter/material.dart';
import '../services/relationship_service.dart'; // This now exports the Contact model
import '../services/auth_service.dart';       // To handle user logout

// NOTE: The Contact class definition has been removed from this file. 
// It is now correctly imported from 'relationship_service.dart' to avoid code duplication.

class SelectContactPage extends StatefulWidget {
  const SelectContactPage({super.key});

  @override
  State<SelectContactPage> createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  final String _language = 'hi'; // or 'en'
  late Stream<List<Contact>> _contactsStream;
  
  // Services are initialized here. This is safe because AuthWrapper ensures
  // this page is only built when a user is logged in.
  final RelationshipService _relationshipService = RelationshipService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Subscribe to the real-time stream of contacts from the user-specific service.
    _contactsStream = _relationshipService.getContactsStream();
  }

  // Helper function to get color based on relationship strength
  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Strong':
        return Colors.green.shade100;
      case 'Medium':
        return Colors.orange.shade100;
      case 'Weak':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  // Helper function to get text color based on relationship strength
  Color _getStrengthTextColor(String strength) {
    switch (strength) {
      case 'Strong':
        return Colors.green.shade800;
      case 'Medium':
        return Colors.orange.shade800;
      case 'Weak':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title is automatically handled by the parent GiftMarketplacePage
        title: Text(_language == 'hi' ? 'रिश्तों का डैशबोर्ड' : 'Relationship Dashboard'),
        actions: [
          // Seed data button remains for testing
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: _language == 'hi' ? 'टेस्ट डेटा डालें' : 'Seed Test Data',
            onPressed: () {
              _relationshipService.seedDatabaseWithDummyData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_language == 'hi' ? 'टेस्ट डेटा डाला जा रहा है...' : 'Seeding test data...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          // The new Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: _language == 'hi' ? 'लॉग आउट' : 'Logout',
            onPressed: () async {
              await _authService.signOut();
              // The AuthWrapper will automatically navigate to the login page.
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Contact>>(
        stream: _contactsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Stream Error: ${snapshot.error}");
            return Center(child: Text(_language == 'hi' ? 'डेटा लोड नहीं हो सका' : 'Could not load data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                _language == 'hi'
                    ? 'कोई संपर्क नहीं मिला. ऊपर दिए गए क्लाउड बटन से टेस्ट डेटा डालें.'
                    : 'No contacts found. Use the cloud icon above to seed test data.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final contacts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(contact.name[0], style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${_language == 'hi' ? contact.relationshipTypeHi : contact.relationshipType} • ${_language == 'hi' ? 'आखरी संपर्क' : 'Last contact'}: ${_language == 'hi' ? contact.lastContactedHi : contact.lastContacted}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: Chip(
                    label: Text(
                      contact.strength,
                      style: TextStyle(color: _getStrengthTextColor(contact.strength), fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _getStrengthColor(contact.strength),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
