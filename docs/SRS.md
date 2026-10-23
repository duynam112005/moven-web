# 2. Software Requirements Specification (SRS)

## 2.1 Quy ước ưu tiên
- **MUST**: bắt buộc trong MVP.
- **SHOULD**: nên có, chỉ bỏ khi có lý do được ghi nhận.
- **OUT**: ngoài phạm vi MVP.

## 2.2 Vai trò và quyền tổng quát
| Khả năng | Khách vãng lai | Khách đã đăng nhập | Admin |
|---|---:|---:|---:|
| Xem sản phẩm/danh mục/banner đang hoạt động | MUST | MUST | MUST |
| Tìm kiếm, lọc, sắp xếp sản phẩm | MUST | MUST | MUST |
| Quản lý hồ sơ/địa chỉ cá nhân | Không | MUST | Tài khoản admin của mình |
| Quản lý giỏ hàng cá nhân | Không | MUST | Không dùng quyền admin để đọc giỏ khách |
| Đặt COD | Không | MUST | Không đặt thay khách qua quyền admin |
| Xem đơn hàng | Không | Chỉ đơn của mình | MUST |
| Hủy đơn đang chờ xác nhận | Không | Đơn của mình | Có thể xử lý theo quy trình admin |
| Đánh giá sản phẩm | Không | Sau khi đủ điều kiện | Quản lý kiểm duyệt |
| Báo cáo đánh giá | Không | MUST | Xử lý báo cáo |
| Quản lý catalog/banner/settings | Không | Không | MUST |
| Cập nhật trạng thái đơn | Không | Không | MUST, theo chuyển trạng thái hợp lệ |

## 2.3 Yêu cầu giao diện và catalog
- `CAT-001`: Trang chủ hiển thị banner hợp lệ, danh mục đang hoạt động và các sản phẩm nổi bật/mới.
- `CAT-002`: Chỉ sản phẩm đang hoạt động và thuộc danh mục đang hoạt động được hiển thị công khai.
- `CAT-003`: Người dùng có thể mở trang danh sách theo danh mục, tìm theo tên/mô tả, lọc theo đối tượng, size, màu và khoảng giá, sắp xếp theo giá/tính mới.
- `CAT-004`: Trang chi tiết hiển thị tên, mô tả, chất liệu, ảnh, giá, các biến thể, trạng thái tồn kho và đánh giá công khai.
- `CAT-005`: Giá hiển thị phải tương ứng biến thể được chọn. Nếu chưa chọn biến thể, giao diện hiển thị khoảng giá thấp nhất–cao nhất hoặc giá “từ …” một cách rõ ràng.
- `CAT-006`: Không cho thêm vào giỏ biến thể ngừng bán hoặc không đủ tồn.
- `CAT-007`: Ảnh lỗi hoặc thiếu phải có placeholder; không để layout vỡ.

## 2.4 Xác thực và tài khoản
- `AUTH-001`: Cho phép đăng ký bằng email và mật khẩu; email verification bật.
- `AUTH-002`: Cho phép đăng nhập/đăng xuất và khôi phục mật khẩu.
- `AUTH-003`: Khách vãng lai có thể duyệt catalog; thao tác checkout yêu cầu phiên đăng nhập hợp lệ và email đã xác minh theo chính sách Auth.
- `AUTH-004`: Hồ sơ ứng dụng gắn với ID của Supabase Auth; không lưu mật khẩu trong bảng `profiles`.
- `AUTH-005`: Người dùng không thể tự nâng quyền admin qua client, API hồ sơ hoặc payload đăng ký.
- `AUTH-006`: Sau đăng nhập, điều hướng dựa trên quyền được xác minh từ dữ liệu tin cậy; không chỉ dựa vào biến role trong bộ nhớ client.

## 2.5 Giỏ hàng và checkout
- `CART-001`: Mỗi tài khoản có tối đa một giỏ đang hoạt động.
- `CART-002`: Một dòng giỏ tương ứng một biến thể; thêm cùng biến thể sẽ tăng số lượng thay vì tạo dòng trùng.
- `CART-003`: Số lượng phải là số nguyên dương; số lượng trong giỏ không thể vượt tồn khả dụng tại thời điểm checkout.
- `CART-004`: Giỏ hiển thị giá hiện tại của biến thể; giá trong giỏ không phải nguồn giá có thẩm quyền khi đặt hàng.
- `CHECKOUT-001`: Chỉ khách đã đăng nhập mới được đặt đơn.
- `CHECKOUT-002`: Phương thức thanh toán duy nhất là COD.
- `CHECKOUT-003`: Khách chọn một địa chỉ đã lưu hoặc nhập thông tin giao hàng hợp lệ; đơn lưu snapshot người nhận, số điện thoại và địa chỉ.
- `CHECKOUT-004`: Phí vận chuyển mặc định 20.000 VND, có thể thay đổi bởi admin; phí áp dụng được đọc từ cấu hình phía server và snapshot vào đơn.
- `CHECKOUT-005`: Giá từng biến thể, số lượng, tổng tiền và phí ship phải được tính/xác minh phía server/database. Không tin tổng tiền do client gửi.
- `CHECKOUT-006`: Tạo đơn, tạo dòng hàng, trừ kho và ghi biến động kho phải thành công cùng nhau hoặc thất bại cùng nhau.
- `CHECKOUT-007`: Sau khi đặt đơn thành công, giỏ hàng đã checkout được dọn theo một cách nhất quán; không xóa giỏ nếu giao dịch đặt đơn thất bại.
- `CHECKOUT-008`: Hiển thị mã đơn, tổng tiền, phí giao hàng và trạng thái ban đầu sau khi đặt thành công.

## 2.6 Đơn hàng và giao vận
- `ORDER-001`: Khách chỉ được xem đơn thuộc tài khoản của mình.
- `ORDER-002`: Khách được hủy đơn chỉ khi trạng thái `pending_confirmation`; thao tác phải nguyên tử và không được hoàn kho hai lần.
- `ORDER-003`: Admin cập nhật trạng thái thủ công, chỉ qua các chuyển trạng thái được phép.
- `ORDER-004`: Trạng thái `delivery_failed` biểu thị giao không thành công, nhưng chưa xác nhận hàng đã về kho (chưa hoàn kho).
- `ORDER-005`: Admin chuyển sang `returned` chỉ sau khi xác nhận hàng đã quay về shop đầy đủ; thao tác này hoàn kho toàn bộ đơn hàng (nguyên tử).
- `ORDER-006`: Mọi đơn giữ snapshot sản phẩm/biến thể/giá/địa chỉ để lịch sử không đổi khi catalog được sửa.
- `ORDER-007`: COD bắt đầu ở `unpaid`. Trong MVP (Phương án B), khi đơn chuyển sang `delivered`, hệ thống tự động cập nhật `payment_status = paid`.
- `ORDER-008`: Không có tích hợp API hãng vận chuyển trong MVP; mã vận đơn là ngoài phạm vi bắt buộc.
- `ORDER-009`: Admin có thể xem chi tiết đơn, thông tin khách/địa chỉ snapshot, dòng hàng và toàn bộ lịch sử trạng thái được ghi tự động trong `order_status_history`.

## 2.7 Đánh giá và báo cáo
- `REV-001`: Chỉ tài khoản đã đăng nhập có đơn giao thành công chứa sản phẩm mới được đánh giá sản phẩm đó.
- `REV-002`: Mỗi khách chỉ có một đánh giá cho mỗi sản phẩm. Quy tắc áp dụng toàn bộ tài khoản, không phải một lần mỗi đơn.
- `REV-003`: Đánh giá có điểm 1–5; bình luận là tùy chọn hoặc bắt buộc theo UI nhưng cần chốt trước triển khai giao diện.
- `REV-004`: Khách có thể báo cáo đánh giá với lý do; báo cáo không tự động ẩn đánh giá.
- `REV-005`: Admin có thể xem báo cáo, đánh dấu đã xem/loại bỏ, ẩn hoặc khôi phục đánh giá và lưu lý do kiểm duyệt.
- `REV-006`: Đánh giá bị ẩn không hiển thị công khai và không được tính vào điểm trung bình công khai.
- `REV-007`: Backend phải xác minh quyền sở hữu đơn, trạng thái giao thành công và sản phẩm trước khi chấp nhận đánh giá.

## 2.8 Quản trị
- `ADM-001`: Admin tạo/sửa/ẩn danh mục; sắp xếp danh mục.
- `ADM-002`: Admin tạo/sửa/ẩn sản phẩm; quản lý nội dung, đối tượng, chất liệu và danh mục chính.
- `ADM-003`: Admin quản lý biến thể, SKU, size, màu, giá bán và tồn kho.
- `ADM-004`: Điều chỉnh tồn kho phải có lý do và tạo bản ghi `inventory_movements`; không sửa tồn trực tiếp không có audit.
- `ADM-005`: Admin tải lên/quản lý ảnh sản phẩm và banner qua Storage policy an toàn.
- `ADM-006`: Admin quản lý banner, thứ tự, lịch hiển thị, trạng thái hoạt động và liên kết đích.
- `ADM-007`: Admin cập nhật trạng thái đơn qua các bước hợp lệ; giao thất bại và xác nhận hàng hoàn về là hai sự kiện khác nhau.
- `ADM-008`: Admin quản lý báo cáo đánh giá và ẩn/khôi phục đánh giá.
- `ADM-009`: Admin cập nhật thông tin cửa hàng và phí giao hàng mặc định.
- `ADM-010`: Dashboard hiển thị số đơn, đơn theo trạng thái, doanh thu đơn giao thành công, sản phẩm bán chạy và biến thể sắp hết hàng.
- `ADM-011`: Ngưỡng “sắp hết hàng” phải cấu hình được hoặc dùng một ngưỡng mặc định có ghi rõ; không suy ra từ trạng thái đơn.
- `ADM-012`: Dashboard không gọi tổng giá trị đơn đã đặt là doanh thu giao thành công.

## 2.9 Yêu cầu phi chức năng
- `NFR-001` Bảo mật: RLS bật trên bảng chứa dữ liệu người dùng và chính sách được kiểm thử bằng cả vai trò anon/authenticated/admin.
- `NFR-002` Bí mật: không nhúng `service_role` key hoặc secret server vào Flutter Web.
- `NFR-003` Toàn vẹn: thao tác đặt/hủy/hoàn kho nguyên tử và chống lặp.
- `NFR-004` Khả năng sử dụng: layout responsive, thao tác checkout có thông báo lỗi có thể hành động.
- `NFR-005` Hiệu năng: phân trang danh sách sản phẩm/đơn; tránh tải toàn bộ bảng.
- `NFR-006` Khả năng truy cập: nhãn form, focus state, tương phản màu và kích thước thao tác hợp lý.
- `NFR-007` Quan sát: lỗi nghiệp vụ và lỗi server được log có ngữ cảnh, không log mật khẩu/token/dữ liệu nhạy cảm.
- `NFR-008` Môi trường: staging/test tách khỏi production, credentials và Storage buckets tách biệt.
- `NFR-009` Khôi phục: cần có kế hoạch backup/export trước khi launch; quy trình cụ thể xác định khi chuẩn bị production.
- `NFR-010` Thời gian: lưu timestamp UTC; giao diện dùng múi giờ `Asia/Ho_Chi_Minh`.

## 2.10 Tiêu chí nghiệm thu tối thiểu
1. Người chưa đăng nhập xem catalog được nhưng không thể checkout.
2. Khách không thể đọc đơn/địa chỉ/giỏ của tài khoản khác.
3. Khách không thể tự đặt `role=admin`.
4. Hai checkout đồng thời không thể bán vượt tồn.
5. Checkout thất bại không tạo đơn nửa chừng và không mất giỏ.
6. Hủy đơn hợp lệ chỉ hoàn kho một lần; gọi lặp không làm tồn tăng thêm.
7. Giao thất bại không hoàn kho trước khi xác nhận hàng hoàn về.
8. Giá/địa chỉ/sản phẩm của đơn cũ không đổi khi catalog hoặc địa chỉ được sửa.
9. Đánh giá không thể tạo nếu chưa có đơn giao thành công chứa sản phẩm.
10. Đánh giá bị ẩn không xuất hiện trong catalog công khai.
11. Admin chỉ truy cập được sau khi quyền được xác thực ở backend.
12. Dashboard doanh thu chỉ tính đơn giao thành công theo định nghĩa được chốt.
