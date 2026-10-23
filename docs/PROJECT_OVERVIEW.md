# 1. Tổng quan dự án MOVEN

## 1.1 Mục tiêu
Xây dựng website thương mại điện tử cho cửa hàng thời trang MOVEN, tập trung vào trải nghiệm mua quần áo đơn giản, hiện đại, tối giản và dễ dùng trên desktop, tablet, mobile. MVP ưu tiên luồng mua hàng COD hoàn chỉnh, quản trị sản phẩm/đơn hàng và bảo vệ dữ liệu.

## 1.2 Đối tượng
- Khách vãng lai: xem và tìm sản phẩm, danh mục, banner, đánh giá công khai.
- Khách hàng đã đăng nhập: quản lý hồ sơ/địa chỉ, giỏ hàng, đặt COD, theo dõi/hủy đơn hợp lệ, đánh giá sản phẩm và báo cáo đánh giá.
- Admin MOVEN: quản lý catalog, tồn kho, banner, đơn hàng, đánh giá/báo cáo và cấu hình cửa hàng.

MVP chỉ có một cửa hàng và một nhóm quyền quản trị. Không xây dựng multi-vendor hoặc nhiều chi nhánh.

## 1.3 Thiết kế giao diện
- Tinh thần: tối giản, trẻ trung, rõ ràng, chuyên nghiệp; tham khảo cách tổ chức trải nghiệm của Coolmate nhưng không sao chép nhận diện hoặc nội dung.
- Bảng màu đề xuất: trắng, đen, xám, kem, be, nâu nhạt. Màu nhấn phải nhất quán và có tương phản đủ.
- Ưu tiên hình ảnh sản phẩm, khoảng trắng, typography dễ đọc, điều hướng rõ ràng.
- Các trang mua sắm phải responsive; thao tác chọn size/màu, thêm giỏ và checkout cần dễ sử dụng trên màn hình nhỏ.
- Cần có trạng thái loading, empty, error, success và retry phù hợp.

## 1.4 Công nghệ bắt buộc
- Frontend: Flutter Web.
- State management: Riverpod.
- Navigation: GoRouter.
- Backend managed: Supabase.
- Authentication: Supabase Auth.
- Database: PostgreSQL trên Supabase.
- Media: Supabase Storage.
- Các thao tác nhạy cảm: PostgreSQL functions/RPC và/hoặc Supabase Edge Functions theo thiết kế bảo mật.
- Kiểm thử: unit test cho logic, integration test cho luồng quan trọng, kiểm thử thủ công trên desktop/mobile web.

Không thêm backend Node.js riêng, SQL Server, MySQL hoặc dịch vụ thanh toán online vào MVP nếu chưa có quyết định thay đổi chính thức.

## 1.5 Phạm vi MVP
### Có
- Trang chủ, banner, danh mục, danh sách sản phẩm, chi tiết sản phẩm.
- Tìm kiếm, lọc, sắp xếp catalog.
- Sản phẩm có size/màu và SKU; giá và tồn kho quản lý theo biến thể.
- Đăng ký, đăng nhập, đăng xuất, xác minh email, quên/đặt lại mật khẩu.
- Giỏ hàng gắn với tài khoản.
- Checkout COD, địa chỉ giao hàng, phí giao hàng.
- Lịch sử và chi tiết đơn; hủy đơn khi đang chờ xác nhận.
- Admin cập nhật trạng thái đơn thủ công.
- Đánh giá sau khi giao thành công; báo cáo đánh giá vi phạm.
- Dashboard quản trị cơ bản.
- Quản lý danh mục, sản phẩm, biến thể, ảnh, banner, đơn, đánh giá/báo cáo, thông tin cửa hàng.
- Trang liên hệ, chính sách giao hàng và thông tin đổi/trả theo quy trình liên hệ thủ công.

### Không thuộc MVP
- Thanh toán online, cổng thanh toán, ví điện tử.
- Voucher, coupon, chương trình tích điểm hoặc loyalty.
- Marketplace, nhiều shop, nhiều kho/chi nhánh.
- Tích hợp API hãng vận chuyển hoặc tự động theo dõi vận đơn.
- Đổi/trả tự phục vụ, hoàn tiền tự động.
- Chat realtime, thông báo push, ứng dụng native.
- Phân quyền admin nhiều cấp/permission tùy chỉnh.
- Giá khuyến mãi theo thời gian, giá riêng theo nhóm khách.
- Đa ngôn ngữ hoặc đa tiền tệ.

## 1.6 Các quyết định nghiệp vụ quan trọng
- COD là phương thức thanh toán duy nhất trong MVP.
- Phí giao hàng lấy từ cấu hình cửa hàng tại thời điểm tạo đơn; giá trị này được snapshot vào đơn.
- Giá bán của từng biến thể có thể khác nhau; giá tại thời điểm mua phải được snapshot vào `order_items`.
- Tồn kho là tồn khả dụng theo từng biến thể.
- Khi tạo đơn thành công, hệ thống trừ tồn kho nguyên tử.
- Khi khách hủy đơn hợp lệ hoặc admin xác nhận hàng hoàn về, hệ thống hoàn kho nguyên tử và chỉ một lần.
- Giao thất bại chưa đồng nghĩa hàng đã về kho; không hoàn kho cho tới khi admin xác nhận hàng hoàn về.
- Báo cáo doanh thu dựa trên đơn giao thành công; không đồng nhất giá trị đơn đã đặt với doanh thu đã giao.
- Danh mục do admin quản lý; một sản phẩm có đúng một danh mục chính.
- Giá biến thể không được tin từ client khi checkout; server đọc giá chuẩn từ database.
