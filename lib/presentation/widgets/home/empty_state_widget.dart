// lib/presentation/widgets/home/empty_state_widget.dart
import 'package:flutter/material.dart';

class HomeEmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const HomeEmptyStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('إعادة التحميل'),
            ),
          ],
        ],
      ),
    );
  }
}