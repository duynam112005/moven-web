# MOVEN — Bộ tài liệu đặc tả kỹ thuật

**Phiên bản:** 1.1
**Trạng thái:** Baseline MVP đang được triển khai — repository có ứng dụng Flutter Web, Supabase migrations, RLS/Storage scripts và test. Tài liệu này không xác nhận trạng thái triển khai hay production của từng môi trường.
**Sản phẩm:** Website bán quần áo một cửa hàng
**Thương hiệu:** MOVEN

## Mục đích

Đây là **entry point duy nhất** cho AI và người phát triển khi cần tra cứu tài liệu dự án. Đọc file này trước, sau đó chỉ mở các tài liệu phù hợp với loại công việc. Bộ tài liệu mô tả phạm vi MVP, nghiệp vụ, kiến trúc, dữ liệu, bảo mật và kế hoạch triển khai; mã ứng dụng, migrations và tests là nguồn hiện trạng triển khai.

## Chọn tài liệu theo loại công việc

| Loại công việc | Tài liệu cần đọc trước khi đề xuất/thay đổi |
|---|---|
| Bất kỳ thay đổi nào | `PROJECT_OVERVIEW.md`, `AI_BUILD_GUIDE.md`, và phần tài liệu liên quan trong bảng này |
| UI Flutter, state, routing, repository, model hoặc test | `ARCHITECTURE.md`, `SRS.md`; đọc `BUSINESS_FLOWS.md` khi chạm một luồng nghiệp vụ |
| Catalog, banner, profile, cart, dashboard hoặc settings | `SRS.md`, `BUSINESS_FLOWS.md`; thêm `SECURITY_SPEC.md` nếu có dữ liệu riêng tư hoặc thao tác admin |
| Auth, RLS, Storage, role, RPC hoặc Edge Function | `SECURITY_SPEC.md`, `ARCHITECTURE.md`, `SRS.md`; thêm luồng nghiệp vụ liên quan |
| Sửa kiến trúc, schema, quyền, tiền, đơn hàng hoặc tồn kho | **Đọc toàn bộ bộ specs:** `PROJECT_OVERVIEW.md`, `SRS.md`, `BUSINESS_FLOWS.md`, `DATABASE_SPEC.md`, `ERD.md`, `SECURITY_SPEC.md`, `ARCHITECTURE.md`, `IMPLEMENTATION_PLAN.md`, `OPEN_DECISIONS.md`, `AI_BUILD_GUIDE.md`, cùng ADR và glossary liên quan |
| Làm rõ thuật ngữ hoặc quyết định đã ghi nhận | `GLOSSARY.md` ở repo root và `docs/adr/`; đọc `OPEN_DECISIONS.md` nếu quyết định còn chưa chốt |
| Lập kế hoạch hoặc kiểm thử/review phạm vi rộng | `IMPLEMENTATION_PLAN.md`, `SRS.md`, các specs của vùng ảnh hưởng và ADR liên quan |

Không cần đọc toàn bộ specs cho thay đổi hẹp không thuộc nhóm nhạy cảm ở trên. Tuy vậy, luôn kiểm tra các tài liệu được chọn có mâu thuẫn với mã hoặc migrations hiện tại hay không.

## Quy tắc đọc và xử lý xung đột

Nếu hai tài liệu mâu thuẫn, không tự chọn một phương án. Dừng phần triển khai bị ảnh hưởng, ghi rõ xung đột và yêu cầu xác nhận. Các quy tắc bảo mật, toàn vẹn dữ liệu và giao dịch nguyên tử không được nới lỏng để tiện triển khai.

## Quyết định đã chốt
- Flutter Web; Supabase Auth, PostgreSQL, Storage; Riverpod; GoRouter.
- Một cửa hàng duy nhất: MOVEN; không phải marketplace.
- Khách có thể xem sản phẩm không cần đăng nhập; phải đăng nhập để đặt hàng.
- Thanh toán COD; phí giao hàng mặc định 20.000 VND, cấu hình được.
- Nguồn giá bán thẩm quyền duy nhất là `product_variants.price`; `compare_at_price` ở cấp biến thể; bỏ `products.base_price`.
- Mỗi sản phẩm thuộc một danh mục chính; admin quản lý danh mục.
- Admin cập nhật trạng thái vận chuyển thủ công; MVP không tích hợp API hãng vận chuyển.
- Chỉ hoàn kho khi admin xác nhận đã nhận đủ hàng hoàn về sau giao thất bại (trạng thái đơn chuyển sang `returned`, hoàn toàn bộ đơn nguyên tử).
- Doanh thu báo cáo tính trên đơn giao thành công (`delivered`); khi đơn chuyển sang `delivered`, hệ thống tự động cập nhật `payment_status = 'paid'`.
- Mọi lần chuyển trạng thái đơn hàng bắt buộc qua RPC và được lưu vết tự động vào bảng `order_status_history`.
- Mỗi khách được đánh giá một lần cho mỗi sản phẩm, chỉ sau khi sản phẩm có trong đơn giao thành công.
- Không triển khai voucher/khuyến mãi trong MVP.
- Không có quy trình đổi/trả tự phục vụ; khách liên hệ cửa hàng, admin xử lý thủ công.
- Đặc tả là baseline để đối chiếu; thay đổi code, SQL hoặc migrations phải tuân theo phạm vi đã được duyệt.

## Quy ước
- Tiền tệ: VND, lưu dưới dạng số nguyên, không dùng floating point.
- Thời gian lưu ở UTC; giao diện hiển thị theo múi giờ Việt Nam (`Asia/Ho_Chi_Minh`).
- Ảnh trong Storage lưu đường dẫn/object key; database không phụ thuộc URL có chữ ký ngắn hạn.
- Xóa mềm/ẩn dữ liệu sản phẩm đã được dùng trong đơn hàng; không xóa cứng lịch sử giao dịch.
- Tất cả hành vi ảnh hưởng tiền, đơn hàng, tồn kho, quyền admin phải được xác thực phía server/database.
