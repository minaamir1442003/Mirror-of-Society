import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}