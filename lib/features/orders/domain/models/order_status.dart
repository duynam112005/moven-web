import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Trạng thái giao vận chuẩn của đơn hàng MOVEN (ADR-0001, GLOSSARY.md)
enum OrderStatus {
  /// Đơn mới tạo thành công, chờ xác nhận đóng gói
  pendingConfirmation('pending_confirmation'),

  /// Đã bàn giao cho đơn vị vận chuyển
  shipping('shipping'),

  /// Giao hàng thành công (dùng tính doanh thu)
  delivered('delivered'),

  /// Giao hàng thất bại (tồn kho giữ nguyên với shipper, không hoàn kho)
  deliveryFailed('delivery_failed'),

  /// Đơn bị hủy (chỉ từ pending_confirmation, hoàn kho ngay)
  cancelled('cancelled'),

  /// Admin xác nhận đã nhận lại hàng hoàn từ shipper (hoàn kho ngay)
  returned('returned');

  final String value;
  const OrderStatus(this.value);

  /// Parse từ chuỗi giá trị trong database
  static OrderStatus fromString(String? val) {
    if (val == null) return OrderStatus.pendingConfirmation;
    final normalized = val.trim().toLowerCase();
    for (final status in OrderStatus.values) {
      if (status.value == normalized) return status;
    }
    // Backward compatibility cho 'pending', 'confirmed', 'preparing'
    if (normalized == 'pending' ||
        normalized == 'confirmed' ||
        normalized == 'preparing') {
      return OrderStatus.pendingConfirmation;
    }
    return OrderStatus.pendingConfirmation;
  }

  /// Tên hiển thị tiếng Việt thân thiện
  String get displayName {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return 'Chờ xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Giao thành công';
      case OrderStatus.deliveryFailed:
        return 'Giao thất bại';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã trả hàng hoàn';
    }
  }

  /// Mô tả ngắn về ý nghĩa trạng thái
  String get description {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return 'Đơn hàng đang chờ nhân viên kiểm tra và chuẩn bị đóng gói.';
      case OrderStatus.shipping:
        return 'Kiện hàng đã xuất kho và đang được chuyển phát đến bạn.';
      case OrderStatus.delivered:
        return 'Kiện hàng đã được phát thành công tới người nhận.';
      case OrderStatus.deliveryFailed:
        return 'Chưa thể giao phát kiện hàng. Shop sẽ liên hệ hỗ trợ bạn.';
      case OrderStatus.cancelled:
        return 'Đơn hàng đã được hủy và sản phẩm đã hoàn lại vào kho.';
      case OrderStatus.returned:
        return 'Kiện hàng hoàn đã về tới kho và được nhập lại tồn kho an toàn.';
    }
  }

  /// Màu nền badge trạng thái
  Color get badgeBackgroundColor {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return const Color(0xFFFEF3C7); // Light amber
      case OrderStatus.shipping:
        return const Color(0xFFDBEAFE); // Light blue
      case OrderStatus.delivered:
        return const Color(0xFFD1FAE5); // Light emerald
      case OrderStatus.deliveryFailed:
        return const Color(0xFFFFEDD5); // Light orange
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2); // Light red
      case OrderStatus.returned:
        return const Color(0xFFF3E8FF); // Light purple
    }
  }

  /// Màu chữ badge trạng thái
  Color get badgeTextColor {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return const Color(0xFFB45309); // Dark amber
      case OrderStatus.shipping:
        return AppColors.info; // Blue
      case OrderStatus.delivered:
        return AppColors.success; // Emerald
      case OrderStatus.deliveryFailed:
        return const Color(0xFFC2410C); // Dark orange
      case OrderStatus.cancelled:
        return AppColors.error; // Red
      case OrderStatus.returned:
        return const Color(0xFF7E22CE); // Dark purple
    }
  }

  /// Icon đại diện cho trạng thái
  IconData get icon {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return Icons.hourglass_top_rounded;
      case OrderStatus.shipping:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.deliveryFailed:
        return Icons.error_outline_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.returned:
        return Icons.assignment_return_outlined;
    }
  }

  /// Khách hàng chỉ được phép tự hủy đơn khi đơn ở pendingConfirmation
  bool get canCustomerCancel => this == OrderStatus.pendingConfirmation;

  /// Các trạng thái tiếp theo hợp lệ mà Admin có thể chuyển tới (theo State Machine ADR-0001)
  List<OrderStatus> get validNextStatusesAdmin {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return [OrderStatus.shipping, OrderStatus.cancelled];
      case OrderStatus.shipping:
        return [OrderStatus.delivered, OrderStatus.deliveryFailed];
      case OrderStatus.deliveryFailed:
        return [OrderStatus.shipping, OrderStatus.returned];
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        return []; // Trạng thái kết thúc
    }
  }

  /// Vị trí bước trong Stepper tiến trình (từ 0 đến 2)
  /// Phục vụ hiển thị tiến trình trực quan
  int get timelineStepIndex {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return 0;
      case OrderStatus.shipping:
        return 1;
      case OrderStatus.delivered:
      case OrderStatus.deliveryFailed:
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        return 2;
    }
  }
}
