# 6. Luồng nghiệp vụ MOVEN

## 6.1 Đăng ký và hồ sơ
1. Khách đăng ký email/mật khẩu qua Supabase Auth.
2. Supabase xác minh email theo cấu hình.
3. Hồ sơ ứng dụng được tạo với role mặc định `customer` bằng cơ chế tin cậy.
4. Khách cập nhật tên, số điện thoại và avatar; không thể sửa role.
5. Nếu chưa xác minh email, checkout bị chặn theo chính sách MVP.

## 6.2 Catalog và biến thể
1. Người dùng mở danh mục hoặc tìm sản phẩm.
2. Chỉ sản phẩm active thuộc danh mục active được hiển thị.
3. Chọn sản phẩm, sau đó chọn biến thể size/màu.
4. Giá và tình trạng hàng thay đổi theo biến thể.
5. Giá hiển thị trên client chỉ để tham khảo; giá checkout được đọc lại từ DB.

## 6.3 Giỏ hàng
1. Khách phải đăng nhập để lưu giỏ trong MVP.
2. Mỗi user có một cart; mỗi variant chỉ có một cart item.
3. Khi thay số lượng, kiểm tra quantity > 0 và variant còn active.
4. Giỏ không giữ chỗ hàng; số lượng có thể thay đổi do các đơn khác.
5. Khi checkout, server kiểm tra lại toàn bộ giỏ và tồn.

## 6.4 Checkout COD & Quét mã QR
1. Khách chọn địa chỉ lưu hoặc nhập người nhận/số điện thoại/địa chỉ hợp lệ.
2. Khách chọn phương thức thanh toán: **Thanh toán khi nhận hàng (COD)** hoặc **Quét mã QR thanh toán**.
3. Client gửi danh sách variant ID và quantity, địa chỉ/ghi chú cần thiết và `payment_method` (`cod` hoặc `qr_code`); không gửi tổng tiền làm nguồn có thẩm quyền.
4. Server xác minh người dùng, trạng thái biến thể, giá, tồn, phí ship hiện tại.
5. Trong một transaction:
   - Tạo order với snapshot người nhận/địa chỉ, `payment_method`.
   - Nếu là `qr_code`: tính `payment_expired_at = clock_timestamp() + INTERVAL '15 minutes'`.
   - Tạo order_items với snapshot tên/SKU/size/màu/giá.
   - Tính subtotal, shipping fee và total.
   - Trừ stock theo biến thể.
   - Ghi inventory movement cho từng dòng (`order_created`).
   - Dọn cart items đã checkout.
6. Nếu bất kỳ bước nào lỗi, rollback toàn bộ; giữ giỏ để khách sửa/thử lại.
7. Sau thành công:
   - Với đơn COD: bắt đầu ở `pending_confirmation`, payment method `cod`, payment status `unpaid`.
   - Với đơn QR: bắt đầu ở `pending_confirmation`, payment method `qr_code`, payment status `unpaid`, hiển thị mã QR có chứa mã đơn, số tiền và thông tin nhận hàng (để quét kiểm tra bằng camera điện thoại) cùng đồng hồ đếm ngược 15 phút.
8. Chống submit lặp để không tạo đơn kép.

## 6.5 Trạng thái đơn hàng
Trạng thái MVP:
- `pending_confirmation`: vừa đặt; khách được hủy.
- `confirmed`: admin xác nhận (hoặc tự động chuyển khi đơn QR được thanh toán `payment_status = 'paid'`).
- `preparing`: đang chuẩn bị hàng.
- `shipping`: đã bàn giao giao hàng/đang giao; trạng thái cập nhật thủ công.
- `delivery_failed`: giao không thành công; chưa kết luận hàng đã về kho.
- `delivered`: giao thành công; tính vào doanh thu theo định nghĩa MVP; tự động cập nhật `payment_status = paid`.
- `cancelled`: đơn đã hủy trước khi xác nhận theo chính sách khách, do admin xử lý hủy khi chưa bàn giao, hoặc do hệ thống tự động hủy đơn QR quá hạn 15 phút chưa thanh toán.
- `returned`: admin xác nhận hàng đã hoàn về đầy đủ và đã thực hiện hoàn kho toàn đơn.

Chuyển trạng thái:
- `pending_confirmation` → `confirmed` hoặc `cancelled`.
- `confirmed` → `preparing` hoặc `cancelled` (chỉ do admin nếu chưa bàn giao).
- `preparing` → `shipping` hoặc `cancelled` (chỉ do admin nếu chưa bàn giao).
- `shipping` → `delivered` hoặc `delivery_failed`.
- `delivery_failed` → `shipping` (giao lại) hoặc `returned` (khi admin xác nhận đã nhận đủ hàng về shop).
- Không cho phép khách tự chuyển trạng thái ngoài việc hủy khi `pending_confirmation`.
- Mọi thao tác chuyển trạng thái bắt buộc chạy qua PostgreSQL RPC tin cậy và tự động ghi log vào bảng `order_status_history` (lưu actor, thời điểm, trạng thái cũ/mới và ghi chú).
- Phạm vi hoàn hàng: xử lý **toàn đơn**, MVP không hỗ trợ hoàn từng phần.

## 6.6 Hủy đơn và hoàn kho
- Khi khách hủy đơn ở `pending_confirmation`, server xác minh quyền sở hữu và trạng thái.
- Khi admin hủy đơn ở `confirmed` hoặc `preparing`, server xác minh role admin và trạng thái hàng chưa giao.
- Khi đơn hàng Quét mã QR quá hạn 15 phút mà `payment_status = 'unpaid'`, RPC `cancel_expired_qr_orders()` tự động chuyển trạng thái sang `cancelled`, lý do `"Hết hạn thời gian thanh toán mã QR (15 phút)"`.
- Trong transaction hủy đơn: đổi trạng thái sang `cancelled`, hoàn kho toàn bộ biến thể với movement reason `order_cancelled`, và ghi log vào `order_status_history`.
- Giao dịch phải idempotent: gọi lại không được cộng tồn lần hai.
- Với đơn đã `shipping` và gặp `delivery_failed`: **tuyệt đối không hoàn kho** khi mới ghi nhận thất bại.
- Chỉ sau khi admin xác nhận hàng đã về cửa hàng, server mới chuyển trạng thái sang `returned`, tăng tồn kho và ghi movement `return_received`.

## 6.7 COD, Quét mã QR và thanh toán
- Khi tạo đơn COD, `payment_status = 'unpaid'`.
- Khi tạo đơn Quét mã QR, `payment_status = 'unpaid'`, hạn thanh toán 15 phút.
- Đối soát thanh toán:
  - Khi đơn COD chuyển sang `delivered`: hệ thống tự động cập nhật `payment_status = 'paid'` (Phương án B).
  - Khi đơn QR được xác nhận đã nhận tiền (`payment_status = 'paid'`): hệ thống tự động chuyển trạng thái đơn sang `confirmed` (ADR-0007).
- Dashboard doanh thu tính tổng giá trị của các đơn có trạng thái `delivered` trong khoảng thời gian được chọn.
- UI ghi rõ đây là "Doanh thu đơn giao thành công".

## 6.8 Đánh giá và báo cáo
1. Khách mở sản phẩm trong lịch sử đơn giao thành công.
2. Server xác minh order item thuộc user, đơn delivered và product khớp.
3. Khách gửi rating 1–5 và comment theo giới hạn được cấu hình.
4. Một user chỉ có một review cho mỗi product.
5. Khách khác có thể báo cáo review với lý do; hạn chế report lặp của cùng user cho cùng review.
6. Báo cáo tạo trạng thái pending; không tự động ẩn review.
7. Admin xem nội dung, quyết định dismiss hoặc ẩn review; lưu actor, thời gian và lý do.
8. Review ẩn không hiển thị công khai và không tính vào điểm trung bình công khai.

## 6.9 Quản lý catalog và banner
- Admin tạo category với slug duy nhất; có thể đổi thứ tự và ẩn/hiện.
- Admin tạo product, gán đúng một category, mô tả, đối tượng, chất liệu.
- Admin tạo variant cho size/màu/SKU, giá riêng và tồn kho.
- Điều chỉnh kho tạo inventory movement; không sửa tồn âm.
- Banner có trạng thái active, sort order và lịch hiển thị; link type được allowlist.
- Xóa mềm/ẩn product/category đã có liên kết lịch sử.

## 6.10 Dashboard
- Đơn theo trạng thái: đếm đơn theo status.
- Doanh thu: tổng total_amount của đơn delivered trong khoảng ngày được chọn; timezone ngày báo cáo là `Asia/Ho_Chi_Minh`.
- Bán chạy: tổng quantity trong order_items của các đơn delivered, xếp giảm dần.
- Sắp hết hàng: variant active có stock dưới ngưỡng cấu hình.
- Không cộng đơn cancelled hoặc delivery_failed vào doanh thu giao thành công.
- Dashboard cần ghi rõ khoảng ngày và định nghĩa số liệu.
