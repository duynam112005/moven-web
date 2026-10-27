import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_report.freezed.dart';
part 'review_report.g.dart';

/// Thực thể Báo cáo đánh giá vi phạm trong MOVEN (Freezed)
@freezed
class ReviewReport with _$ReviewReport {
  const ReviewReport._();

  const factory ReviewReport({
    required String id,
    @JsonKey(name: 'review_id') required String reviewId,
    @JsonKey(name: 'reporter_id') required String reporterId,
    @JsonKey(name: 'reporter_name') @Default('Người dùng') String reporterName,
    @JsonKey(name: 'review_comment') String? reviewComment,
    @JsonKey(name: 'review_rating') int? reviewRating,
    @JsonKey(name: 'review_author_name') String? reviewAuthorName,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_name') String? productName,
    required String reason,
    String? details,
    @Default('pending') String status,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'resolution_note') String? resolutionNote,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ReviewReport;

  factory ReviewReport.fromJson(Map<String, dynamic> json) =>
      _$ReviewReportFromJson(json);

  /// Nhãn hiển thị tiếng Việt của lý do báo cáo
  String get reasonDisplayName {
    switch (reason) {
      case 'spam':
        return 'Spam / Quảng cáo';
      case 'inappropriate':
        return 'Ngôn từ phản cảm / Thô tục';
      case 'fake':
        return 'Nội dung sai sự thật / Đánh giá giả';
      case 'other':
      default:
        return 'Lý do khác';
    }
  }

  /// Nhãn hiển thị trạng thái xử lý
  String get statusDisplayName {
    switch (status) {
      case 'reviewed':
        return 'Đã xử lý (Đã ẩn)';
      case 'dismissed':
        return 'Đã bỏ qua';
      case 'pending':
      default:
        return 'Chờ xử lý';
    }
  }

  bool get isPending => status == 'pending';
}
