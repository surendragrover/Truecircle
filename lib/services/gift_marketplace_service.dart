import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import 'cultural_regional_ai.dart';

/// 🎁 Gift Marketplace Service
/// AI-powered gift recommendations based on cultural intelligence
class GiftMarketplaceService {
  
  /// 🤖 Generate AI-powered gift recommendations for a contact
  static Future<List<GiftRecommendation>> getGiftRecommendationsForContact(
    Contact contact,
    List<ContactInteraction> interactions,
    {String? occasion}
  ) async {
    try {
      // Analyze cultural context
      final culturalProfile = CulturalRegionalAI.detectRegionalCommunicationStyle(
        contact, interactions
      );
      
      final festivalAnalysis = await CulturalRegionalAI.analyzeFestivalConnections(
        contact, interactions
      );
      
      // Generate recommendations based on AI analysis
      final recommendations = <GiftRecommendation>[];
      
      // Upcoming festival recommendations
      if (festivalAnalysis.upcomingFestivals.isNotEmpty) {
        final festival = festivalAnalysis.upcomingFestivals.first;
        final festivalGift = _generateFestivalGiftRecommendation(
          contact, festival, culturalProfile
        );
        recommendations.add(festivalGift);
      }
      
      // Relationship-based recommendations
      final relationshipGift = _generateRelationshipBasedRecommendation(
        contact, culturalProfile, interactions
      );
      recommendations.add(relationshipGift);
      
      // Cultural preference recommendations
      final culturalGift = _generateCulturalPreferenceRecommendation(
        contact, culturalProfile
      );
      recommendations.add(culturalGift);
      
      return recommendations;
    } catch (e) {
      debugPrint('❌ Gift recommendation error: $e');
      return _getFallbackRecommendations();
    }
  }

  /// 🎉 Get trending gifts for current season/festivals
  static Future<List<CulturalGift>> getTrendingGifts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API
    
    final currentMonth = DateTime.now().month;
    
    // Festival-based trending gifts
    if (currentMonth >= 10 && currentMonth <= 11) { // Diwali season
      return _getDiwaliTrendingGifts();
    } else if (currentMonth >= 2 && currentMonth <= 3) { // Holi season
      return _getHoliTrendingGifts();
    }
    
    return _getGeneralTrendingGifts();
  }

  /// 📊 Get gift categories with cultural context
  static List<GiftCategory> getGiftCategories() {
    return [
      GiftCategory(
        id: 'religious',
        name: 'Religious Items',
        hindiName: 'धार्मिक वस्तुएं',
        emoji: '🙏',
        subcategories: ['Idols', 'Pooja Items', 'Prayer Books', 'Sacred Items'],
        culturalRelevance: 0.95,
      ),
      GiftCategory(
        id: 'sweets',
        name: 'Traditional Sweets',
        hindiName: 'पारंपरिक मिठाई',
        emoji: '🍬',
        subcategories: ['Laddu', 'Barfi', 'Halwa', 'Festival Boxes'],
        culturalRelevance: 0.92,
      ),
      GiftCategory(
        id: 'jewelry',
        name: 'Jewelry & Accessories',
        hindiName: 'आभूषण',
        emoji: '💍',
        subcategories: ['Gold', 'Silver', 'Artificial', 'Traditional'],
        culturalRelevance: 0.88,
      ),
      GiftCategory(
        id: 'clothing',
        name: 'Traditional Clothing',
        hindiName: 'पारंपरिक वस्त्र',
        emoji: '🥻',
        subcategories: ['Sarees', 'Kurtas', 'Lehengas', 'Accessories'],
        culturalRelevance: 0.85,
      ),
      GiftCategory(
        id: 'home_decor',
        name: 'Home Decoration',
        hindiName: 'घर की सजावट',
        emoji: '🏠',
        subcategories: ['Rangoli', 'Diyas', 'Wall Hangings', 'Torans'],
        culturalRelevance: 0.82,
      ),
      GiftCategory(
        id: 'electronics',
        name: 'Modern Electronics',
        hindiName: 'इलेक्ट्रॉनिक्स',
        emoji: '📱',
        subcategories: ['Gadgets', 'Home Appliances', 'Audio', 'Smart Devices'],
        culturalRelevance: 0.65,
      ),
    ];
  }

  /// 🛒 Cart Management
  static final List<CartItem> _cartItems = [];
  
  static List<CartItem> getCartItems() => List.from(_cartItems);
  
  static void addToCart(dynamic item, {int quantity = 1}) {
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item.name ?? item.giftSuggestion ?? 'Unknown Item',
      price: _extractPrice(item),
      quantity: quantity,
      culturalRelevance: item.culturalRelevance ?? 0.5,
      isAIRecommended: item.aiConfidence != null,
    );
    
    _cartItems.add(cartItem);
    debugPrint('🛒 Added to cart: ${cartItem.name}');
  }
  
  static void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
  }
  
  static double getCartTotal() {
    return _cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
  
  static int getCartItemCount() {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  /// 🔍 Search gifts with cultural intelligence
  static Future<List<CulturalGift>> searchGifts(
    String query, {
    String? category,
    double? minPrice,
    double? maxPrice,
    String? occasion,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock search results with cultural context
    final results = <CulturalGift>[];
    
    if (query.toLowerCase().contains('diwali') || query.contains('दीवाली')) {
      results.addAll(_getDiwaliGifts());
    } else if (query.toLowerCase().contains('holi') || query.contains('होली')) {
      results.addAll(_getHoliGifts());
    } else {
      results.addAll(_getGeneralSearchResults(query));
    }
    
    return results;
  }

  // Private Helper Methods
  
  static GiftRecommendation _generateFestivalGiftRecommendation(
    Contact contact,
    IndianFestival festival,
    RegionalProfile culturalProfile,
  ) {
    final relationship = _inferRelationshipType(contact);
    final gifts = _getFestivalSpecificGifts(festival.name);
    final selectedGift = gifts.isNotEmpty ? gifts.first : _getDefaultGift();
    
    return GiftRecommendation(
      contactName: contact.displayName,
      relationship: relationship,
      occasion: festival.name,
      giftSuggestion: selectedGift.name,
      culturalReasoning: _generateCulturalReasoning(festival, relationship, culturalProfile),
      priceRange: '₹${selectedGift.price - 500} - ₹${selectedGift.price + 500}',
      aiConfidence: 0.9,
      culturalRelevance: 0.95,
    );
  }
  
  static GiftRecommendation _generateRelationshipBasedRecommendation(
    Contact contact,
    RegionalProfile culturalProfile,
    List<ContactInteraction> interactions,
  ) {
    final relationship = _inferRelationshipType(contact);
    
    String giftSuggestion;
    String reasoning;
    double confidence;
    
    switch (relationship) {
      case 'Mother':
      case 'Father':
        giftSuggestion = 'Premium Health Supplement with Silver Coin';
        reasoning = 'Respectful gift showing care for elder\'s health and prosperity';
        confidence = 0.92;
        break;
      case 'Sister':
      case 'Brother':
        giftSuggestion = 'Personalized Photo Frame with Rakhi';
        reasoning = 'Emotional connection with personal memories and sibling bond';
        confidence = 0.88;
        break;
      case 'Friend':
        giftSuggestion = 'Branded Accessories with Cultural Touch';
        reasoning = 'Modern gift with traditional elements for friendship';
        confidence = 0.75;
        break;
      default:
        giftSuggestion = 'Traditional Sweet Box with Greeting Card';
        reasoning = 'Safe, culturally appropriate gift for any relationship';
        confidence = 0.70;
    }
    
    return GiftRecommendation(
      contactName: contact.displayName,
      relationship: relationship,
      occasion: 'General',
      giftSuggestion: giftSuggestion,
      culturalReasoning: reasoning,
      priceRange: '₹1,500 - ₹3,500',
      aiConfidence: confidence,
      culturalRelevance: 0.85,
    );
  }
  
  static GiftRecommendation _generateCulturalPreferenceRecommendation(
    Contact contact,
    RegionalProfile culturalProfile,
  ) {
    final region = culturalProfile.detectedRegion.toString();
    
    String giftSuggestion;
    String reasoning;
    
    if (region.contains('North')) {
      giftSuggestion = 'Pashmina Shawl with Traditional Embroidery';
      reasoning = 'North Indian preference for warm, artistic textiles';
    } else if (region.contains('South')) {
      giftSuggestion = 'Silk Fabric with Temple Border Design';
      reasoning = 'South Indian appreciation for silk and temple art';
    } else if (region.contains('West')) {
      giftSuggestion = 'Handcrafted Mirror Work Items';
      reasoning = 'Western Indian tradition of mirror work and handicrafts';
    } else {
      giftSuggestion = 'Regional Specialty Food Package';
      reasoning = 'Regional food specialties show cultural understanding';
    }
    
    return GiftRecommendation(
      contactName: contact.displayName,
      relationship: _inferRelationshipType(contact),
      occasion: 'Cultural Preference',
      giftSuggestion: giftSuggestion,
      culturalReasoning: reasoning,
      priceRange: '₹2,000 - ₹5,000',
      aiConfidence: 0.82,
      culturalRelevance: 0.90,
    );
  }
  
  static String _inferRelationshipType(Contact contact) {
    final name = contact.displayName.toLowerCase();
    final metadata = contact.metadata;
    
    // Check metadata first
    if (metadata['relationship'] != null) {
      return metadata['relationship'];
    }
    
    // Infer from name patterns
    if (name.contains('papa') || name.contains('dad') || name.contains('father')) {
      return 'Father';
    } else if (name.contains('mama') || name.contains('mom') || name.contains('mother')) {
      return 'Mother';
    } else if (name.contains('bhai') || name.contains('brother')) {
      return 'Brother';
    } else if (name.contains('didi') || name.contains('sister')) {
      return 'Sister';
    } else if (name.contains('uncle') || name.contains('chacha') || name.contains('mama')) {
      return 'Uncle';
    } else if (name.contains('aunty') || name.contains('chachi') || name.contains('mami')) {
      return 'Aunt';
    }
    
    return 'Friend'; // Default assumption
  }
  
  static String _generateCulturalReasoning(
    IndianFestival festival,
    String relationship,
    RegionalProfile culturalProfile,
  ) {
    final festivlName = festival.name;
    final region = culturalProfile.detectedRegion.toString();
    
    switch (festivlName) {
      case 'Diwali':
        return 'Diwali gifts should bring prosperity and light. For $relationship in $region, traditional items with modern touch work best.';
      case 'Holi':
        return 'Holi celebrates colors and joy. Organic colors and sweets are perfect for $relationship relationships.';
      case 'Eid':
        return 'Eid gifts should reflect respect and celebration. Sweet boxes and modest gifts are culturally appropriate.';
      default:
        return 'Cultural festivals require thoughtful gifts that honor traditions while showing personal care.';
    }
  }
  
  static List<CulturalGift> _getFestivalSpecificGifts(String festivalName) {
    switch (festivalName) {
      case 'Diwali':
        return _getDiwaliGifts();
      case 'Holi':
        return _getHoliGifts();
      default:
        return _getGeneralGifts();
    }
  }
  
  static List<CulturalGift> _getDiwaliGifts() {
    return [
      CulturalGift(name: 'Silver Lakshmi Coin', hindiName: 'चांदी लक्ष्मी सिक्का', emoji: '🪙', price: 1500, culturalRelevance: 0.98),
      CulturalGift(name: 'Brass Diya Set (12 pieces)', hindiName: 'पीतल दीया सेट', emoji: '🪔', price: 899, culturalRelevance: 0.95),
      CulturalGift(name: 'Dry Fruits Premium Box', hindiName: 'ड्राई फ्रूट्स', emoji: '🥜', price: 2500, culturalRelevance: 0.90),
      CulturalGift(name: 'Rangoli Stencil Kit', hindiName: 'रंगोली स्टेंसिल', emoji: '🎨', price: 399, culturalRelevance: 0.88),
    ];
  }
  
  static List<CulturalGift> _getHoliGifts() {
    return [
      CulturalGift(name: 'Organic Color Powder Set', hindiName: 'प्राकृतिक रंग', emoji: '🌈', price: 499, culturalRelevance: 0.95),
      CulturalGift(name: 'Traditional Pichkari', hindiName: 'पिचकारी', emoji: '🔫', price: 299, culturalRelevance: 0.92),
      CulturalGift(name: 'Gujiya Making Kit', hindiName: 'गुजिया बनाने का सेट', emoji: '🥟', price: 799, culturalRelevance: 0.90),
      CulturalGift(name: 'Dhol Miniature', hindiName: 'ढोल', emoji: '🥁', price: 1299, culturalRelevance: 0.85),
    ];
  }
  
  static List<CulturalGift> _getGeneralGifts() {
    return [
      CulturalGift(name: 'Prayer Beads (Mala)', hindiName: 'माला', emoji: '📿', price: 299, culturalRelevance: 0.88),
      CulturalGift(name: 'Incense Gift Box', hindiName: 'धूप अगरबत्ती', emoji: '🦨', price: 199, culturalRelevance: 0.82),
      CulturalGift(name: 'Traditional Tea Set', hindiName: 'चाय सेट', emoji: '🫖', price: 1599, culturalRelevance: 0.75),
    ];
  }
  
  static List<CulturalGift> _getDiwaliTrendingGifts() {
    return [
      CulturalGift(name: 'LED String Lights', hindiName: 'एल.ई.डी लाइट्स', emoji: '💡', price: 699, culturalRelevance: 0.85),
      CulturalGift(name: 'Artificial Marigold Garland', hindiName: 'गेंदे की माला', emoji: '🌺', price: 199, culturalRelevance: 0.82),
      ..._getDiwaliGifts(),
    ];
  }
  
  static List<CulturalGift> _getHoliTrendingGifts() {
    return [
      CulturalGift(name: 'Water Balloon Pack', hindiName: 'पानी गुब्बारे', emoji: '🎈', price: 99, culturalRelevance: 0.80),
      CulturalGift(name: 'Herbal Face Pack', hindiName: 'हर्बल फेस पैक', emoji: '🧴', price: 599, culturalRelevance: 0.75),
      ..._getHoliGifts(),
    ];
  }
  
  static List<CulturalGift> _getGeneralTrendingGifts() {
    return [
      CulturalGift(name: 'Yoga Mat with Sanskrit Prints', hindiName: 'योग मैट', emoji: '🧘', price: 1299, culturalRelevance: 0.88),
      CulturalGift(name: 'Ayurvedic Herbal Tea', hindiName: 'आयुर्वेदिक चाय', emoji: '🍵', price: 799, culturalRelevance: 0.85),
      CulturalGift(name: 'Handwoven Cotton Towels', hindiName: 'हैंडलूम तौलिया', emoji: '🏺', price: 999, culturalRelevance: 0.80),
    ];
  }
  
  static List<CulturalGift> _getGeneralSearchResults(String query) {
    // Mock search algorithm
    return [
      CulturalGift(name: 'Search Result: $query', hindiName: 'खोज परिणाम', emoji: '🔍', price: 599, culturalRelevance: 0.60),
    ];
  }
  
  static CulturalGift _getDefaultGift() {
    return CulturalGift(
      name: 'Traditional Sweet Box',
      hindiName: 'मिठाई का डिब्बा',
      emoji: '🍬',
      price: 799,
      culturalRelevance: 0.85,
    );
  }
  
  static List<GiftRecommendation> _getFallbackRecommendations() {
    return [
      GiftRecommendation(
        contactName: 'Contact',
        relationship: 'Friend',
        occasion: 'General',
        giftSuggestion: 'Traditional Sweet Box',
        culturalReasoning: 'Safe, culturally appropriate gift for any occasion',
        priceRange: '₹500 - ₹1,000',
        aiConfidence: 0.60,
        culturalRelevance: 0.80,
      ),
    ];
  }
  
  static double _extractPrice(dynamic item) {
    if (item.price != null) return item.price.toDouble();
    
    // Try to extract from price range string
    if (item.priceRange != null) {
      final priceStr = item.priceRange.toString();
      final numbers = RegExp(r'\d+').allMatches(priceStr);
      if (numbers.isNotEmpty) {
        return double.tryParse(numbers.first.group(0)!) ?? 999.0;
      }
    }
    
    return 999.0; // Default price
  }
}

// Data Models
class GiftRecommendation {
  final String contactName;
  final String relationship;
  final String occasion;
  final String giftSuggestion;
  final String culturalReasoning;
  final String priceRange;
  final double aiConfidence;
  final double culturalRelevance;

  GiftRecommendation({
    required this.contactName,
    required this.relationship,
    required this.occasion,
    required this.giftSuggestion,
    required this.culturalReasoning,
    required this.priceRange,
    required this.aiConfidence,
    required this.culturalRelevance,
  });
}

class CulturalGift {
  final String name;
  final String hindiName;
  final String emoji;
  final int price;
  final double culturalRelevance;
  final String? description;
  final List<String>? occasions;

  CulturalGift({
    required this.name,
    required this.hindiName,
    required this.emoji,
    required this.price,
    required this.culturalRelevance,
    this.description,
    this.occasions,
  });
}

class GiftCategory {
  final String id;
  final String name;
  final String hindiName;
  final String emoji;
  final List<String> subcategories;
  final double culturalRelevance;

  GiftCategory({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.emoji,
    required this.subcategories,
    required this.culturalRelevance,
  });
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final double culturalRelevance;
  final bool isAIRecommended;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.culturalRelevance,
    required this.isAIRecommended,
  });
}
