import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/errors/app_exception.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/core/utils/responsive_layout.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/core/widgets/empty_state_view.dart';
import 'package:moven/core/widgets/error_state_view.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';
import 'widgets/cancel_order_dialog.dart';
import 'widgets/order_card.dart';

/// Màn hình danh sách đơn hàng cá nhân của khách hàng (/orders)
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(customerOrdersFilterProvider);
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildContent(context, ref, currentFilter, ordersAsync, isMobile: true),
          tablet: _buildContent(context, ref, currentFilter, ordersAsync, isMobile: false),
          desktop: _buildContent(context, ref, currentFilter, ordersAsync, isMobile: false),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    OrderStatus? currentFilter,
    AsyncValue<dynamic> ordersAsync, {
    required bool isMobile,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.space16 : AppDimensions.space32,
        vertical: AppDimensions.space24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề trang
              Text(
                'Đơn hàng của bạn',
                style: isMobile ? AppTypography.headlineMedium : AppTypography.displayMedium,
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                'Theo dõi tình trạng vận chuyển và lịch sử mua sắm COD tại MOVEN',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 2. Thanh Tab lọc trạng thái động (Filter Tabs)
              _buildFilterTabs(ref, currentFilter),
              const SizedBox(height: AppDimensions.space24),

              // 3. Danh sách đơn hàng với AnimatedSwitcher
              ordersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: AppLoading()),
                ),
                error: (error, _) => ErrorStateView(
                  message: 'Không thể tải danh sách đơn hàng: $error',
                  onRetry: () => ref.invalidate(customerOrdersProvider),
                ),
                data: (ordersList) {
                  final orders = ordersList as List;
                  if (orders.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'Chưa có đơn hàng nào',
                      description: currentFilter == null
                          ? 'Bạn chưa có đơn hàng nào tại MOVEN. Khám phá các thiết kế thời trang tối giản ngay hôm nay!'
                          : 'Không có đơn hàng nào ở trạng thái "${currentFilter.displayName}".',
                      actionLabel: 'Khám phá sản phẩm',
                      onAction: () => context.go(RouteNames.catalogPath),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: ListView.separated(
                      key: ValueKey(currentFilter?.value ?? 'all'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimensions.space16),
                      itemBuilder: (context, index) {
                        final order = orders[index] as Order;
                        return OrderCard(
                          order: order,
                          onCancelPressed: order.status.canCustomerCancel
                              ? () => _handleCancelOrder(context, ref, order)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCancelOrder(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    final reason = await CancelOrderDialog.show(context, order.orderCode);
    if (reason == null || !context.mounted) return;

    final success = await ref
        .read(orderActionControllerProvider.notifier)
        .cancelOrder(orderCode: order.orderCode, reason: reason);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn hàng thành công.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(orderActionControllerProvider).error;
        final message = error is AppException
            ? error.message
            : 'Không thể hủy đơn hàng. Vui lòng thử lại sau.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildFilterTabs(WidgetRef ref, OrderStatus? currentFilter) {
    final filters = [
      (null, 'Tất cả'),
      (OrderStatus.pendingConfirmation, 'Chờ xác nhận'),
      (OrderStatus.shipping, 'Đang giao'),
      (OrderStatus.delivered, 'Đã giao'),
      (OrderStatus.cancelled, 'Đã hủy'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final filterValue = item.$1;
          final title = item.$2;
          final isSelected = currentFilter == filterValue;

          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space8),
            child: InkWell(
              onTap: () {
                ref.read(customerOrdersFilterProvider.notifier).state = filterValue;
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
