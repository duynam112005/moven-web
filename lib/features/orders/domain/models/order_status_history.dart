import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_status.dart';

part 'order_status_history.freezed.dart';
part 'order_status_history.g.dart';

/// Bản ghi lịch sử thay đổi trạng thái đơn hàng (Freezed)
@freezed
class OrderStatusHistory with _$OrderStatusHistory {
  const factory OrderStatusHistory({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'from_status') OrderStatus? fromStatus,
    @JsonKey(name: 'to_status') required OrderStatus toStatus,
    @JsonKey(name: 'actor_id') String? actorId,
    String? note,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _OrderStatusHistory;

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusHistoryFromJson(json);
}
