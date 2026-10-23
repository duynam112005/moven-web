# 5. Đặc tả bảo mật, RLS và Storage

## 5.1 Nguyên tắc
1. Mặc định từ chối; chỉ mở quyền tối thiểu cần thiết.
2. Bật RLS cho mọi bảng nghiệp vụ có thể được truy cập qua API Supabase.
3. `anon` chỉ đọc dữ liệu công khai đã được lọc; không đọc dữ liệu cá nhân.
4. `authenticated` chỉ truy cập dữ liệu của chính tài khoản mình, trừ thao tác công khai đã xác định.
5. Quyền admin phải được xác minh từ nguồn tin cậy ở server/database; không tin role do client gửi.
6. Không bao giờ đưa `service_role` key, secret Edge Function hoặc database password vào Flutter Web.
7. Thao tác tiền, đơn, kho và kiểm duyệt phải có kiểm tra quyền và validation phía server.

## 5.2 Ma trận quyền logic
| Bảng | Anon | Customer | Admin |
|---|---|---|---|
| `profiles` | Không đọc hồ sơ riêng tư | Đọc/sửa trường được phép của chính mình; không sửa role | Quản lý theo nhu cầu quản trị, không được lộ bí mật xác thực |
| `addresses` | Không | CRUD địa chỉ của mình | Chỉ đọc khi cần xử lý đơn; ưu tiên xem snapshot trong đơn |
| `categories` | Đọc active | Đọc active | CRUD/ẩn/sắp xếp |
| `products` | Đọc active | Đọc active | CRUD/ẩn |
| `product_variants` | Đọc biến thể active của sản phẩm active | Đọc như anon; không sửa stock/price qua thao tác khách | CRUD giá/biến thể; điều chỉnh kho qua nghiệp vụ có audit |
| `product_images` | Đọc ảnh của catalog active | Như anon | CRUD metadata |
| `banners` | Chỉ đọc banner active trong lịch hiển thị | Như anon | CRUD |
| `carts` | Không | Chỉ giỏ của mình | Không mặc định đọc giỏ khách |
| `cart_items` | Không | Chỉ dòng thuộc giỏ của mình | Không mặc định |
| `orders` | Không | Chỉ đọc đơn của mình; tạo/hủy qua hàm nghiệp vụ | Đọc và cập nhật trạng thái hợp lệ qua luồng admin |
| `order_items` | Không | Chỉ đọc dòng của đơn mình | Đọc để vận hành |
| `inventory_movements` | Không | Không | Đọc; ghi qua hàm nghiệp vụ được bảo vệ |
| `reviews` | Đọc review không ẩn của sản phẩm công khai | Tạo/sửa review của mình nếu đủ điều kiện; không tự ẩn | Đọc, ẩn/khôi phục, kiểm duyệt |
| `review_reports` | Không | Tạo report và xem trạng thái report của mình nếu cần | Xem/xử lý tất cả report |
| `store_settings` | Chỉ đọc trường công khai cần thiết (store name/contact/shipping fee nếu hiển thị) | Như anon | Sửa |

Ma trận này là ý định bảo mật, chưa phải policy SQL. Trước migration phải xác định cụ thể `SELECT/INSERT/UPDATE/DELETE` và kiểm thử từng policy.

## 5.3 Quyền profile và admin
- Không cho client gửi `role=admin` trong signup hoặc update profile.
- Tạo profile mới phải mặc định `customer`.
- Cấp admin chỉ qua thao tác đáng tin cậy, ví dụ migration/SQL console quản trị hoặc server-side admin provisioning; ghi lại quy trình.
- Không dùng metadata do người dùng tự sửa làm nguồn duy nhất để cấp quyền.
- Admin route guard ở Flutter chỉ cải thiện UX; mọi thao tác backend vẫn phải kiểm tra quyền.
- Khi sửa profile, chỉ cho phép các cột như `full_name`, `phone`, `avatar_path`; không cho phép sửa `id`, `role`, hoặc cột quản trị.

## 5.4 Thao tác nghiệp vụ bắt buộc chạy phía server
- Tạo đơn COD và tính lại giá/tổng/phí ship.
- Kiểm tra tồn và trừ kho nguyên tử.
- Hủy đơn và hoàn kho một lần.
- Chuyển trạng thái đơn.
- Xác nhận hàng hoàn về và hoàn kho.
- Xác minh điều kiện viết review.
- Cấp/thu hồi quyền admin.
- Ghi inventory movement.
Không cho client trực tiếp ghi `stock_quantity`, `total_amount`, `payment_status`, `delivered_at`, `cancelled_at`, `is_hidden` của review hoặc trường kiểm duyệt.

## 5.5 Quy tắc tạo đơn
- Xác thực session và user ID từ JWT, không nhận user ID tùy ý từ payload.
- Lấy biến thể, giá hiện hành, trạng thái hoạt động và tồn từ database.
- Xác minh quantity nguyên dương, biến thể active và đủ hàng.
- Tính subtotal, shipping fee, total server-side.
- Dùng transaction/locking để ngăn race condition.
- Nếu bất kỳ bước nào thất bại, rollback toàn bộ.
- Không để retry tạo đơn trùng: cân nhắc idempotency key hoặc cơ chế chống submit lặp.
- Snapshot thông tin sản phẩm/biến thể/địa chỉ vào order.
- Trừ kho và ghi movement trong cùng transaction.

## 5.6 Quy tắc hủy và hoàn kho
- Hủy bởi khách chỉ khi `pending_confirmation`.
- Mỗi đơn/biến thể chỉ được hoàn kho đúng một lần cho sự kiện hủy/hoàn hàng.
- `delivery_failed` không tự động cộng kho.
- Admin xác nhận hàng đã hoàn về rồi mới thực hiện hoàn kho.
- Dùng trạng thái đơn và/hoặc bản ghi movement có khóa chống lặp để tránh double-restock.
- Không cho người dùng gọi trực tiếp hàm nội bộ bỏ qua kiểm tra quyền.

## 5.7 Supabase Storage
- Tách bucket hoặc đường dẫn logic cho product images, banners và avatar.
- Catalog image/banner có thể đọc công khai nếu đó là chủ ý thiết kế.
- Chỉ admin được upload, thay thế hoặc xóa ảnh sản phẩm/banner.
- Avatar chỉ được sửa trong vùng của chính user.
- Kiểm tra loại MIME, dung lượng và phần mở rộng; không tin tên file từ client.
- Database chỉ lưu object path/key; tạo URL phù hợp khi hiển thị.
- Khi thay ảnh, tránh xóa object cũ trước khi metadata mới đã lưu thành công.
- Storage policy phải được kiểm thử độc lập với RLS của bảng metadata.

## 5.8 Kiểm thử bảo mật bắt buộc
- Anon không đọc orders, carts, addresses, profiles riêng tư hoặc movements.
- Customer A không đọc/sửa dữ liệu customer B.
- Customer không thể nâng role hoặc sửa giá/tồn/tổng tiền.
- Customer không thể tự đặt đơn thành delivered.
- Customer không thể review sản phẩm chưa mua hoặc đơn chưa delivered.
- Customer không thể tự ẩn review hoặc xử lý report.
- Customer không thể upload ảnh banner/product.
- Admin có thể thực hiện tác vụ quản trị được phép nhưng không thể vượt quy tắc chuyển trạng thái.
