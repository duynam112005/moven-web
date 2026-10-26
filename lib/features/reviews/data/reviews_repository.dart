import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moven/features/reviews/domain/models/product_rating_summary.dart';
import 'package:moven/features/reviews/domain/models/review.dart';
import 'package:moven/features/reviews/domain/models/review_eligibility.dart';
import 'package:moven/features/reviews/domain/models/review_report.dart';

/// Repository quản lý toàn diện đánh giá sản phẩm và kiểm duyệt (Customer & Admin)
class ReviewsRepository {
  final SupabaseClient? _client;

  ReviewsRepository([this._client]);

  bool get _isSupabaseConfigured => _client != null;

  // In-memory mock storage for UI preview
  static final List<Review> _mockReviews = [
    Review(
      id: 'rev-001',
      productId: 'prod-001',
      userId: 'usr-001',
      userName: 'Nguyễn Văn An',
      userAvatar: null,
      orderItemId: 'item-001',
      orderCode: 'MVN-8A9F1B2C',
      variantLabel: 'Size L • Màu Đen',
      rating: 5,
      comment: 'Áo phông chất vải cotton 100% cực kỳ thoáng mát, form áo rất chuẩn đẹp!',
      isHidden: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'rev-002',
      productId: 'prod-001',
      userId: 'usr-002',
      userName: 'Trần Thị Bình',
      userAvatar: null,
      orderItemId: 'item-002',
      orderCode: 'MVN-3D4E5F6A',
      variantLabel: 'Size M • Màu Trắng',
      rating: 4,
      comment: 'Giao hàng nhanh, đóng gói cẩn thận. Vải hơi mỏng một chút nhưng mặc mùa hè rất dễ chịu.',
      isHidden: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'rev-003',
      productId: 'prod-001',
      userId: 'usr-003',
      userName: 'Lê Hoàng Cường',
      userAvatar: null,
      orderItemId: 'item-003',
      orderCode: 'MVN-7B8C9D0E',
      variantLabel: 'Size XL • Màu Xanh Navy',
      rating: 5,
      comment: 'Đường may tỉ mỉ, không có chỉ thừa. Sẽ ủng hộ shop thêm nhiều đơn nữa!',
      isHidden: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Review(
      id: 'rev-004',
      productId: 'prod-002',
      userId: 'usr-004',
      userName: 'Phạm Minh Đức',
      userAvatar: null,
      orderItemId: 'item-004',
      orderCode: 'MVN-1A2B3C4D',
      variantLabel: 'Size 32 • Màu Be',
      rating: 5,
      comment: 'Quần vừa vặn, co giãn nhẹ vận động rất thoải mái.',
      isHidden: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'rev-005',
      productId: 'prod-001',
      userId: 'usr-005',
      userName: 'Người dùng vi phạm',
      userAvatar: null,
      orderItemId: 'item-005',
      orderCode: 'MVN-9Z8Y7X6W',
      variantLabel: 'Size S • Màu Đen',
      rating: 1,
      comment: 'Shop lừa đảo quảng cáo rác truy cập website abc.com để nhận voucher 500k',
      isHidden: true,
      hiddenReason: 'Spam đường link quảng cáo ngoài',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static final List<ReviewReport> _mockReports = [
    ReviewReport(
      id: 'rep-001',
      reviewId: 'rev-005',
      reporterId: 'usr-001',
      reporterName: 'Nguyễn Văn An',
      reviewComment: 'Shop lừa đảo quảng cáo rác truy cập website abc.com để nhận voucher 500k',
      reviewRating: 1,
      reviewAuthorName: 'Người dùng vi phạm',
      productId: 'prod-001',
      productName: 'Áo Phông Nam Basic Cotton',
      reason: 'spam',
      details: 'Tài khoản này chèn link website cờ bạc quảng cáo rác.',
      status: 'reviewed',
      resolvedBy: 'admin-001',
      resolutionNote: 'Đã ẩn đánh giá vi phạm',
      resolvedAt: DateTime.now().subtract(const Duration(days: 9)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ReviewReport(
      id: 'rep-002',
      reviewId: 'rev-003',
      reporterId: 'usr-002',
      reporterName: 'Trần Thị Bình',
      reviewComment: 'Đường may tỉ mỉ, không có chỉ thừa. Sẽ ủng hộ shop thêm nhiều đơn nữa!',
      reviewRating: 5,
      reviewAuthorName: 'Lê Hoàng Cường',
      productId: 'prod-001',
      productName: 'Áo Phông Nam Basic Cotton',
      reason: 'other',
      details: 'Báo cáo nhầm, đánh giá tốt.',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // ==========================================
  // CUSTOMER APIs
  // ==========================================

  /// Lấy danh sách đánh giá công khai của sản phẩm (is_hidden = false)
  Future<List<Review>> getProductReviews(String productId) async {
    if (!_isSupabaseConfigured) {
      return _mockReviews
          .where((r) => r.productId == productId && !r.isHidden)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    try {
      final response = await _client!
          .from('reviews')
          .select('''
            id,
            product_id,
            user_id,
            order_item_id,
            rating,
            comment,
            is_hidden,
            hidden_reason,
            created_at,
            updated_at,
            profiles:user_id(full_name, avatar_path),
            order_items:order_item_id(
              order_id,
              size_snapshot,
              color_snapshot,
              orders:order_id(order_code)
            )
          ''')
          .eq('product_id', productId)
          .eq('is_hidden', false)
          .order('created_at', ascending: false);

      final list = (response as List).map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final orderItem = row['order_items'] as Map<String, dynamic>?;
        final order = orderItem?['orders'] as Map<String, dynamic>?;

        final size = orderItem?['size_snapshot'] as String?;
        final color = orderItem?['color_snapshot'] as String?;
        final variantParts = <String>[];
        if (size != null && size.isNotEmpty) variantParts.add('Size $size');
        if (color != null && color.isNotEmpty) variantParts.add('Màu $color');

        return Review(
          id: row['id'] as String,
          productId: row['product_id'] as String,
          userId: row['user_id'] as String,
          userName: (profile?['full_name'] as String?) ?? 'Khách hàng MOVEN',
          userAvatar: profile?['avatar_path'] as String?,
          orderItemId: row['order_item_id'] as String?,
          orderCode: order?['order_code'] as String?,
          variantLabel: variantParts.isEmpty ? null : variantParts.join(' • '),
          rating: row['rating'] as int,
          comment: row['comment'] as String?,
          isHidden: row['is_hidden'] as bool? ?? false,
          hiddenReason: row['hidden_reason'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: row['updated_at'] != null
              ? DateTime.parse(row['updated_at'] as String)
              : null,
        );
      }).toList();

      return list;
    } catch (e) {
      if (kDebugMode) debugPrint('[ReviewsRepository] getProductReviews error: $e');
      return _mockReviews
          .where((r) => r.productId == productId && !r.isHidden)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  /// Lấy thống kê số sao và số lượng đánh giá của sản phẩm
  Future<ProductRatingSummary> getProductRatingSummary(String productId) async {
    if (!_isSupabaseConfigured) {
      final reviews = _mockReviews
          .where((r) => r.productId == productId && !r.isHidden)
          .toList();
      if (reviews.isEmpty) {
        return ProductRatingSummary(productId: productId);
      }
      final counts = <String, int>{'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
      var sum = 0;
      for (final r in reviews) {
        counts['${r.rating}'] = (counts['${r.rating}'] ?? 0) + 1;
        sum += r.rating;
      }
      final avg = double.parse((sum / reviews.length).toStringAsFixed(1));
      return ProductRatingSummary(
        productId: productId,
        totalReviews: reviews.length,
        averageRating: avg,
        counts: counts,
      );
    }

    try {
      final res = await _client!.rpc(
        'get_product_rating_summary',
        params: {'p_product_id': productId},
      );
      final data = res as Map<String, dynamic>;
      final rawCounts = data['counts'] as Map<String, dynamic>? ?? {};
      final counts = <String, int>{};
      rawCounts.forEach((k, v) => counts[k] = (v as num).toInt());

      return ProductRatingSummary(
        productId: productId,
        totalReviews: (data['total_reviews'] as num?)?.toInt() ?? 0,
        averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0.0,
        counts: counts,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[ReviewsRepository] getProductRatingSummary error: $e');
      final reviews = _mockReviews
          .where((r) => r.productId == productId && !r.isHidden)
          .toList();
      if (reviews.isEmpty) {
        return ProductRatingSummary(productId: productId);
      }
      final counts = <String, int>{'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
      var sum = 0;
      for (final r in reviews) {
        counts['${r.rating}'] = (counts['${r.rating}'] ?? 0) + 1;
        sum += r.rating;
      }
      final avg = double.parse((sum / reviews.length).toStringAsFixed(1));
      return ProductRatingSummary(
        productId: productId,
        totalReviews: reviews.length,
        averageRating: avg,
        counts: counts,
      );
    }
  }

  /// Kiểm tra điều kiện viết đánh giá của khách hàng hiện hành
  Future<ReviewEligibility> checkEligibility(String productId) async {
    if (!_isSupabaseConfigured) {
      // Mock mode: Cho phép đánh giá trên sản phẩm prod-001 để test UI
      final hasReviewed = _mockReviews.any(
        (r) => r.productId == productId && r.userId == 'usr-current',
      );
      if (hasReviewed) {
        return const ReviewEligibility(
          isAuthenticated: true,
          isEligible: false,
          hasReviewed: true,
          reason: 'ALREADY_REVIEWED',
          message: 'Bạn đã đánh giá sản phẩm này rồi.',
        );
      }
      return const ReviewEligibility(
        isAuthenticated: true,
        isEligible: true,
        hasReviewed: false,
        reason: 'ELIGIBLE',
        message: 'Bạn đủ điều kiện đánh giá sản phẩm này.',
        orderCode: 'MVN-8A9F1B2C',
        sizeSnapshot: 'L',
        colorSnapshot: 'Đen',
      );
    }

    try {
      final res = await _client!.rpc(
        'check_review_eligibility',
        params: {'p_product_id': productId},
      );
      return ReviewEligibility.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('[ReviewsRepository] checkEligibility error: $e');
      return ReviewEligibility(
        isAuthenticated: false,
        isEligible: false,
        hasReviewed: false,
        reason: 'ERROR',
        message: 'Không thể kiểm tra điều kiện đánh giá: $e',
      );
    }
  }

  /// Khách hàng gửi đánh giá sản phẩm (yêu cầu đơn delivered)
  Future<Map<String, dynamic>> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    if (!_isSupabaseConfigured) {
      final newReview = Review(
        id: 'rev-mock-${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        userId: 'usr-current',
        userName: 'Tôi (Khách hàng)',
        orderCode: 'MVN-8A9F1B2C',
        variantLabel: 'Size L • Màu Đen',
        rating: rating,
        comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
        isHidden: false,
        createdAt: DateTime.now(),
      );
      _mockReviews.insert(0, newReview);
      return {
        'success': true,
        'message': 'Đánh giá của bạn đã được gửi thành công!',
        'review_id': newReview.id,
      };
    }

    final res = await _client!.rpc(
      'submit_product_review',
      params: {
        'p_product_id': productId,
        'p_rating': rating,
        'p_comment': comment,
      },
    );
    return res as Map<String, dynamic>;
  }

  /// Khách hàng báo cáo đánh giá vi phạm
  Future<Map<String, dynamic>> reportReview({
    required String reviewId,
    required String reason,
    String? details,
  }) async {
    if (!_isSupabaseConfigured) {
      final newReport = ReviewReport(
        id: 'rep-mock-${DateTime.now().millisecondsSinceEpoch}',
        reviewId: reviewId,
        reporterId: 'usr-current',
        reporterName: 'Tôi (Người báo cáo)',
        reason: reason,
        details: details,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      _mockReports.insert(0, newReport);
      return {
        'success': true,
        'message': 'Cảm ơn bạn. Báo cáo đã được gửi tới quản trị viên để xem xét.',
      };
    }

    final res = await _client!.rpc(
      'report_product_review',
      params: {
        'p_review_id': reviewId,
        'p_reason': reason,
        'p_details': details,
      },
    );
    return res as Map<String, dynamic>;
  }

  // ==========================================
  // ADMIN APIs
  // ==========================================

  /// Lấy toàn bộ đánh giá cho Admin (kèm tìm kiếm & lọc)
  Future<List<Review>> getAdminReviews({
    String? searchQuery,
    int? ratingFilter,
    bool? isHiddenFilter,
  }) async {
    if (!_isSupabaseConfigured) {
      return _mockReviews.where((r) {
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          final matchComment = r.comment?.toLowerCase().contains(q) ?? false;
          final matchUser = r.userName.toLowerCase().contains(q);
          final matchCode = r.orderCode?.toLowerCase().contains(q) ?? false;
          if (!matchComment && !matchUser && !matchCode) return false;
        }
        if (ratingFilter != null && r.rating != ratingFilter) return false;
        if (isHiddenFilter != null && r.isHidden != isHiddenFilter) return false;
        return true;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    try {
      var query = _client!.from('reviews').select('''
        id,
        product_id,
        user_id,
        order_item_id,
        rating,
        comment,
        is_hidden,
        hidden_reason,
        created_at,
        updated_at,
        profiles:user_id(full_name, avatar_path),
        order_items:order_item_id(
          order_id,
          size_snapshot,
          color_snapshot,
          orders:order_id(order_code)
        )
      ''');

      if (ratingFilter != null) {
        query = query.eq('rating', ratingFilter);
      }
      if (isHiddenFilter != null) {
        query = query.eq('is_hidden', isHiddenFilter);
      }

      final response = await query.order('created_at', ascending: false);

      final list = (response as List).map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final orderItem = row['order_items'] as Map<String, dynamic>?;
        final order = orderItem?['orders'] as Map<String, dynamic>?;

        final size = orderItem?['size_snapshot'] as String?;
        final color = orderItem?['color_snapshot'] as String?;
        final variantParts = <String>[];
        if (size != null && size.isNotEmpty) variantParts.add('Size $size');
        if (color != null && color.isNotEmpty) variantParts.add('Màu $color');

        return Review(
          id: row['id'] as String,
          productId: row['product_id'] as String,
          userId: row['user_id'] as String,
          userName: (profile?['full_name'] as String?) ?? 'Khách hàng MOVEN',
          userAvatar: profile?['avatar_path'] as String?,
          orderItemId: row['order_item_id'] as String?,
          orderCode: order?['order_code'] as String?,
          variantLabel: variantParts.isEmpty ? null : variantParts.join(' • '),
          rating: row['rating'] as int,
          comment: row['comment'] as String?,
          isHidden: row['is_hidden'] as bool? ?? false,
          hiddenReason: row['hidden_reason'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: row['updated_at'] != null
              ? DateTime.parse(row['updated_at'] as String)
              : null,
        );
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return list.where((r) {
          final matchComment = r.comment?.toLowerCase().contains(q) ?? false;
          final matchUser = r.userName.toLowerCase().contains(q);
          final matchCode = r.orderCode?.toLowerCase().contains(q) ?? false;
          return matchComment || matchUser || matchCode;
        }).toList();
      }

      return list;
    } catch (e) {
      if (kDebugMode) debugPrint('[ReviewsRepository] getAdminReviews error: $e');
      return _mockReviews;
    }
  }

  /// Lấy danh sách báo cáo đánh giá cho Admin
  Future<List<ReviewReport>> getAdminReports({String? statusFilter}) async {
    if (!_isSupabaseConfigured) {
      return _mockReports.where((r) {
        if (statusFilter != null && statusFilter.isNotEmpty && r.status != statusFilter) {
          return false;
        }
        return true;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    try {
      var query = _client!.from('review_reports').select('''
        id,
        review_id,
        reporter_id,
        reason,
        details,
        status,
        resolved_by,
        resolution_note,
        resolved_at,
        created_at,
        profiles:reporter_id(full_name),
        reviews:review_id(
          rating,
          comment,
          user_id,
          product_id,
          profiles:user_id(full_name),
          products:product_id(name)
        )
      ''');

      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.eq('status', statusFilter);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((row) {
        final reporter = row['profiles'] as Map<String, dynamic>?;
        final review = row['reviews'] as Map<String, dynamic>?;
        final author = review?['profiles'] as Map<String, dynamic>?;
        final product = review?['products'] as Map<String, dynamic>?;

        return ReviewReport(
          id: row['id'] as String,
          reviewId: row['review_id'] as String,
          reporterId: row['reporter_id'] as String,
          reporterName: (reporter?['full_name'] as String?) ?? 'Người dùng',
          reviewComment: review?['comment'] as String?,
          reviewRating: review?['rating'] as int?,
          reviewAuthorName: (author?['full_name'] as String?) ?? 'Tác giả đánh giá',
          productId: review?['product_id'] as String?,
          productName: product?['name'] as String?,
          reason: row['reason'] as String,
          details: row['details'] as String?,
          status: row['status'] as String? ?? 'pending',
          resolvedBy: row['resolved_by'] as String?,
          resolutionNote: row['resolution_note'] as String?,
          resolvedAt: row['resolved_at'] != null
              ? DateTime.parse(row['resolved_at'] as String)
              : null,
          createdAt: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[ReviewsRepository] getAdminReports error: $e');
      return _mockReports;
    }
  }

  /// Admin kiểm duyệt đánh giá: ẩn / khôi phục / bác bỏ báo cáo
  Future<Map<String, dynamic>> adminModerateReview({
    required String reviewId,
    required String action,
    String? reason,
    String? reportId,
  }) async {
    if (!_isSupabaseConfigured) {
      final index = _mockReviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final existing = _mockReviews[index];
        if (action == 'hide') {
          _mockReviews[index] = existing.copyWith(
            isHidden: true,
            hiddenReason: reason ?? 'Quản trị viên ẩn',
          );
        } else if (action == 'unhide') {
          _mockReviews[index] = existing.copyWith(
            isHidden: false,
            hiddenReason: null,
          );
        }
      }

      // Update related report
      if (reportId != null) {
        final repIndex = _mockReports.indexWhere((rep) => rep.id == reportId);
        if (repIndex != -1) {
          _mockReports[repIndex] = _mockReports[repIndex].copyWith(
            status: action == 'hide' ? 'reviewed' : 'dismissed',
            resolutionNote: reason,
            resolvedAt: DateTime.now(),
          );
        }
      }

      return {
        'success': true,
        'message': 'Đã xử lý kiểm duyệt đánh giá thành công.',
      };
    }

    final res = await _client!.rpc(
      'admin_moderate_review',
      params: {
        'p_review_id': reviewId,
        'p_action': action,
        'p_reason': reason,
        'p_report_id': reportId,
      },
    );
    return res as Map<String, dynamic>;
  }
}
