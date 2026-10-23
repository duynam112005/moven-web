import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Màn hình Tổng quan Dashboard Quản trị MOVEN
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Range Info
        const Text(
          'Tổng quan kinh doanh',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          'Số liệu doanh thu tính trên đơn hàng đã giao thành công (delivered). Múi giờ Việt Nam.',
          style: AppTypography.bodySmall,
        ),

        const SizedBox(height: AppDimensions.space24),

        // 4 KPI Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Doanh thu giao thành công',
                value: CurrencyFormatter.format(0),
                subtitle: 'Chỉ tính đơn delivered',
                icon: Icons.monetization_on_outlined,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: _buildMetricCard(
                title: 'Đơn chờ xác nhận',
                value: '0',
                subtitle: 'Cần admin duyệt',
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: _buildMetricCard(
                title: 'Đang vận chuyển',
                value: '0',
                subtitle: 'Đang giao tới khách',
                icon: Icons.local_shipping_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: _buildMetricCard(
                title: 'Sắp hết hàng (≤ 5)',
                value: '0',
                subtitle: 'Tồn dưới ngưỡng cấu hình',
                icon: Icons.warning_amber_outlined,
                color: AppColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space32),

        // Recent Activity / Orders placeholder
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.space24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đơn hàng gần đây',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: AppDimensions.space16),
              const Divider(),
              const SizedBox(height: AppDimensions.space32),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    const Text(
                      'Chưa có đơn hàng nào',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      'Khi khách hàng đặt đơn COD, dữ liệu đơn sẽ xuất hiện tại đây.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppDimensions.space6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
