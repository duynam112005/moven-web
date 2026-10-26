import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/widgets/app_button.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/core/widgets/empty_state_view.dart';
import 'package:moven/features/reviews/domain/models/review.dart';
import 'package:moven/features/reviews/domain/models/review_report.dart';
import 'package:moven/features/reviews/presentation/providers/reviews_providers.dart';
import 'package:moven/features/reviews/presentation/widgets/rating_stars.dart';

/// Màn hình Quản trị Kiểm duyệt Đánh giá & Báo cáo vi phạm của Admin
class AdminReviewsScreen extends ConsumerStatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  ConsumerState<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends ConsumerState<AdminReviewsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          _buildHeader(),

          const SizedBox(height: AppDimensions.space20),

          // 2. Tab Bar (Báo cáo vi phạm / Tất cả đánh giá)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.onPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Báo cáo vi phạm'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Tất cả đánh giá'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // 3. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kiểm duyệt Đánh giá & Báo cáo',
          style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Xử lý phản ánh từ khách hàng và quản lý nội dung đánh giá công khai.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: BÁO CÁO VI PHẠM (REPORTS)
  // ==========================================

  Widget _buildReportsTab() {
    final statusFilter = ref.watch(adminReportsStatusFilterProvider);
    final reportsAsync = ref.watch(adminReportsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildReportFilterChip('pending', 'Chờ xử lý', statusFilter == 'pending'),
              const SizedBox(width: 8),
              _buildReportFilterChip('reviewed', 'Đã xử lý (Ẩn)', statusFilter == 'reviewed'),
              const SizedBox(width: 8),
              _buildReportFilterChip('dismissed', 'Đã bỏ qua', statusFilter == 'dismissed'),
              const SizedBox(width: 8),
              _buildReportFilterChip('all', 'Tất cả báo cáo', statusFilter == 'all'),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.space16),

        // Reports list
        Expanded(
          child: reportsAsync.when(
            loading: () => const Center(
              child: AppLoading(message: 'Đang tải danh sách báo cáo vi phạm...'),
            ),
            error: (err, _) => Center(
              child: Text(
                'Lỗi khi tải báo cáo: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (reports) {
              if (reports.isEmpty) {
                return Center(
                  child: EmptyStateView(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Không có báo cáo nào',
                    description: statusFilter == 'pending'
                        ? 'Tất cả báo cáo vi phạm đã được xử lý xong!'
                        : 'Không có báo cáo nào phù hợp với bộ lọc.',
                  ),
                );
              }

              return ListView.separated(
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildReportCard(reports[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportFilterChip(String value, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        ref.read(adminReportsStatusFilterProvider.notifier).state = value;
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(ReviewReport report) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt);

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
          // Header: Status badge, Reason, Date
          Row(
            children: [
              // Reason badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      report.reasonDisplayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: report.isPending
                      ? const Color(0xFFFEF3C7)
                      : (report.status == 'reviewed'
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.border),
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                ),
                child: Text(
                  report.statusDisplayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: report.isPending
                        ? const Color(0xFFB45309)
                        : (report.status == 'reviewed'
                            ? AppColors.error
                            : AppColors.textSecondary),
                  ),
                ),
              ),

              const Spacer(),
              Text(
                dateStr,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space12),

          // Reporter & Details
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Người báo cáo: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: report.reporterName),
              ],
            ),
            style: AppTypography.bodyMedium,
          ),

          if (report.details != null && report.details!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ghi chú báo cáo: "${report.details}"',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.space12),

          // Target Review Quote Box
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Đánh giá bị báo cáo: ',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      report.reviewAuthorName ?? 'Tác giả',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    if (report.reviewRating != null)
                      RatingStars.small(rating: report.reviewRating!.toDouble()),
                  ],
                ),
                if (report.productName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Sản phẩm: ${report.productName}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  report.reviewComment != null && report.reviewComment!.isNotEmpty
                      ? report.reviewComment!
                      : '(Đánh giá không kèm nhận xét bằng chữ)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons (Only for Pending reports)
          if (report.isPending) ...[
            const SizedBox(height: AppDimensions.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Bác bỏ báo cáo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    ),
                  ),
                  onPressed: () => _handleDismissReport(report),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility_off_outlined, size: 16),
                  label: const Text('Ẩn đánh giá này'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    ),
                  ),
                  onPressed: () => _handleHideReportedReview(report),
                ),
              ],
            ),
          ] else if (report.resolutionNote != null) ...[
            const SizedBox(height: 8),
            Text(
              'Kết quả xử lý: ${report.resolutionNote}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleDismissReport(ReviewReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bác bỏ báo cáo này?'),
        content: const Text(
          'Đánh giá sẽ tiếp tục hiển thị công khai bình thường. Báo cáo sẽ được chuyển sang trạng thái "Đã bỏ qua".',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận bỏ qua'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(reviewActionControllerProvider.notifier).adminModerate(
            reviewId: report.reviewId,
            action: 'dismiss',
            reportId: report.id,
            reason: 'Quản trị viên xác nhận báo cáo không có căn cứ',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.info,
            content: Text('Đã bỏ qua báo cáo.'),
          ),
        );
      }
    }
  }

  Future<void> _handleHideReportedReview(ReviewReport report) async {
    final reasonController = TextEditingController(
      text: 'Vi phạm: ${report.reasonDisplayName}',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ẩn đánh giá vi phạm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá này sẽ bị ẩn khỏi trang sản phẩm và không được tính vào điểm sao trung bình.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do ẩn (bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận ẩn'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) return;

      await ref.read(reviewActionControllerProvider.notifier).adminModerate(
            reviewId: report.reviewId,
            action: 'hide',
            reportId: report.id,
            reason: reason,
            productId: report.productId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Đã ẩn đánh giá và hoàn tất báo cáo.'),
          ),
        );
      }
    }
  }

  // ==========================================
  // TAB 2: TẤT CẢ ĐÁNH GIÁ (REVIEWS)
  // ==========================================

  Widget _buildReviewsTab() {
    final reviewsAsync = ref.watch(adminReviewsProvider);
    final filter = ref.watch(adminReviewsFilterProvider);

    return Column(
      children: [
        // Search & Filters bar
        _buildReviewsFilterBar(filter),

        const SizedBox(height: AppDimensions.space16),

        // Reviews Data Table
        Expanded(
          child: reviewsAsync.when(
            loading: () => const Center(
              child: AppLoading(message: 'Đang tải danh sách đánh giá...'),
            ),
            error: (err, _) => Center(
              child: Text(
                'Lỗi khi tải đánh giá: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (reviews) {
              if (reviews.isEmpty) {
                return Center(
                  child: EmptyStateView(
                    icon: Icons.rate_review_outlined,
                    title: 'Không tìm thấy đánh giá',
                    description: 'Thử điều chỉnh từ khóa tìm kiếm hoặc bộ lọc sao/trạng thái.',
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1000),
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.6), // Khách hàng & Mã đơn
                          1: FlexColumnWidth(1.4), // Biến thể
                          2: FlexColumnWidth(1.4), // Số sao
                          3: FlexColumnWidth(2.6), // Nội dung nhận xét
                          4: FlexColumnWidth(1.2), // Ngày tạo
                          5: FlexColumnWidth(1.4), // Trạng thái
                          6: FlexColumnWidth(1.2), // Thao tác
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          // Table Header
                          TableRow(
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(AppDimensions.radius12),
                              ),
                            ),
                            children: [
                              _buildTableHeaderCell('Khách hàng & Mã đơn'),
                              _buildTableHeaderCell('Biến thể đã mua'),
                              _buildTableHeaderCell('Số sao'),
                              _buildTableHeaderCell('Nội dung nhận xét'),
                              _buildTableHeaderCell('Ngày gửi'),
                              _buildTableHeaderCell('Trạng thái'),
                              _buildTableHeaderCell('Thao tác'),
                            ],
                          ),

                          // Table Rows
                          ...reviews.map((review) => _buildReviewTableRow(review)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsFilterBar(AdminReviewsFilterState filter) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo khách hàng, mã đơn, nội dung...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onSubmitted: (val) {
                ref.read(adminReviewsFilterProvider.notifier).update(
                      (s) => s.copyWith(searchQuery: val.trim()),
                    );
              },
            ),
          ),
          const SizedBox(width: AppDimensions.space12),

          // Rating filter
          DropdownButton<int?>(
            value: filter.ratingFilter,
            hint: const Text('Tất cả sao', style: TextStyle(fontSize: 13)),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tất cả sao')),
              ...[5, 4, 3, 2, 1].map(
                (star) => DropdownMenuItem(
                  value: star,
                  child: Text('$star sao', style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
            onChanged: (val) {
              ref.read(adminReviewsFilterProvider.notifier).update(
                    (s) => s.copyWith(ratingFilter: () => val),
                  );
            },
          ),
          const SizedBox(width: AppDimensions.space12),

          // Hidden status filter
          DropdownButton<bool?>(
            value: filter.isHiddenFilter,
            hint: const Text('Trạng thái', style: TextStyle(fontSize: 13)),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
              DropdownMenuItem(value: false, child: Text('Đang hiển thị')),
              DropdownMenuItem(value: true, child: Text('Đang ẩn')),
            ],
            onChanged: (val) {
              ref.read(adminReviewsFilterProvider.notifier).update(
                    (s) => s.copyWith(isHiddenFilter: () => val),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
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

  TableRow _buildReviewTableRow(Review review) {
    final dateStr = DateFormat('dd/MM/yyyy').format(review.createdAt);

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      children: [
        // 1. Khách hàng & Mã đơn
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              if (review.orderCode != null)
                Text(
                  review.orderCode!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
            ],
          ),
        ),

        // 2. Biến thể
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Text(
            review.variantLabel ?? 'Mặc định',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),

        // 3. Số sao
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: AppDimensions.space12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingStars.small(rating: review.rating.toDouble()),
                const SizedBox(width: 4),
                Text(
                  '${review.rating}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        // 4. Nhận xét
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.hasComment ? review.comment! : '(Không có nhận xét bằng chữ)',
                style: AppTypography.bodyMedium.copyWith(
                  color: review.hasComment ? AppColors.textPrimary : AppColors.textMuted,
                  fontStyle: review.hasComment ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (review.isHidden && review.hiddenReason != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Lý do ẩn: ${review.hiddenReason}',
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ],
            ],
          ),
        ),

        // 5. Ngày tạo
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Text(dateStr, style: AppTypography.bodySmall),
        ),

        // 6. Trạng thái
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: review.isHidden
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              border: Border.all(
                color: review.isHidden
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              review.isHidden ? 'Đang ẩn' : 'Hiển thị',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: review.isHidden ? AppColors.error : AppColors.success,
              ),
            ),
          ),
        ),

        // 7. Thao tác Toggle
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: review.isHidden
              ? OutlinedButton(
                  onPressed: () => _handleToggleReviewVisibility(review, isHiding: false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Khôi phục', style: TextStyle(fontSize: 12)),
                )
              : OutlinedButton(
                  onPressed: () => _handleToggleReviewVisibility(review, isHiding: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Ẩn', style: TextStyle(fontSize: 12)),
                ),
        ),
      ],
    );
  }

  Future<void> _handleToggleReviewVisibility(Review review, {required bool isHiding}) async {
    if (isHiding) {
      final reasonController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ẩn đánh giá này?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vui lòng nhập lý do ẩn đánh giá để lưu vào lịch sử kiểm duyệt:'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do ẩn (bắt buộc)',
                  hintText: 'Ví dụ: Ngôn từ phản cảm, spam...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xác nhận ẩn'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        final reason = reasonController.text.trim();
        if (reason.isEmpty) return;

        await ref.read(reviewActionControllerProvider.notifier).adminModerate(
              reviewId: review.id,
              action: 'hide',
              reason: reason,
              productId: review.productId,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Đã ẩn đánh giá.'),
            ),
          );
        }
      }
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Khôi phục hiển thị đánh giá?'),
          content: const Text(
            'Đánh giá này sẽ được hiển thị công khai trở lại trên trang sản phẩm và tiếp tục tính vào điểm sao trung bình.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xác nhận khôi phục'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        await ref.read(reviewActionControllerProvider.notifier).adminModerate(
              reviewId: review.id,
              action: 'unhide',
              productId: review.productId,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Đã khôi phục hiển thị đánh giá.'),
            ),
          );
        }
      }
    }
  }
}
