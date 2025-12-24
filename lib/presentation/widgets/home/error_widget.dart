// lib/presentation/widgets/home/error_widget.dart
import 'package:flutter/material.dart';

class HomeErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  const HomeErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}