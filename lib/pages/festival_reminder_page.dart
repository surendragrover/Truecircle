import 'package:flutter/material.dart';
import '../widgets/quick_actions_panel.dart';
import '../widgets/dr_iris_avatar.dart';

/// Festival Reminder Page
/// Cross-platform compatible: Android, iOS, macOS, Windows, Web, Linux
class FestivalReminderPage extends StatefulWidget {
  const FestivalReminderPage({super.key});

  @override
  State<FestivalReminderPage> createState() => _FestivalReminderPageState();
}

class _FestivalReminderPageState extends State<FestivalReminderPage> {
  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Service will auto-initialize when needed
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎊 Festival Reminders'),
        backgroundColor: Colors.orange[100],
        foregroundColor: Colors.black87,
        elevation: 2,
        actions: [
          // Dr. Iris avatar in app bar
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: DrIrisAvatar(size: 32),
          ),
          // Settings
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[50]!,
              Colors.deepOrange[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration, size: 64, color: Colors.orange[600]),
                const SizedBox(height: 16),
                const Text(
                  'Festival Reminders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Quick AI'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Festival Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              subtitle: const Text('Manage festival reminders'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle notification toggle
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language Preference'),
              subtitle: const Text('Hindi / English'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle language selection
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Regional Festivals'),
              subtitle: const Text('Show local celebrations'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle regional settings
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: QuickActionsPanel(
          actions: [
            QuickActionItem(
              icon: Icons.message,
              labelEn: 'Generate Messages',
              labelHi: 'फेस्टिवल संदेश',
              color: Colors.blue,
              onPressed: () => _generateQuickMessages(),
            ),
            QuickActionItem(
              icon: Icons.card_giftcard,
              labelEn: 'Suggest Gifts',
              labelHi: 'गिफ्ट सुझाव',
              color: Colors.green,
              onPressed: () => _suggestGifts(),
            ),
            QuickActionItem(
              icon: Icons.local_grocery_store,
              labelEn: 'Dry Fruits Guide',
              labelHi: 'ड्राई फ्रूट्स गाइड',
              color: Colors.orange,
              onPressed: () => _showDryFruitsGuide(),
            ),
            QuickActionItem(
              icon: Icons.event_note,
              labelEn: 'Plan Festival',
              labelHi: 'फेस्टिवल प्लानिंग',
              color: Colors.purple,
              onPressed: () => _planFestival(),
            ),
          ],
        ),
      ),
    );
  }

  void _generateQuickMessages() {
    Navigator.pop(context); // Close bottom sheet

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI Message Generator'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DrIrisAvatar(size: 64),
            const SizedBox(height: 16),
            const Text(
              'AI is generating personalized festival messages for you...',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Messages are customized based on relationship types and cultural context!',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _suggestGifts() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'AI Gift Suggestions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gift categories
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGiftCategoryItem('🥜 Dry Fruits & Nuts',
                          'Premium quality nuts for health and prosperity'),
                      _buildGiftCategoryItem('🙏 Religious Items',
                          'Sacred items for prayers and blessings'),
                      _buildGiftCategoryItem('🍯 Traditional Sweets',
                          'Authentic Indian sweets and delicacies'),
                      _buildGiftCategoryItem('🪔 Decorative Items',
                          'Beautiful decorations for festivals'),
                      _buildGiftCategoryItem('💎 Jewelry',
                          'Traditional and modern jewelry pieces'),
                      _buildGiftCategoryItem(
                          '👕 Festive Clothing', 'Traditional and ethnic wear'),
                      _buildGiftCategoryItem(
                          '📱 Electronics', 'Modern gadgets and appliances'),
                      _buildGiftCategoryItem('📚 Books & Spiritual',
                          'Religious texts and spiritual guides'),
                      _buildGiftCategoryItem(
                          '🏠 Home Decor', 'Items to beautify living spaces'),
                      _buildGiftCategoryItem('🎨 Traditional Artifacts',
                          'Handicrafts and cultural items'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Get Personalized Recommendations'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGiftCategoryItem(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle category selection
        },
      ),
    );
  }

  void _showDryFruitsGuide() {
    Navigator.pop(context);

    // Simple dry fruits recommendations
    final dryFruitsGifts = [
      {'name': 'Almonds', 'price': '₹500'},
      {'name': 'Cashews', 'price': '₹700'},
      {'name': 'Dates', 'price': '₹300'},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('🥜', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Text(
                    'Dry Fruits Premium Collection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[100]!, Colors.orange[100]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🌟 Perfect for all festivals! Dry fruits symbolize prosperity, health, and good fortune in Indian culture. They make ideal gifts for Diwali, Karva Chauth, and other celebrations.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: dryFruitsGifts
                      .map((gift) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Text('🥜',
                                  style: TextStyle(fontSize: 24)),
                              title: Text(gift['name']!),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Premium quality dry fruits for festivals'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Traditional gift with health benefits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  gift['price']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _planFestival() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.event_note, color: Colors.purple),
            SizedBox(width: 8),
            Text('Complete Festival Planner'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎯 AI-Powered Festival Planning',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPlannerItem('📋 Checklist Creation',
                'Custom to-do lists for each festival'),
            _buildPlannerItem(
                '🛒 Shopping Lists', 'Organized lists for gifts and supplies'),
            _buildPlannerItem(
                '👥 Guest Management', 'Invite and track attendees'),
            _buildPlannerItem(
                '🍽️ Menu Planning', 'Traditional recipes and meal plans'),
            _buildPlannerItem(
                '🏠 Decoration Ideas', 'Creative decoration suggestions'),
            _buildPlannerItem(
                '💰 Budget Tracker', 'Expense tracking and budgeting'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Festival planner feature coming soon!'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Planning'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
