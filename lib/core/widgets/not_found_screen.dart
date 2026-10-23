import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';
import '../router/route_names.dart';
import 'app_button.dart';

/// Trang hiển thị khi không tìm thấy đường dẫn (Lỗi 404 Not Found)
class NotFoundScreen extends StatelessWidget {
  final String? path;

  const NotFoundScreen({super.key, this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              const Text(
                'Trang không tồn tại',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: AppDimensions.space12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  path != null
                      ? 'Đường dẫn "$path" không tồn tại hoặc đã bị thay đổi.'
                      : 'Trang bạn đang tìm kiếm không tồn tại hoặc đã được chuyển sang địa chỉ khác.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
              AppButton(
                label: 'Về trang chủ',
                icon: const Icon(Icons.home_outlined, size: 18),
                onPressed: () => context.goNamed(RouteNames.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
