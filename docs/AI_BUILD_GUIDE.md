# 9. Hướng dẫn dành cho AI lập trình

## 9.1 Vai trò
Bạn là kỹ sư phần mềm triển khai website thương mại điện tử một cửa hàng MOVEN theo đúng đặc tả đã phê duyệt. Bạn phải ưu tiên tính đúng đắn nghiệp vụ, bảo mật, khả năng kiểm thử và code dễ bảo trì hơn tốc độ tạo nhiều file.

## 9.2 Tra cứu tài liệu

Luôn bắt đầu ở `docs/README.md`. File này là entry point duy nhất, quy định tài liệu cần đọc theo từng loại công việc và khi nào phải đọc toàn bộ specs. Không áp dụng một thứ tự đọc toàn bộ cố định cho mọi thay đổi.

Khi công việc sửa kiến trúc, schema, quyền, tiền, đơn hàng hoặc tồn kho, bắt buộc đọc toàn bộ specs theo danh sách trong `docs/README.md`, cùng ADR và glossary liên quan.

## 9.3 Quy tắc không được vi phạm
- Không tự ý thay đổi stack: Flutter Web + Supabase/PostgreSQL + Riverpod + GoRouter.
- Không tạo backend Node.js hoặc chuyển sang SQL Server/MySQL khi chưa được chủ dự án chấp thuận.
- Không viết SQL/migration trước khi các mục cần chốt trong đặc tả được giải quyết.
- Không tự thêm voucher, thanh toán online, marketplace hoặc đổi/trả tự phục vụ vào MVP.
- Không đưa service_role key hoặc secret vào frontend.
- Không tin giá, tổng tiền, role, tồn kho, trạng thái đơn hoặc điều kiện review do client gửi.
- Không cho khách sửa role, stock, total, payment status, order status hoặc moderation fields trực tiếp.
- Không xóa cứng dữ liệu giao dịch/lịch sử.
- Không hoàn kho khi mới có trạng thái delivery_failed; chỉ hoàn khi có sự kiện hợp lệ và chống lặp.
- Không coi `delivered` là bằng chứng tiền COD đã đối soát thực nhận. Dashboard MVP hiển thị doanh thu đơn giao thành công.
- Không tạo schema/table/column ngoài đặc tả mà không ghi lại lý do và yêu cầu phê duyệt.
- Không giả định rằng RLS tự động bảo vệ mọi function; cần kiểm tra quyền trong từng function.
- Không chỉ dựa vào route guard Flutter để bảo vệ admin.

## 9.4 Cách làm việc
- Triển khai từng giai đoạn trong `IMPLEMENTATION_PLAN.md`.
- Trước mỗi giai đoạn, liệt kê file sẽ tạo/sửa và lý do.
- Sau mỗi giai đoạn, chạy test/lint/analyze tương ứng và báo cáo kết quả thật; không tuyên bố test pass nếu chưa chạy.
- Nếu thiếu quyết định, nêu câu hỏi cụ thể và đề xuất mặc định; không tự đoán những quyết định ảnh hưởng tiền, bảo mật, trạng thái hoặc schema.
- Giữ thay đổi tập trung; không refactor rộng ngoài phạm vi task.
- Cập nhật tài liệu nếu có quyết định mới được người dùng chấp thuận.
- Với lỗi, trình bày nguyên nhân, cách tái hiện, cách sửa và kiểm thử hồi quy.

## 9.5 Quy ước code dự kiến
- Feature-first, tránh Clean Architecture quá nhiều tầng.
- UI không truy vấn Supabase trực tiếp nếu đã có repository cho feature.
- Model/DTO có kiểu dữ liệu rõ; xử lý null và timestamp tường minh.
- Phân biệt lỗi validation, lỗi quyền, lỗi mạng, hết hàng và lỗi server.
- Không log session/token, mật khẩu hoặc dữ liệu nhạy cảm.
- UI phải có loading, empty, error và success states.
- Mọi thao tác có tác động tồn/tiền phải có test.
- Ưu tiên accessibility, responsive layout và tiếng Việt tự nhiên cho UI MVP.

## 9.6 Báo cáo hoàn thành mỗi giai đoạn
Báo cáo:
1. Những gì đã triển khai.
2. Các file đã tạo/sửa.
3. Quyết định/giả định mới (nếu có).
4. Test đã chạy và kết quả.
5. Rủi ro hoặc việc còn thiếu.
6. Giai đoạn tiếp theo được đề xuất.

## 9.7 Điều kiện dừng
Dừng và hỏi người dùng nếu phát hiện:
- Xung đột giữa tài liệu.
- Yêu cầu mới làm thay đổi schema hoặc phân quyền.
- Luồng hoàn tiền/hoàn kho không rõ.
- Một thao tác yêu cầu quyền vượt quá RLS dự kiến.
- Không thể bảo đảm tính nguyên tử hoặc idempotency cho tiền/tồn kho.
