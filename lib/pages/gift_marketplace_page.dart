
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:truecircle/services/auth_service.dart';
import 'select_contact_page.dart'; // Import the contact selection page
import '../services/relationship_service.dart'; // To get the Contact model

// Gift class definition remains the same.
class Gift {
  final String name;
  final String nameHi;
  final String lottieAsset;
  final int price;

  const Gift({
    required this.name,
    required this.nameHi,
    required this.lottieAsset,
    required this.price,
  });
}

class GiftMarketplacePage extends StatefulWidget {
  const GiftMarketplacePage({super.key});

  @override
  State<GiftMarketplacePage> createState() => _GiftMarketplacePageState();
}

class _GiftMarketplacePageState extends State<GiftMarketplacePage> {
  final String _language = 'hi'; // or 'en'
  Gift? _selectedGift;
  late Razorpay _razorpay;
  final AuthService _authService = AuthService(); // Add auth service

  final List<Gift> _gifts = [
    const Gift(name: 'Love Gift', nameHi: 'प्रेम उपहार', lottieAsset: 'assets/animations/love_gift.json', price: 50),
    const Gift(name: 'Celebration', nameHi: 'जश्न', lottieAsset: 'assets/animations/celebration_gift.json', price: 75),
    const Gift(name: 'Thank You', nameHi: 'धन्यवाद', lottieAsset: 'assets/animations/thank_you_gift.json', price: 30),
  ];
  
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  // After successful payment, navigate to the contact selection page.
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_language == 'hi' ? 'भुगतान सफल! अब एक संपर्क चुनें।' : 'Payment Successful! Now select a contact.'}'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to SelectContactPage and wait for a contact to be popped.
    final selectedContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => const SelectContactPage()),
    );

    if (selectedContact != null && _selectedGift != null) {
      // Show a final confirmation message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'hi'
                ? 'आपका उपहार "${_selectedGift!.nameHi}" ${selectedContact.name} को सफलतापूर्वक भेज दिया गया है!'
                : 'Your gift "${_selectedGift!.name}" has been sent to ${selectedContact.name}!',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_language == 'hi' ? 'भुगतान विफल:' : 'Payment Failed:'} ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language == 'hi' ? 'उपहार भेजें' : 'Send a Gift'),
        actions: [
          // Logout button in the main page as well
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: _language == 'hi' ? 'लॉग आउट' : 'Logout',
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildVirtualGiftsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSendButton(),
    );
  }

  void _initiatePayment() {
    if (_selectedGift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_language == 'hi' ? 'कृपया भेजने के लिए एक उपहार चुनें।' : 'Please select a gift to send.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_HSRfmRKRmu2RbV', // Using the test key
      'amount': _selectedGift!.price * 100, // Amount in paise
      'name': 'TrueCircle Gifts',
      'description': 'Sending a ${_selectedGift!.name}',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language == 'hi' ? 'किसी खास को एक एनिमेटेड उपहार भेजें' : 'Send an Animated Gift to Someone Special',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              _language == 'hi' ? '1. एक उपहार चुनें।\n2. 'उपहार भेजें' पर क्लिक करें।\n3. भुगतान पूरा करें और जादू देखें!' : '1. Select a gift.\n2. Click \'Send Gift\'.\n3. Complete the payment and see the magic!',
               style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualGiftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_language == 'hi' ? 'उपहार चुनें' : 'Choose a Gift', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: _gifts.length,
          itemBuilder: (context, index) {
            final gift = _gifts[index];
            final isSelected = _selectedGift == gift;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGift = gift;
                });
              },
              child: Card(
                elevation: isSelected ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3) : BorderSide.none,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(gift.lottieAsset, height: 100, width: 100),
                    const SizedBox(height: 12),
                    Text(_language == 'hi' ? gift.nameHi : gift.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                     Text(
                      '₹${gift.price}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
            onPressed: _initiatePayment,
            icon: const Icon(Icons.send),
            label: Text(_language == 'hi' ? 'उपहार भेजें' : 'Send Gift'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
    );
  }
}
