import 'package:flutter/foundation.dart';

@immutable
class Dream {
  final String id;
  final String text;
  final DateTime createdAt;

  const Dream({
    required this.id,
    required this.text,
    required this.createdAt,
  });
}
