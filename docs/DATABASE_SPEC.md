# 3. Đặc tả cơ sở dữ liệu logic

## 3.1 Quy ước chung
- PostgreSQL trên Supabase.
- ID nội bộ dùng UUID (trừ khi có quyết định khác trước migration).
- Thời gian dùng `timestamptz`, lưu UTC.
- Tiền dùng kiểu số nguyên VND; không dùng `float`/`real` cho tiền.
- Các bảng nghiệp vụ có `created_at`; bảng có thể sửa thường có `updated_at`.
- Tên bảng/cột dùng `snake_case`, bảng dùng số nhiều nhất quán.
- FK nên có quy tắc xóa rõ ràng. Không cascade xóa lịch sử đơn/biến động kho.
- Giá và địa chỉ của đơn hàng là snapshot bất biến sau khi đặt.
- Các giá trị enum có thể triển khai bằng PostgreSQL enum hoặc CHECK constraint; chọn một cách thống nhất khi viết migration.

## 3.2 Bảng và cột

### 1. `profiles`
Hồ sơ ứng dụng, gắn với Supabase Auth.
- `id`: UUID, PK, FK đến `auth.users.id`.
- `full_name`: tên hiển thị.
- `phone`: số điện thoại, nullable nếu chưa cung cấp.
- `role`: `customer` hoặc `admin`; mặc định `customer`.
- `avatar_path`: object key trong Storage, nullable.
- `created_at`, `updated_at`.
Quy tắc: client không được tự thay đổi `role`; cấp admin qua thao tác quản trị tin cậy.

### 2. `addresses`
- `id`: UUID, PK.
- `user_id`: FK `profiles.id`.
- `recipient_name`, `phone`: bắt buộc.
- `province`, `district`, `ward`, `address_line`: thông tin địa chỉ.
- `is_default`: boolean.
- `created_at`, `updated_at`.
Ràng buộc: địa chỉ chỉ do chủ sở hữu quản lý; tối đa một địa chỉ mặc định mỗi người dùng (cần bảo đảm bằng transaction/unique partial index hoặc logic tương đương).

### 3. `categories`
- `id`: UUID, PK.
- `name`: bắt buộc.
- `slug`: bắt buộc, unique.
- `description`: nullable.
- `image_path`: nullable.
- `is_active`: boolean.
- `sort_order`: integer.
- `created_at`, `updated_at`.
Quy tắc: danh mục có sản phẩm liên quan nên được ẩn thay vì xóa cứng.

### 4. `products`
- `id`: UUID, PK.
- `category_id`: FK `categories.id`, bắt buộc.
- `name`: bắt buộc.
- `slug`: unique, bắt buộc.
- `description`, `material`: nullable hoặc theo yêu cầu nội dung.
- `target_audience`: `men`, `women`, `unisex`.
- `is_featured`, `is_active`: boolean.
- `created_at`, `updated_at`.
Quy tắc: mỗi sản phẩm đúng một danh mục chính. Không lưu `base_price` ở cấp sản phẩm; giá hiển thị được tính động từ các biến thể bán được (`MIN(product_variants.price)`). Không xóa cứng sản phẩm đã xuất hiện trong đơn.

### 5. `product_variants`
- `id`: UUID, PK.
- `product_id`: FK `products.id`.
- `sku`: bắt buộc, unique.
- `size`: nullable cho sản phẩm không có size.
- `color_name`, `color_hex`: nullable theo loại sản phẩm.
- `price`: giá bán VND theo biến thể, bắt buộc, không âm (nguồn giá bán duy nhất có thẩm quyền).
- `compare_at_price`: giá gốc/giá so sánh VND theo biến thể, nullable, không âm (nếu có phải >= `price`).
- `stock_quantity`: số lượng tồn khả dụng, không âm.
- `is_active`: boolean.
- `created_at`, `updated_at`.
Ràng buộc: unique tổ hợp `product_id + size + color_name` (sử dụng ràng buộc thích hợp cho các trường NULL). Không cho đặt biến thể ngừng bán. Giá bán khi checkout luôn được đọc trực tiếp từ DB server.

### 6. `product_images`
- `id`: UUID, PK.
- `product_id`: FK `products.id`.
- `variant_id`: FK `product_variants.id`, nullable.
- `image_path`: object key Storage.
- `alt_text`: nullable.
- `sort_order`: integer.
- `is_primary`: boolean.
- `created_at`.
Quy tắc: ảnh chính phải được xác định ổn định; nếu có ảnh gắn variant, cần quy tắc fallback sang ảnh sản phẩm chung.

### 7. `banners`
- `id`: UUID, PK.
- `title`: bắt buộc.
- `subtitle`: nullable.
- `image_path`: bắt buộc.
- `link_type`: kiểu đích được cho phép như `none`, `product`, `category`, `url`.
- `link_value`: nullable; không cho URL nguy hiểm hoặc scheme tùy ý.
- `start_at`, `end_at`: nullable theo lịch hiển thị.
- `is_active`: boolean.
- `sort_order`: integer.
- `created_at`, `updated_at`.
Quy tắc: banner chỉ hiển thị công khai khi active và nằm trong khoảng thời gian đã cấu hình.

### 8. `carts`
- `id`: UUID, PK.
- `user_id`: FK `profiles.id`, unique.
- `created_at`, `updated_at`.
Quy tắc: một giỏ hoạt động cho mỗi tài khoản trong MVP.

### 9. `cart_items`
- `id`: UUID, PK.
- `cart_id`: FK `carts.id`.
- `variant_id`: FK `product_variants.id`.
- `quantity`: integer dương.
- `created_at`, `updated_at`.
Ràng buộc unique `cart_id + variant_id`. Giỏ không đảm bảo giữ chỗ tồn kho; tồn được xác minh lại lúc checkout.

### 10. `orders`
- `id`: UUID, PK.
- `order_code`: unique, dễ đọc, không đoán được tuần tự đơn giản nếu có thể (tiền tố `MVN-`).
- `user_id`: FK `profiles.id`.
- `status`: `pending_confirmation`, `confirmed`, `preparing`, `shipping`, `delivery_failed`, `delivered`, `cancelled`, `returned`.
- `payment_method`: `cod` (thanh toán khi nhận hàng) hoặc `qr_code` (quét mã QR thanh toán) (ADR-0007).
- `payment_status`: `unpaid`, `paid`, `failed`. Khi tạo đơn bắt đầu ở `unpaid`. Trong MVP (theo Phương án B), khi đơn chuyển sang `delivered`, hệ thống tự động cập nhật `payment_status = 'paid'`. Với đơn `qr_code`, khi `payment_status = 'paid'`, đơn tự động chuyển sang `confirmed`.
- `payment_expired_at`: timestamptz, nullable (thời hạn 15 phút cho đơn `qr_code`; quá hạn tự hủy và hoàn kho).
- `recipient_name`, `recipient_phone`, `shipping_address`: snapshot bắt buộc.
- `subtotal`: tổng giá dòng hàng trước phí ship.
- `shipping_fee`: phí ship snapshot.
- `discount_amount`: để dành cho tương lai; MVP luôn 0 và không nhận từ client.
- `total_amount`: tổng thanh toán đơn hàng; được server tính.
- `customer_note`: nullable.
- `created_at`, `updated_at`, `cancelled_at`, `delivered_at`.
Quy tắc: khách chỉ được hủy khi đơn ở `pending_confirmation`. Admin có thể hủy ở `confirmed` hoặc `preparing` (nếu hàng chưa bàn giao). `delivery_failed` không tự hoàn kho. Khi admin xác nhận đã nhận đủ hàng hoàn về kho, đơn chuyển sang `returned` và hoàn kho toàn bộ đơn (nguyên tử). Dashboard doanh thu tính trên đơn `delivered`.

### 11. `order_items`
- `id`: UUID, PK.
- `order_id`: FK `orders.id`.
- `variant_id`: FK `product_variants.id`, nullable để bảo toàn lịch sử nếu biến thể bị lưu trữ/ngừng dùng.
- `product_name_snapshot`, `sku_snapshot`, `size_snapshot`, `color_snapshot`: snapshot.
- `unit_price`: giá biến thể tại thời điểm mua.
- `quantity`: số lượng dương.
- `line_total`: `unit_price * quantity`.
Quy tắc: dòng hàng không được thay đổi bởi khách sau khi đặt; tổng đơn phải khớp tổng dòng hàng + ship − discount.

### 12. `inventory_movements`
- `id`: UUID, PK.
- `variant_id`: FK `product_variants.id`.
- `order_id`: FK `orders.id`, nullable cho điều chỉnh/restock.
- `quantity_delta`: số nguyên có dấu; âm là trừ kho, dương là cộng kho.
- `reason`: `order_created`, `order_cancelled`, `return_received`, `restock`, `adjustment`.
- `created_by`: FK `profiles.id`, nullable cho thao tác hệ thống.
- `created_at`.
Quy tắc: bảng audit append-only; không cho khách ghi trực tiếp. Mọi thay đổi tồn có movement record trong cùng transaction. `order_cancelled` áp dụng cho cả hủy bởi khách hoặc hủy bởi admin. Hoàn kho khi hàng về ghi nhận `return_received` sau khi đơn chuyển sang `returned`.

### 13. `reviews`
- `id`: UUID, PK.
- `product_id`: FK `products.id`.
- `user_id`: FK `profiles.id`.
- `order_item_id`: FK `order_items.id`.
- `rating`: integer 1–5.
- `comment`: nullable, độ dài tối đa phải được quy định trong validation.
- `is_hidden`: boolean mặc định false.
- `hidden_reason`: nullable.
- `created_at`, `updated_at`.
Ràng buộc unique `user_id + product_id`. Server xác minh order item thuộc user, đơn delivered và sản phẩm khớp. Review ẩn không hiển thị công khai/không tính vào rating công khai.

### 14. `review_reports`
- `id`: UUID, PK.
- `review_id`: FK `reviews.id`.
- `reporter_id`: FK `profiles.id`.
- `reason`: loại lý do được hỗ trợ.
- `details`: nullable.
- `status`: `pending`, `reviewed`, `dismissed`.
- `resolved_by`: FK `profiles.id`, nullable.
- `resolution_note`, `resolved_at`: nullable.
- `created_at`.
Quy tắc: report không tự ẩn review. Chống spam bằng unique hoặc giới hạn báo cáo lặp theo review/người dùng; quy tắc cụ thể cần triển khai nhất quán.

### 15. `store_settings`
- `id`: UUID, PK; chỉ một bản ghi cấu hình hoạt động.
- `store_name`: mặc định `MOVEN`.
- `logo_path`: nullable.
- `contact_email`, `contact_phone`: nullable.
- `default_shipping_fee`: VND không âm, mặc định 20000.
- `low_stock_threshold`: số nguyên không âm, mặc định 5 (ngưỡng cảnh báo tồn kho thấp cho dashboard).
- `updated_at`.
Quy tắc: chỉ admin được sửa; phí ship được snapshot vào từng đơn; singleton pattern (tối đa 1 dòng).

### 16. `order_status_history`
- `id`: UUID, PK.
- `order_id`: FK `orders.id`.
- `from_status`: trạng thái trước, nullable (NULL khi khởi tạo đơn hàng).
- `to_status`: trạng thái mới, bắt buộc (`pending_confirmation`, `confirmed`, `preparing`, `shipping`, `delivery_failed`, `delivered`, `cancelled`, `returned`).
- `actor_id`: FK `profiles.id`, bắt buộc (người thực hiện chuyển trạng thái).
- `note`: ghi chú tùy chọn (lý do hủy, lý do giao thất bại, xác nhận hoàn hàng), nullable.
- `created_at`: timestamptz, mặc định now().
Quy tắc: bảng audit append-only; mọi chuyển trạng thái đơn hàng đều bắt buộc ghi log vào bảng này trong cùng transaction qua RPC đáng tin cậy; client không được phép insert/update/delete trực tiếp.

## 3.3 Ràng buộc toàn vẹn tối thiểu
- Giá, phí ship, subtotal, total và discount không âm.
- `stock_quantity >= 0`; `quantity > 0`; `rating` trong 1–5; `low_stock_threshold >= 0`.
- SKU, slug, order_code unique.
- Một sản phẩm có một category chính.
- Một cart mỗi user; một cart item mỗi variant trong cart.
- Một review mỗi user/product.
- Chỉ các trạng thái được định nghĩa mới được lưu (`pending_confirmation`, `confirmed`, `preparing`, `shipping`, `delivery_failed`, `delivered`, `cancelled`, `returned`).
- FK lịch sử không cascade delete các order/order_items/inventory_movements/order_status_history.
- `total_amount = subtotal + shipping_fee - discount_amount`; MVP `discount_amount = 0`.
- Tồn kho được bảo vệ khỏi race condition bằng transaction/row-level locking trong RPC.
- Một địa chỉ mặc định tối đa cho mỗi user.
- Chỉ một bản ghi store_settings có hiệu lực.

## 3.4 Chỉ mục đề xuất
- Unique: `categories.slug`, `products.slug`, `product_variants.sku`, `orders.order_code`.
- Unique composite: `product_variants(product_id, size, color_name)` (sử dụng NULLS NOT DISTINCT hoặc tương đương), `cart_items(cart_id, variant_id)`, `reviews(user_id, product_id)`, `review_reports(reporter_id, review_id)`.
- Index: `products(category_id, is_active)`, `product_variants(product_id, is_active)`, `orders(user_id, created_at desc)`, `orders(status, created_at desc)`, `order_items(order_id)`, `order_status_history(order_id, created_at desc)`, `reviews(product_id, created_at desc)`, `review_reports(status, created_at)`, `inventory_movements(variant_id, created_at desc)`.
- Chỉ mục bổ sung phải dựa trên truy vấn thực tế và kế hoạch truy vấn, tránh index thừa.

## 3.5 Các quyết định đã chốt phục vụ migration
- Trạng thái nhận lại hàng: `returned`; hoàn kho toàn đơn nguyên tử khi admin xác nhận nhận đủ hàng.
- Bảng lịch sử chuyển trạng thái: `order_status_history` ghi nhận tự động qua RPC.
- Nguồn giá: `product_variants.price` là giá bán duy nhất; `compare_at_price` ở cấp biến thể; bỏ `products.base_price`.
- Thanh toán COD: tự động cập nhật `payment_status = 'paid'` khi đơn chuyển sang `delivered` (Phương án B).
- Lý do hủy đơn trong kho: `order_cancelled` áp dụng cho cả khách và admin.
- Cấp quyền admin: qua migration/console quản trị; không có API đăng ký admin.
