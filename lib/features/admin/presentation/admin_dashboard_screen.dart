import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/core/widgets/error_state_view.dart';
import 'package:moven/features/admin/domain/models/dashboard_metrics.dart';
import 'package:moven/features/admin/presentation/providers/dashboard_providers.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';
import 'package:moven/features/orders/presentation/customer/widgets/order_status_badge.dart';

/// Màn hình Tổng quan Dashboard Quản trị MOVEN (Động theo ADR-0005)
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(dashboardDateRangeProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Range Filter Chips
          _buildHeader(context, ref, range),

          const SizedBox(height: AppDimensions.space24),

          // 2. Metrics Async Body
          metricsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.space48),
                child: AppLoading(message: 'Đang tải số liệu thống kê Dashboard...'),
              ),
            ),
            error: (err, _) => ErrorStateView(
              title: 'Không thể tải Dashboard',
              message: err.toString(),
              onRetry: () => ref.refresh(dashboardMetricsProvider),
            ),
            data: (metrics) => _buildDashboardContent(context, metrics),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    DashboardDateRange selectedRange,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tổng quan kinh doanh',
                  style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppDimensions.space8),
                IconButton(
                  tooltip: 'Làm mới số liệu',
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => ref.invalidate(dashboardMetricsProvider),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space4),
            Text(
              'Doanh thu tính từ đơn đã giao thành công (delivered). Múi giờ Việt Nam.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );

        Widget buildRangeButtons() {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: DashboardDateRange.values.map((r) {
              final isSelected = r == selectedRange;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () {
                    ref.read(dashboardDateRangeProvider.notifier).state = r;
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleCol,
              const SizedBox(height: AppDimensions.space16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: buildRangeButtons(),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleCol),
            const SizedBox(width: AppDimensions.space16),
            buildRangeButtons(),
          ],
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 KPI Summary Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 900;
            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildRevenueCard(metrics)),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(child: _buildPendingCard(metrics)),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: [
                      Expanded(child: _buildShippingCard(metrics)),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(child: _buildLowStockCard(metrics)),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildRevenueCard(metrics)),
                const SizedBox(width: AppDimensions.space16),
                Expanded(child: _buildPendingCard(metrics)),
                const SizedBox(width: AppDimensions.space16),
                Expanded(child: _buildShippingCard(metrics)),
                const SizedBox(width: AppDimensions.space16),
                Expanded(child: _buildLowStockCard(metrics)),
              ],
            );
          },
        ),

        const SizedBox(height: AppDimensions.space32),

        // Middle Section: Status breakdown & Best Sellers
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildStatusBreakdownCard(metrics)),
                  const SizedBox(width: AppDimensions.space24),
                  Expanded(flex: 6, child: _buildBestSellersCard(metrics)),
                ],
              );
            }

            return Column(
              children: [
                _buildStatusBreakdownCard(metrics),
                const SizedBox(height: AppDimensions.space24),
                _buildBestSellersCard(metrics),
              ],
            );
          },
        ),

        const SizedBox(height: AppDimensions.space32),

        // Low Stock Alert Table
        _buildLowStockTableCard(metrics),

        const SizedBox(height: AppDimensions.space32),

        // Recent Orders Table
        _buildRecentOrdersCard(context, metrics),
      ],
    );
  }

  // ==========================================
  // KPI METRICS CARDS
  // ==========================================

  Widget _buildRevenueCard(DashboardMetrics metrics) {
    return _buildMetricCard(
      title: 'Doanh thu giao thành công',
      value: CurrencyFormatter.format(metrics.deliveredRevenue),
      subtitle: 'Chỉ tính đơn delivered',
      icon: Icons.monetization_on_outlined,
      color: AppColors.success,
    );
  }

  Widget _buildPendingCard(DashboardMetrics metrics) {
    return _buildMetricCard(
      title: 'Đơn chờ duyệt',
      value: '${metrics.pendingConfirmationCount}',
      subtitle: 'Cần xác nhận giao',
      icon: Icons.pending_actions_outlined,
      color: AppColors.warning,
    );
  }

  Widget _buildShippingCard(DashboardMetrics metrics) {
    return _buildMetricCard(
      title: 'Đang vận chuyển',
      value: '${metrics.shippingCount}',
      subtitle: 'Đang giao tới khách',
      icon: Icons.local_shipping_outlined,
      color: AppColors.info,
    );
  }

  Widget _buildLowStockCard(DashboardMetrics metrics) {
    return _buildMetricCard(
      title: 'Cảnh báo tồn kho',
      value: '${metrics.lowStockCount}',
      subtitle: 'Tồn kho ≤ ${metrics.lowStockThreshold}',
      icon: Icons.warning_amber_outlined,
      color: AppColors.error,
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
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
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

  // ==========================================
  // STATUS BREAKDOWN & BEST SELLERS
  // ==========================================

  Widget _buildStatusBreakdownCard(DashboardMetrics metrics) {
    final totalOrders = metrics.statusCounts.values.fold<int>(0, (sum, c) => sum + c);

    final statuses = [
      {'key': 'pending_confirmation', 'name': 'Chờ xác nhận', 'color': AppColors.warning},
      {'key': 'confirmed', 'name': 'Đã xác nhận', 'color': AppColors.info},
      {'key': 'preparing', 'name': 'Đang chuẩn bị', 'color': const Color(0xFF6366F1)},
      {'key': 'shipping', 'name': 'Đang vận chuyển', 'color': AppColors.info},
      {'key': 'delivered', 'name': 'Giao thành công', 'color': AppColors.success},
      {'key': 'delivery_failed', 'name': 'Giao thất bại', 'color': AppColors.error},
      {'key': 'cancelled', 'name': 'Đã hủy', 'color': AppColors.textMuted},
      {'key': 'returned', 'name': 'Đã nhận lại hàng', 'color': const Color(0xFF9333EA)},
    ];

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
                'Phân bổ đơn hàng',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Tổng: $totalOrders đơn',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          ...statuses.map((item) {
            final key = item['key'] as String;
            final name = item['name'] as String;
            final color = item['color'] as Color;
            final count = metrics.statusCounts[key] ?? 0;
            final pct = totalOrders > 0 ? (count / totalOrders) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 125,
                    child: Text(
                      name,
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBestSellersCard(DashboardMetrics metrics) {
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
                'Top sản phẩm bán chạy',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Từ đơn delivered',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          if (metrics.bestSellers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có dữ liệu bán chạy trong kỳ.')),
            )
          else
            ...metrics.bestSellers.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? const Color(0xFFF59E0B)
                            : (index == 1
                                ? const Color(0xFF9CA3AF)
                                : (index == 2
                                    ? const Color(0xFFD97706)
                                    : AppColors.surfaceVariant)),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: index < 3 ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),

                    // Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Doanh thu: ${CurrencyFormatter.format(item.totalRevenue)}',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity sold
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                      ),
                      child: Text(
                        'Đã bán: ${item.totalSold}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // LOW STOCK ALERT TABLE
  // ==========================================

  Widget _buildLowStockTableCard(DashboardMetrics metrics) {
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
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Cảnh báo tồn kho thấp (Tồn kho ≤ ${metrics.lowStockThreshold})',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${metrics.lowStockVariants.length} biến thể cần nhập kho',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          if (metrics.lowStockVariants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Tất cả sản phẩm đều đảm bảo lượng tồn kho an toàn.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 700),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.4), // SKU
                    1: FlexColumnWidth(2.5), // Tên sản phẩm
                    2: FlexColumnWidth(1.2), // Phân loại (Size / Màu)
                    3: FlexColumnWidth(1.2), // Tồn kho
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      children: [
                        _buildCell('Mã SKU', isHeader: true),
                        _buildCell('Sản phẩm', isHeader: true),
                        _buildCell('Phân loại', isHeader: true),
                        _buildCell('Tồn kho', isHeader: true),
                      ],
                    ),
                    ...metrics.lowStockVariants.map((item) {
                      final isOutOfStock = item.stockQuantity == 0;
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                        ),
                        children: [
                          _buildCell(item.sku),
                          _buildCell(item.productName),
                          _buildCell('Size ${item.size} • ${item.colorName}'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isOutOfStock
                                      ? AppColors.error.withValues(alpha: 0.1)
                                      : AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                                  border: Border.all(
                                    color: isOutOfStock
                                        ? AppColors.error.withValues(alpha: 0.3)
                                        : AppColors.warning.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  isOutOfStock ? 'Hết hàng (0)' : 'Còn ${item.stockQuantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isOutOfStock ? AppColors.error : AppColors.warning,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // RECENT ORDERS TABLE
  // ==========================================

  Widget _buildRecentOrdersCard(BuildContext context, DashboardMetrics metrics) {
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
                'Đơn hàng gần đây',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => context.goNamed(RouteNames.adminOrders),
                child: const Text('Xem tất cả đơn hàng →'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          if (metrics.recentOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có đơn hàng nào.')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 750),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.4), // Mã đơn
                    1: FlexColumnWidth(1.8), // Khách nhận
                    2: FlexColumnWidth(1.4), // Tổng tiền
                    3: FlexColumnWidth(1.6), // Trạng thái
                    4: FlexColumnWidth(1.4), // Thời gian
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      children: [
                        _buildCell('Mã đơn hàng', isHeader: true),
                        _buildCell('Người nhận', isHeader: true),
                        _buildCell('Tổng thu COD', isHeader: true),
                        _buildCell('Trạng thái', isHeader: true),
                        _buildCell('Thời gian đặt', isHeader: true),
                      ],
                    ),
                    ...metrics.recentOrders.map((ord) {
                      final dateStr = DateFormat('dd/MM HH:mm').format(ord.createdAt);
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                        ),
                        children: [
                          _buildCell(ord.orderCode),
                          _buildCell(ord.recipientName),
                          _buildCell(CurrencyFormatter.format(ord.totalAmount)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: OrderStatusBadge(
                                status: OrderStatus.fromString(ord.status),
                              ),
                            ),
                          ),
                          _buildCell(dateStr),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        style: isHeader
            ? AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              )
            : AppTypography.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
