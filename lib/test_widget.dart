import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text('Test'),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.star),
              SizedBox(width: 8),
              Text('Star'),
            ],
          ),
        ],
      ),
    );
  }
}
