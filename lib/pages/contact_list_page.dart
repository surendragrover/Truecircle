import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:truecircle/services/contact_service.dart';
import 'package:truecircle/services/app_mode_service.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  bool _isLoading = false;
  bool _isFullMode = false;

  @override
  void initState() {
    super.initState();
    _checkModeAndFetch();
  }

  Future<void> _checkModeAndFetch() async {
    final isFull = await AppModeService.isFullMode();
    setState(() {
      _isFullMode = isFull;
    });
    if (_isFullMode) {
      _fetchContacts();
    }
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    final contacts = await ContactService.getContacts(context);

    if (mounted) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Contacts'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isFullMode) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Full Mode is not active. Please activate it in Settings to see your contacts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No contacts found or permission denied.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchContacts,
                child: const Text('Retry Fetching Contacts'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final photo = contact.photo;
        return ListTile(
          leading: (photo != null && photo.isNotEmpty)
              ? CircleAvatar(backgroundImage: MemoryImage(photo))
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text(contact.displayName),
          subtitle: Text(contact.phones.isNotEmpty
              ? contact.phones.first.number
              : 'No phone number'),
        );
      },
    );
  }
}
