import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result.freezed.dart';

/// Generic model bọc kết quả phân trang
@Freezed(genericArgumentFactories: true)
class PaginatedResult<T> with _$PaginatedResult<T> {
  const PaginatedResult._();

  const factory PaginatedResult({
    required List<T> items,
    required int totalCount,
    required int page,
    required int pageSize,
  }) = _PaginatedResult<T>;

  /// Tổng số trang
  int get totalPages => (totalCount / pageSize).ceil();

  /// Có trang kế tiếp hay không
  bool get hasMore => page * pageSize < totalCount;

  /// Có trang trước hay không
  bool get hasPrevious => page > 1;
}
