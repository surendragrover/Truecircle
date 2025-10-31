import './gift_model.dart';

class GiftService {
  // In a real app, this would come from a server or a local database.
  static const List<Gift> _gifts = [
    Gift(
      id: 'gift_001',
      name: 'A Virtual Rose',
      description: 'A beautiful rose to show you care.',
      imageAsset: 'assets/gifts/rose.png',
      price: 10, // Price in coins
    ),
    Gift(
      id: 'gift_002',
      name: 'A Warm Smile',
      description: 'To brighten someone\'s day.',
      imageAsset: 'assets/gifts/smile.png',
      price: 5,
    ),
    Gift(
      id: 'gift_003',
      name: 'A Supportive Hug',
      description: 'A virtual hug to offer comfort and support.',
      imageAsset: 'assets/gifts/hug.png',
      price: 15,
    ),
  ];

  Future<List<Gift>> getAvailableGifts() async {
    // Simulate a network call
    await Future.delayed(const Duration(milliseconds: 500));
    return _gifts;
  }
}
