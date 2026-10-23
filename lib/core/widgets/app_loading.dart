import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Widget hiển thị trạng thái loading spinner tối giản, tinh tế
class AppLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoading({
    super.key,
    this.message,
    this.size = 28.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    final spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (message == null || message!.isEmpty) {
      return Center(child: spinner);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spinner,
          const SizedBox(height: AppDimensions.space16),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
