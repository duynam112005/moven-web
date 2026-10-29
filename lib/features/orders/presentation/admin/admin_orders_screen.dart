import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/core/utils/responsive_layout.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/core/widgets/empty_state_view.dart';
import 'package:moven/core/widgets/error_state_view.dart';
import 'package:moven/features/orders/domain/models/order.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/customer/widgets/order_status_badge.dart';
import 'package:moven/features/orders/presentation/providers/orders_providers.dart';
import 'widgets/admin_order_detail_dialog.dart';
import 'widgets/admin_order_status_dialog.dart';

/// Màn hình Quản lý Đơn hàng & Vận chuyển cho Admin (/admin/orders)
class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(adminOrdersFilterProvider);
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildBody(context, currentFilter, ordersAsync, isMobile: true),
        tablet: _buildBody(context, currentFilter, ordersAsync, isMobile: false),
        desktop: _buildBody(context, currentFilter, ordersAsync, isMobile: false),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderStatus? currentFilter,
    AsyncValue<List<Order>> ordersAsync, {
    required bool isMobile,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppDimensions.space16 : AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Đơn hàng & Giao vận',
                    style: isMobile
                        ? AppTypography.headlineMedium
                        : AppTypography.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cập nhật trạng thái thủ công: shipping, delivery_failed, delivered, returned.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => ref.invalidate(adminOrdersProvider),
                tooltip: 'Làm mới',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space20),

          // 2. Search Bar & Status Filter Tabs
          _buildSearchAndFilters(currentFilter),
          const SizedBox(height: AppDimensions.space20),

          // 3. Orders List / Table
          ordersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: AppLoading()),
            ),
            error: (error, _) => ErrorStateView(
              message: 'Lỗi tải danh sách đơn hàng: $error',
              onRetry: () => ref.invalidate(adminOrdersProvider),
            ),
            data: (orders) {
              if (orders.isEmpty) {
                return EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'Không tìm thấy đơn hàng nào',
                  description:
                      'Không có đơn hàng nào phù hợp với bộ lọc hoặc từ khóa tìm kiếm hiện tại.',
                );
              }

              return isMobile
                  ? _buildMobileCardsList(orders)
                  : _buildDesktopTable(orders);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(OrderStatus? currentFilter) {
    final filters = [
      (null, 'Tất cả'),
      (OrderStatus.pendingConfirmation, 'Chờ xác nhận'),
      (OrderStatus.shipping, 'Đang giao'),
      (OrderStatus.delivered, 'Giao thành công'),
      (OrderStatus.deliveryFailed, 'Giao thất bại'),
      (OrderStatus.returned, 'Đã hoàn về kho'),
      (OrderStatus.cancelled, 'Đã hủy'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              ref.read(adminOrdersSearchQueryProvider.notifier).state = val;
            },
            decoration: InputDecoration(
              hintText: 'Tìm theo mã đơn (MVN-...) hoặc SĐT...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(adminOrdersSearchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space16),

        // Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((item) {
              final filterValue = item.$1;
              final label = item.$2;
              final isSelected = currentFilter == filterValue;

              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.space8),
                child: InkWell(
                  onTap: () {
                    ref.read(adminOrdersFilterProvider.notifier).state = filterValue;
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
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
                      label,
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
        ),
      ],
    );
  }

  Widget _buildDesktopTable(List<Order> orders) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1000),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.4), // Mã đơn
              1: FlexColumnWidth(1.8), // Khách hàng
              2: FlexColumnWidth(1.2), // Ngày tạo
              3: FlexColumnWidth(1.3), // Tổng COD
              4: FlexColumnWidth(1.8), // Trạng thái
              5: FlexColumnWidth(1.5), // Tiền COD
              6: FlexColumnWidth(2.0), // Hành động
            },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header Row
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius12)),
            ),
            children: [
              _buildHeaderCell('Mã đơn'),
              _buildHeaderCell('Khách hàng'),
              _buildHeaderCell('Ngày đặt'),
              _buildHeaderCell('Tổng thu COD'),
              _buildHeaderCell('Trạng thái'),
              _buildHeaderCell('Tiền COD'),
              _buildHeaderCell('Hành động nhanh'),
            ],
          ),

          // Data Rows
          ...orders.map((order) {
            final dateStr = DateFormat('dd/MM HH:mm').format(order.createdAt);
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              children: [
                // 1. Mã đơn & Phương thức thanh toán
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.orderCode,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isQrPayment
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: order.isQrPayment
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          order.paymentMethodDisplayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: order.isQrPayment
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Khách hàng & SĐT
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.recipientName,
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        order.recipientPhone,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Ngày đặt
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Text(
                    dateStr,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ),

                // 4. Tổng tiền COD
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // 5. Trạng thái vận chuyển
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: OrderStatusBadge(status: order.status),
                ),

                // 6. Trạng thái thu tiền COD (ADR-0002)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: AppDimensions.space12,
                  ),
                  child: InkWell(
                    onTap: () async {
                      final newPayment = order.isPaid ? 'unpaid' : 'paid';
                      await ref
                          .read(orderActionControllerProvider.notifier)
                          .adminUpdatePayment(
                            orderId: order.id,
                            orderCode: order.orderCode,
                            paymentStatus: newPayment,
                            note: 'Admin chuyển sang $newPayment',
                          );
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: order.isPaid
                            ? AppColors.success.withValues(alpha: 0.15)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                        border: Border.all(
                          color: order.isPaid
                              ? AppColors.success.withValues(alpha: 0.3)
                              : const Color(0xFFD97706).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.isPaid ? Icons.check : Icons.access_time,
                            size: 11,
                            color: order.isPaid ? AppColors.success : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              order.isPaid ? 'Đã nộp' : 'Chưa thu',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: order.isPaid ? AppColors.success : const Color(0xFFB45309),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 7. Hành động nhanh
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space8),
                  child: _buildQuickActions(order),
                ),
              ],
            );
          }),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space12,
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildQuickActions(Order order) {
    final status = order.status;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Action Button
        if (status == OrderStatus.pendingConfirmation)
          IconButton(
            tooltip: 'Giao cho shipper',
            icon: const Icon(Icons.local_shipping, size: 18, color: AppColors.info),
            onPressed: () => AdminOrderStatusDialog.show(context, order),
          )
        else if (status == OrderStatus.shipping)
          IconButton(
            tooltip: 'Cập nhật kết quả phát hàng',
            icon: const Icon(Icons.assignment_turned_in, size: 18, color: AppColors.success),
            onPressed: () => AdminOrderStatusDialog.show(context, order),
          )
        else if (status == OrderStatus.deliveryFailed)
          IconButton(
            tooltip: 'Giao lại hoặc Nhận hàng hoàn kho',
            icon: const Icon(Icons.assignment_return, size: 18, color: Color(0xFF7E22CE)),
            onPressed: () => AdminOrderStatusDialog.show(context, order),
          ),

        // Detail View Button
        IconButton(
          tooltip: 'Xem toàn bộ chi tiết',
          icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
          onPressed: () => AdminOrderDetailDialog.show(context, order),
        ),
      ],
    );
  }

  Widget _buildMobileCardsList(List<Order> orders) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt);

        return Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
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
                  Row(
                    children: [
                      Text(
                        order.orderCode,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isQrPayment
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.paymentMethodDisplayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: order.isQrPayment
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Khách: ${order.recipientName} • ${order.recipientPhone}',
                style: AppTypography.bodySmall,
              ),
              Text(
                'Ngày: $dateStr',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const Divider(color: AppColors.border, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng COD: ${CurrencyFormatter.format(order.totalAmount)}',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        order.isPaid ? 'Đã thu tiền COD' : 'Chưa thu tiền COD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: order.isPaid ? AppColors.success : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (order.status.validNextStatusesAdmin.isNotEmpty)
                        OutlinedButton(
                          onPressed: () => AdminOrderStatusDialog.show(context, order),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: const Text('Đổi trạng thái', style: TextStyle(fontSize: 12)),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => AdminOrderDetailDialog.show(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Chi tiết', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
