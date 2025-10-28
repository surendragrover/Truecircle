import 'package:hive/hive.dart';

// Single enum definition
enum CoinTransactionType {
  dailyLogin,
  entryReward,
  marketplacePurchase,
  bonus,
}

@HiveType(typeId: 10)
class CoinReward extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  CoinTransactionType type;

  @HiveField(2)
  int amount;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? description;

  CoinReward({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
  };

  factory CoinReward.fromJson(Map<String, dynamic> json) => CoinReward(
    id: json['id'],
    type: CoinTransactionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => CoinTransactionType.bonus,
    ),
    amount: json['amount'] ?? 0,
    timestamp: DateTime.parse(json['timestamp']),
    description: json['description'],
  );
}

// Manual Hive adapters (following TrueCircle convention)
class CoinTransactionTypeAdapter extends TypeAdapter<CoinTransactionType> {
  @override
  final int typeId = 72;

  @override
  CoinTransactionType read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return CoinTransactionType.dailyLogin;
      case 1:
        return CoinTransactionType.entryReward;
      case 2:
        return CoinTransactionType.marketplacePurchase;
      case 3:
        return CoinTransactionType.bonus;
      default:
        return CoinTransactionType.bonus;
    }
  }

  @override
  void write(BinaryWriter writer, CoinTransactionType obj) {
    switch (obj) {
      case CoinTransactionType.dailyLogin:
        writer.writeByte(0);
        break;
      case CoinTransactionType.entryReward:
        writer.writeByte(1);
        break;
      case CoinTransactionType.marketplacePurchase:
        writer.writeByte(2);
        break;
      case CoinTransactionType.bonus:
        writer.writeByte(3);
        break;
    }
  }
}

class CoinRewardAdapter extends TypeAdapter<CoinReward> {
  @override
  final int typeId = 10;

  @override
  CoinReward read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinReward(
      id: fields[0] as String,
      type: fields[1] as CoinTransactionType,
      amount: fields[2] as int,
      timestamp: fields[3] as DateTime,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CoinReward obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinRewardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}