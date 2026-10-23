# MOVEN — Bộ tài liệu đặc tả kỹ thuật

**Phiên bản:** 1.0  
**Trạng thái:** Đặc tả MVP — chưa triển khai code hoặc SQL  
**Sản phẩm:** Website bán quần áo một cửa hàng  
**Thương hiệu:** MOVEN

## Mục đích
Bộ tài liệu này là nguồn yêu cầu chuẩn cho người phát triển và AI lập trình. Các tài liệu mô tả phạm vi MVP, nghiệp vụ, kiến trúc, dữ liệu, ERD, bảo mật và kế hoạch triển khai. Chúng không chứa mã ứng dụng hoặc câu lệnh SQL triển khai.

## Thứ tự ưu tiên khi đọc
1. `PROJECT_OVERVIEW.md` — mục tiêu, phạm vi và quyết định nền tảng.
2. `SRS.md` — yêu cầu chức năng và tiêu chí nghiệm thu.
3. `BUSINESS_FLOWS.md` — luồng nghiệp vụ và quy tắc chuyển trạng thái.
4. `DATABASE_SPEC.md` — mô hình dữ liệu logic và ràng buộc.
5. `ERD.md` — sơ đồ quan hệ.
6. `SECURITY_SPEC.md` — RLS, phân quyền và Storage.
7. `ARCHITECTURE.md` — cấu trúc và trách nhiệm các lớp.
8. `IMPLEMENTATION_PLAN.md` — thứ tự triển khai và kiểm thử.
9. `OPEN_DECISIONS.md` - 
10. `AI_BUILD_GUIDE.md` — quy tắc bắt buộc dành cho AI.

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
- Không viết code hoặc SQL trong giai đoạn đặc tả.

## Quy ước
- Tiền tệ: VND, lưu dưới dạng số nguyên, không dùng floating point.
- Thời gian lưu ở UTC; giao diện hiển thị theo múi giờ Việt Nam (`Asia/Ho_Chi_Minh`).
- Ảnh trong Storage lưu đường dẫn/object key; database không phụ thuộc URL có chữ ký ngắn hạn.
- Xóa mềm/ẩn dữ liệu sản phẩm đã được dùng trong đơn hàng; không xóa cứng lịch sử giao dịch.
- Tất cả hành vi ảnh hưởng tiền, đơn hàng, tồn kho, quyền admin phải được xác thực phía server/database.
