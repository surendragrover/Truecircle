import 'package:hive/hive.dart';

class CoinRewardService {
  // Singleton pattern for easy access
  CoinRewardService._privateConstructor();
  static final CoinRewardService instance = CoinRewardService._privateConstructor();

  final String _boxName = 'user_wallet';
  final String _coinsKey = 'coin_balance';

  Future<Box<int>> _getWalletBox() async {
    // This ensures the box is open before any operation.
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<int>(_boxName);
    }
    return Hive.box<int>(_boxName);
  }

  Future<int> getUserCoinsCount() async {
    final box = await _getWalletBox();
    return box.get(_coinsKey, defaultValue: 0) ?? 0;
  }

  Future<void> grantCoins(int amount) async {
    final box = await _getWalletBox();
    final currentCoins = await getUserCoinsCount();
    await box.put(_coinsKey, currentCoins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    final box = await _getWalletBox();
    final currentCoins = await getUserCoinsCount();
    if (currentCoins >= amount) {
      await box.put(_coinsKey, currentCoins - amount);
      return true; // Purchase successful
    }
    return false; // Not enough coins
  }
}
