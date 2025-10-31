import 'package:flutter/foundation.dart';

@immutable
class Gift {
  final String id;
  final String name;
  final String description;
  final String imageAsset;
  final int price;

  const Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.price,
  });
}
