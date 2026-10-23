import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

/// Trang hiển thị thông tin tĩnh: Chính sách giao hàng, Đổi trả thủ công, Liên hệ
class StaticPageScreen extends StatelessWidget {
  final String title;
  final List<Widget> content;

  const StaticPageScreen({
    super.key,
    required this.title,
    required this.content,
  });

  factory StaticPageScreen.shippingPolicy() {
    return const StaticPageScreen(
      title: 'Chính sách giao hàng & COD',
      content: [
        Text(
          '1. Phương thức thanh toán',
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: AppDimensions.space8),
        Text(
          'MOVEN áp dụng phương thức thanh toán khi nhận hàng (COD) cho tất cả các đơn hàng trên toàn quốc. Khách hàng được quyền kiểm tra gói hàng trước khi thanh toán tiền mặt cho nhân viên giao vận.',
          style: AppTypography.bodyMedium,
        ),
        SizedBox(height: AppDimensions.space24),
        Text(
          '2. Phí giao hàng',
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: AppDimensions.space8),
        Text(
          'Phí giao hàng tiêu chuẩn toàn quốc là 20.000 VND/đơn hàng. Phí vận chuyển được áp dụng cố định và ghi rõ tại thời điểm quý khách xác nhận đặt hàng.',
          style: AppTypography.bodyMedium,
        ),
        SizedBox(height: AppDimensions.space24),
        Text(
          '3. Thời gian giao hàng dự kiến',
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: AppDimensions.space8),
        Text(
          '- Khu vực nội thành Hà Nội & TP. Hồ Chí Minh: 1 - 2 ngày làm việc.\n- Các tỉnh thành khác: 3 - 5 ngày làm việc.',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  factory StaticPageScreen.returnPolicy() {
    return const StaticPageScreen(
      title: 'Chính sách đổi trả hàng',
      content: [
        Text(
          '1. Quy trình đổi trả liên hệ thủ công',
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: AppDimensions.space8),
        Text(
          'Trong phiên bản hiện tại, MOVEN không hỗ trợ quy trình đổi/trả tự phục vụ trên hệ thống. Quý khách có nhu cầu đổi size, đổi màu hoặc phản ánh sản phẩm lỗi vui lòng liên hệ trực tiếp với bộ phận chăm sóc khách hàng.',
          style: AppTypography.bodyMedium,
        ),
        SizedBox(height: AppDimensions.space24),
        Text(
          '2. Điều kiện đổi trả',
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: AppDimensions.space8),
        Text(
          '- Sản phẩm còn nguyên tem mác, chưa qua giặt ủi hoặc sử dụng.\n- Yêu cầu đổi trả được gửi trong vòng 7 ngày kể từ khi đơn hàng được giao thành công.\n- Hỗ trợ đổi size 1 lần miễn phí.',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  factory StaticPageScreen.contact() {
    return const StaticPageScreen(
      title: 'Liên hệ với MOVEN',
      content: [
        Text(
          'Cửa hàng thời trang MOVEN',
          style: AppTypography.titleLarge,
        ),
        SizedBox(height: AppDimensions.space8),
        Text(
          'Chúng tôi luôn sẵn sàng lắng nghe và giải đáp mọi thắc mắc của bạn về sản phẩm, kích cỡ và đơn hàng.',
          style: AppTypography.bodyMedium,
        ),
        SizedBox(height: AppDimensions.space24),
        Text(
          'Thông tin liên hệ:',
          style: AppTypography.titleMedium,
        ),
        SizedBox(height: AppDimensions.space12),
        Text(
          '• Hotline: 1900 xxxx (8:30 - 21:30 hàng ngày)\n• Email hỗ trợ: support@moven.vn\n• Hợp tác kinh doanh: contact@moven.vn\n• Địa chỉ: Hà Nội, Việt Nam',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space48,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.space32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.displayMedium),
                const SizedBox(height: AppDimensions.space8),
                const Divider(),
                const SizedBox(height: AppDimensions.space24),
                ...content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
