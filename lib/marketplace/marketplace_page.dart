import 'package:flutter/material.dart';
import './gift_model.dart';
import './gift_service.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final GiftService _giftService = GiftService();
  late Future<List<Gift>> _giftsFuture;

  @override
  void initState() {
    super.initState();
    _giftsFuture = _giftService.getAvailableGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Marketplace'),
      ),
      body: FutureBuilder<List<Gift>>(
        future: _giftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load gifts.'));
          }
          final gifts = snapshot.data ?? [];
          if (gifts.isEmpty) {
            return const Center(child: Text('No gifts available right now.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              return _buildGiftCard(gifts[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildGiftCard(Gift gift) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                gift.imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              gift.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '${gift.price} coins',
              style: const TextStyle(fontSize: 14, color: Colors.amber),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
