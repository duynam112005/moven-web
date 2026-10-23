# 8. Kế hoạch triển khai và kiểm thử

## Giai đoạn 0 — Chốt đặc tả
- Rà soát các mục “cần chốt” trong `DATABASE_SPEC.md` và `BUSINESS_FLOWS.md`.
- Chốt trạng thái đơn, quy tắc hoàn kho, comment review, ngưỡng low-stock, mã đơn/SKU và cấu trúc địa chỉ.
- Chốt ma trận RLS và cách provision admin.
- Chưa tạo schema production hoặc viết UI trước khi quyết định khóa được ghi vào tài liệu.

**Exit criteria:** không còn quyết định mơ hồ ảnh hưởng schema, bảo mật hoặc tiền/tồn kho.

## Giai đoạn 1 — Thiết lập môi trường
- Tạo dự án Supabase staging riêng.
- Thiết lập Flutter Web, Riverpod, GoRouter và cấu hình môi trường.
- Xác minh Auth email, redirect URL và password recovery.
- Tách secret/public config; xác nhận không có service_role trong frontend.
- Thiết lập quy trình migration có version control khi đã được duyệt.

**Exit criteria:** ứng dụng khởi chạy; Auth staging hoạt động; secret scan không phát hiện secret nhạy cảm.

## Giai đoạn 2 — Database nền tảng và RLS
- Triển khai schema theo `DATABASE_SPEC.md` sau khi duyệt.
- Thiết lập constraint, index, trigger/function chỉ khi có đặc tả rõ.
- Thiết lập RLS cho anon/customer/admin.
- Tạo Storage buckets và policies.
- Seed dữ liệu mẫu giả lập, không dùng dữ liệu khách thật.

**Exit criteria:** test quyền từng vai trò đạt; constraint quan trọng được test.

## Giai đoạn 3 — Auth và profile
- Đăng ký, email verification, login/logout, forgot/reset password.
- Tạo profile customer an toàn.
- Hồ sơ, địa chỉ và route guard.
- Test không thể nâng role.

**Exit criteria:** luồng Auth đầy đủ và dữ liệu cá nhân được cô lập.

## Giai đoạn 4 — Catalog và trang chủ
- Admin CRUD category/product/variant/images.
- Catalog public, search/filter/sort/pagination.
- Homepage/banner/product detail.
- Test giá theo variant, ảnh, active/inactive.

**Exit criteria:** chỉ dữ liệu public hợp lệ được hiển thị; admin upload được ảnh.

## Giai đoạn 5 — Cart và checkout COD
- Cart persistence.
- Server-side checkout function.
- Tính giá/phí ship và snapshot.
- Atomic stock decrement và inventory movement.
- Chống duplicate submission và concurrency.

**Exit criteria:** test checkout thành công, hết hàng, giá thay đổi, lỗi giữa transaction và checkout đồng thời.

## Giai đoạn 6 — Admin orders và vận chuyển thủ công
- Admin xem đơn và cập nhật status.
- Khách xem đơn và hủy khi pending confirmation.
- Ghi nhận delivery_failed.
- Xác nhận hàng hoàn về rồi mới restock.
- Test double-cancel/double-restock.

**Exit criteria:** không có stock drift trong các kịch bản test; lịch sử đơn được giữ nguyên.

## Giai đoạn 7 — Reviews và reports
- Chỉ review sau delivered.
- Một review/customer/product.
- Report review, admin moderation.
- Test ownership và trạng thái đơn.

**Exit criteria:** không thể tạo review giả hoặc tự ẩn review.

## Giai đoạn 8 — Dashboard, settings và hoàn thiện UI
- Store settings, shipping fee.
- Dashboard delivered revenue, best sellers, low stock.
- Responsive, loading/error/empty states, accessibility pass.
- Trang liên hệ/chính sách.

**Exit criteria:** số liệu đối chiếu với các đơn seed; UX trên desktop và mobile chấp nhận được.

## Giai đoạn 9 — Kiểm thử trước launch
- Unit/integration/manual tests.
- Security review RLS/Storage/functions.
- Kiểm tra backup/export, log, monitoring và quy trình xử lý sự cố.
- Test trên browser phổ biến và kích thước màn hình.
- Chuẩn bị production riêng, không sao chép secret staging.

**Exit criteria:** tất cả P0/P1 defects đã đóng; rollback/backup procedure được thử nghiệm.

## Bộ test bắt buộc
- Catalog public chỉ trả dữ liệu active.
- User A không đọc/sửa dữ liệu User B.
- Không thể tạo admin từ signup/profile.
- Hai checkout đồng thời không oversell.
- Checkout lỗi rollback order/items/stock/movement/cart changes.
- Giá thay đổi sau khi thêm giỏ: checkout dùng giá hiện hành hoặc từ chối rõ ràng, không dùng giá cũ do client gửi.
- Cancel/retry không hoàn kho hai lần.
- Delivery failed không restock ngay.
- Xác nhận return received chỉ restock một lần.
- Review chỉ được phép với delivered order; review duplicate bị chặn.
- Review hidden không xuất hiện công khai.
- Dashboard doanh thu không tính cancelled/delivery_failed.
- Storage upload/delete bị chặn với customer.
