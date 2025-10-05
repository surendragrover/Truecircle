import 'package:flutter/material.dart';
import '../services/loyalty_points_service.dart';
import '../widgets/truecircle_logo.dart';

class LoyaltyPointsPage extends StatefulWidget {
  final bool isHindi;

  const LoyaltyPointsPage({super.key, this.isHindi = false});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  int _totalPoints = 0;
  List<Map<String, dynamic>> _pointsHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPointsData();
  }

  Future<void> _loadPointsData() async {
    try {
      final points = LoyaltyPointsService.instance.totalPoints;
      final history = LoyaltyPointsService.instance.pointsHistory;

      setState(() {
        _totalPoints = points;
        _pointsHistory = history
            .map((transaction) => {
                  'date': transaction.timestamp.toIso8601String().split('T')[0],
                  'points': transaction.points,
                  'reason': transaction.reasonEn,
                  'reasonHi': transaction.reasonHi
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BFA5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 2,
        title: Row(
          children: [
            TrueCircleLogo(
              size: 35,
              showText: false,
              isHindi: widget.isHindi,
              style: LogoStyle.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isHindi ? 'लॉयल्टी पॉइंट्स' : 'Loyalty Points',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Points Card
                  _buildTotalPointsCard(),
                  const SizedBox(height: 24),

                  // Points History
                  Text(
                    widget.isHindi ? 'पॉइंट्स का इतिहास' : 'Points History',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPointsHistory(),

                  const SizedBox(height: 24),

                  // How to Earn More Points
                  _buildEarnMoreSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            _totalPoints.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.isHindi ? 'कुल पॉइंट्स' : 'Total Points',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isHindi
                ? '1 पॉइंट = ₹1 (भविष्य की सुविधाओं के लिए)'
                : '1 Point = ₹1 (for future features)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHistory() {
    if (_pointsHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF004D40),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.history,
              size: 48,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isHindi
                  ? 'अभी तक कोई पॉइंट्स नहीं मिले\nरोज़ाना लॉगिन करके पॉइंट्स कमाएं!'
                  : 'No points earned yet\nLogin daily to earn points!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          _pointsHistory.map((entry) => _buildHistoryItem(entry)).toList(),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final date = DateTime.parse(entry['date'] + 'T00:00:00');
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00695C)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isHindi ? entry['reasonHi'] : entry['reason'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${entry['points']}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isHindi
                ? 'और पॉइंट्स कैसे कमाएं?'
                : 'How to Earn More Points?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEarnMethod(
            Icons.login,
            widget.isHindi ? 'दैनिक लॉगिन' : 'Daily Login',
            widget.isHindi ? '+5 पॉइंट्स रोज़ाना' : '+5 Points Daily',
          ),
          _buildEarnMethod(
            Icons.psychology,
            widget.isHindi ? 'डॉ. आइरिस से बात करें' : 'Chat with Dr. Iris',
            widget.isHindi ? 'जल्द आएगा' : 'Coming Soon',
          ),
          _buildEarnMethod(
            Icons.book,
            widget.isHindi ? 'मूड जर्नल भरें' : 'Complete Mood Journal',
            widget.isHindi ? 'जल्द आएगा' : 'Coming Soon',
          ),
          _buildEarnMethod(
            Icons.share,
            widget.isHindi ? 'ऐप शेयर करें' : 'Share the App',
            widget.isHindi ? 'जल्द आएगा' : 'Coming Soon',
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethod(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
