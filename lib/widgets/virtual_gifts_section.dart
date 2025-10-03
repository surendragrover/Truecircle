import 'package:flutter/material.dart';
import '../services/loyalty_points_service.dart';
import '../services/festival_data_service.dart';
import '../theme/coral_theme.dart';

class VirtualGiftsSection extends StatefulWidget {
  final bool isHindi;
  final int loyaltyPoints;
  final List<Map<String, dynamic>> gifts;
  final FestivalHighlightInfo? festivalHighlight;
  final void Function(Map<String,dynamic> gift, {required bool usePoints}) onPurchase;
  final void Function(Map<String,dynamic> gift)? onPreview;
  final String? recommendedGiftId;
  final void Function(Map<String,dynamic> gift)? onShare;

  const VirtualGiftsSection({
    super.key,
    required this.isHindi,
    required this.loyaltyPoints,
    required this.gifts,
    required this.festivalHighlight,
    required this.onPurchase,
    this.onPreview,
    this.recommendedGiftId,
    this.onShare,
  });

  static const String _festivalGreetingGiftId = 'vg_card_1';

  @override
  State<VirtualGiftsSection> createState() => _VirtualGiftsSectionState();
}

class _VirtualGiftsSectionState extends State<VirtualGiftsSection> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<Animation<double>> _fadeIns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _prepareAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _controller.forward(); });
  }

  void _prepareAnimations() {
    final count = widget.gifts.length.clamp(1, 12);
    _fadeIns = List.generate(count, (i) {
      final start = (i * 0.08).clamp(0.0, 0.9);
      final end = (start + 0.30).clamp(0.0, 1.0);
      return CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut));
    });
  }

  @override
  void didUpdateWidget(covariant VirtualGiftsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifts.length != widget.gifts.length) {
      _prepareAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.isHindi;
    final loyaltyPoints = widget.loyaltyPoints;
    final festivalHighlight = widget.festivalHighlight;
    final recommendedGiftId = widget.recommendedGiftId;
    final onPurchase = widget.onPurchase;
    final onPreview = widget.onPreview;
    final onShare = widget.onShare;

    final ordered = List<Map<String,dynamic>>.from(widget.gifts);
    if (festivalHighlight != null) {
      final idx = ordered.indexWhere((g)=> g['id'] == VirtualGiftsSection._festivalGreetingGiftId);
      if (idx != -1) { final g = ordered.removeAt(idx); ordered.insert(0, g); }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: CoralTheme.glowShadow(0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
              const SizedBox(width: 8),
              Text(isHindi ? 'वर्चुअल उपहार (AI)' : 'Virtual Gifts (AI)', style: const TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
              const Spacer(),
              Tooltip(
                message: isHindi? 'पॉइंट्स से आंशिक भुगतान (1 पॉइंट = ₹1)' : 'Use points for partial payment (1 point = ₹1)',
                child: Row(children:[
                  const Icon(Icons.stars, size:16, color: Colors.amber),
                  const SizedBox(width:4),
                  Text('$loyaltyPoints', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w600)),
                ]),
              )
            ],
          ),
          const SizedBox(height:10),
            Text(
              isHindi
                  ? 'ये सभी उपहार पूर्णतः वर्चुअल, निजी और डिवाइस पर AI द्वारा उत्पन्न होते हैं। कोई बाहरी सर्वर share नहीं।'
                  : 'All gifts are fully virtual, private and generated on-device. No external sharing.',
              style: const TextStyle(fontSize:11,color: Colors.black54),
            ),
          const SizedBox(height:16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const SizedBox(height:12),
            itemBuilder: (_, i) {
              final g = ordered[i];
              final title = isHindi ? g['titleHi'] : g['title'];
              final desc = isHindi ? g['descHi'] : g['desc'];
              final price = (g['basePrice'] as double);
              const maxRedeemable = LoyaltyPointsService.dailyLoginPoints * 15;
              final canUse = loyaltyPoints > 0;
              final isFestivalGreeting = g['id'] == VirtualGiftsSection._festivalGreetingGiftId;
              final showFestivalBadge = isFestivalGreeting && festivalHighlight != null && festivalHighlight.daysAway <= 15;
              final anim = i < _fadeIns.length ? _fadeIns[i] : kAlwaysCompleteAnimation;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin:0.96,end:1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors:[
                            Colors.pinkAccent.withValues(alpha:.15),
                            Colors.purpleAccent.withValues(alpha:.12)
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.pinkAccent.withValues(alpha:0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children:[
                              Text(g['emoji'], style: const TextStyle(fontSize:26)),
                              const SizedBox(width:10),
                              Expanded(child: Text(title, style: const TextStyle(fontSize:14,fontWeight: FontWeight.w600))),
                              Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontSize:12,fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height:6),
                            Text(desc, style: const TextStyle(fontSize:11,height:1.3)),
                            const SizedBox(height:8),
                            Row(children:[
                              if (onPreview != null && isFestivalGreeting)
                                Padding(
                                  padding: const EdgeInsets.only(right:8.0),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:12, vertical:8)),
                                    onPressed: () => onPreview(g),
                                    child: Text(isHindi? 'पूर्वावलोकन':'Preview', style: const TextStyle(fontSize:11)),
                                  ),
                                ),
                              if (onShare != null)
                                Padding(
                                  padding: const EdgeInsets.only(right:8.0),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:10, vertical:8)),
                                    onPressed: () => onShare(g),
                                    child: Text(isHindi? 'शेयर कोड':'Share Code', style: const TextStyle(fontSize:10)),
                                  ),
                                ),
                              if (canUse)
                                OutlinedButton.icon(
                                  onPressed: () => onPurchase(g, usePoints: true),
                                  icon: const Icon(Icons.stars,size:16),
                                  label: Text(isHindi? 'पॉइंट्स + खरीद':'Use Points'),
                                ),
                              const SizedBox(width:8),
                              ElevatedButton.icon(
                                onPressed: () => onPurchase(g, usePoints: false),
                                icon: const Icon(Icons.lock_open,size:16),
                                label: Text(isHindi? 'अनलॉक':'Unlock'),
                              ),
                              const Spacer(),
                              Tooltip(
                                message: isHindi? 'अधिकतम आंशिक रिडीम संकेतक':'Indicative max partial redeem',
                                child: Text(isHindi? '≤ $maxRedeemable पॉइंट' : '≤ $maxRedeemable pts', style: const TextStyle(fontSize:10,color: Colors.black45)),
                              )
                            ])
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showFestivalBadge)
                    Positioned(
                      top: -6,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:[BoxShadow(color: Colors.deepOrange.withValues(alpha:0.4), blurRadius:6, offset: const Offset(0,3))],
                        ),
                        child: Text(isHindi? 'त्योहार ${festivalHighlight.daysAway} दिन' : 'Festival ${festivalHighlight.daysAway}d', style: const TextStyle(color: Colors.white,fontSize:10,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (recommendedGiftId != null && recommendedGiftId == g['id'])
                    Positioned(
                      top: -6,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:[BoxShadow(color: Colors.indigo.withValues(alpha:0.4), blurRadius:6, offset: const Offset(0,3))],
                        ),
                        child: Text(isHindi? 'अनुशंसित':'Recommended', style: const TextStyle(color: Colors.white,fontSize:10,fontWeight: FontWeight.bold)),
                      ),
                    )
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
