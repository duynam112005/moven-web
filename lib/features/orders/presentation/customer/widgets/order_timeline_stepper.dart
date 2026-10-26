import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';

/// Stepper tiến trình vận chuyển đơn hàng sinh động với timeline audit log
class OrderTimelineStepper extends StatefulWidget {
  final Order order;

  const OrderTimelineStepper({
    super.key,
    required this.order,
  });

  @override
  State<OrderTimelineStepper> createState() => _OrderTimelineStepperState();
}

class _OrderTimelineStepperState extends State<OrderTimelineStepper> {
  bool _isLogExpanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order.status;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến trình đơn hàng',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isLogExpanded = !_isLogExpanded),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: AppDimensions.space4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isLogExpanded ? 'Thu gọn' : 'Chi tiết lịch sử',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _isLogExpanded ? 0.5 : 0.0,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),

          // 1. Interactive Stepper Graphic
          _buildStepperGraphic(status),

          // 2. Expandable Audit Log (AnimatedCrossFade)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            crossFadeState: _isLogExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.space16),
                  child: Divider(color: AppColors.border, height: 1),
                ),
                Text(
                  'Nhật ký giao vận chi tiết',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                if (order.statusHistory.isEmpty)
                  Text(
                    'Chưa có cập nhật nào khác.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  )
                else
                  ...order.statusHistory.map((hist) {
                    final time = DateFormat('dd/MM/yyyy HH:mm').format(hist.createdAt);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      hist.toStatus.displayName,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: hist.toStatus.badgeTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.space8),
                                    Text(
                                      time,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                if (hist.note != null && hist.note!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      hist.note!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperGraphic(OrderStatus status) {
    if (status == OrderStatus.cancelled) {
      return _buildExceptionTimeline(
        title: 'Đơn hàng đã hủy',
        description: widget.order.cancellationReason ?? 'Khách hoặc cửa hàng đã hủy đơn này.',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
      );
    }

    if (status == OrderStatus.returned) {
      return _buildExceptionTimeline(
        title: 'Hàng đã hoàn về kho shop',
        description: 'Kiện hàng hoàn đã được quản trị viên nhận lại và nhập kho an toàn.',
        icon: Icons.assignment_return_outlined,
        color: const Color(0xFF7E22CE),
      );
    }

    final isStep1Active = true;
    final isStep2Active = status == OrderStatus.shipping ||
        status == OrderStatus.delivered ||
        status == OrderStatus.deliveryFailed;
    final isStep3Active = status == OrderStatus.delivered;
    final isStep3Failed = status == OrderStatus.deliveryFailed;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Step 1
            _buildStepNode(
              title: 'Đặt hàng',
              subtitle: 'Đang xử lý',
              isActive: isStep1Active,
              icon: Icons.check,
            ),
            // Connector 1-2
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                height: 3,
                color: isStep2Active ? AppColors.primary : AppColors.border,
              ),
            ),
            // Step 2
            _buildStepNode(
              title: 'Đang giao',
              subtitle: isStep2Active ? 'Đang trên đường' : 'Chờ bàn giao',
              isActive: isStep2Active,
              icon: Icons.local_shipping_outlined,
            ),
            // Connector 2-3
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                height: 3,
                color: isStep3Active
                    ? AppColors.success
                    : isStep3Failed
                        ? AppColors.warning
                        : AppColors.border,
              ),
            ),
            // Step 3
            _buildStepNode(
              title: isStep3Failed ? 'Giao thất bại' : 'Hoàn tất',
              subtitle: isStep3Active
                  ? 'Đã nhận hàng'
                  : isStep3Failed
                      ? 'Shop sẽ hỗ trợ'
                      : 'Giao hàng',
              isActive: isStep3Active || isStep3Failed,
              isFailed: isStep3Failed,
              icon: isStep3Active
                  ? Icons.check_circle
                  : isStep3Failed
                      ? Icons.error_outline
                      : Icons.inventory_2_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepNode({
    required String title,
    required String subtitle,
    required bool isActive,
    bool isFailed = false,
    required IconData icon,
  }) {
    final activeColor = isFailed
        ? AppColors.warning
        : isActive
            ? AppColors.primary
            : AppColors.border;

    final iconColor = isActive ? AppColors.onPrimary : AppColors.textMuted;
    final bgCircleColor = isFailed
        ? AppColors.warning
        : isActive
            ? AppColors.primary
            : AppColors.surfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgCircleColor,
            shape: BoxShape.circle,
            border: Border.all(color: activeColor, width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isFailed
                ? AppColors.warning
                : isActive
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExceptionTimeline({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
