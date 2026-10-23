# Quyết định kỹ thuật và thiết kế dữ liệu MOVEN

## 1. Các quyết định ĐÃ CHỐT CHÍNH THỨC

| ID | Vấn đề | Quyết định đã chốt | Tác động kỹ thuật |
|---|---|---|---|
| **D-05 & D-11** | Giao thất bại & Hoàn kho | - Trạng thái đơn khi nhận lại hàng là **`returned`**.<br>- Chỉ hoàn kho khi admin xác nhận đã nhận đủ hàng về kho.<br>- Phạm vi hoàn kho: **toàn đơn**, MVP không hỗ trợ hoàn từng phần. | - Enum trạng thái đơn gồm: `pending_confirmation`, `confirmed`, `preparing`, `shipping`, `delivery_failed`, `delivered`, `cancelled`, `returned`.<br>- Bỏ trạng thái `returned_to_stock`. RPC hoàn kho xử lý toàn bộ `order_items`. |
| **D-07** | Audit chuyển trạng thái | - Bổ sung bảng **`order_status_history`** ngay trong MVP.<br>- Mọi chuyển trạng thái đơn bắt buộc qua RPC/transaction và tự động ghi log vào bảng này. | - Thêm bảng thứ 16 vào Database Spec và ERD.<br>- Lưu trữ `order_id`, `from_status`, `to_status`, `actor_id`, `note`, `created_at`. |
| **D-10** | Nguồn giá & Giá so sánh | - **Bỏ hoàn toàn** cột `products.base_price`.<br>- **`product_variants.price`** là nguồn giá bán có thẩm quyền duy nhất.<br>- **`compare_at_price`** chuyển xuống bảng `product_variants`.<br>- Giá hiển thị ở cấp sản phẩm được tính động từ biến thể (khoảng giá min-max hoặc giá "từ min"). | - Bảng `products` chỉ quản lý thông tin chung.<br>- Bảng `product_variants` chứa `price` (NOT NULL) và `compare_at_price` (nullable).<br>- Không có nguy cơ mâu thuẫn hai nguồn giá. |
| **D-06** | Xác nhận thanh toán COD | - Áp dụng **Phương án B**: Trong MVP, khi admin chuyển trạng thái đơn sang `delivered`, hệ thống tự động cập nhật `payment_status = 'paid'`. | - Đơn giản hóa vận hành cho MVP một cửa hàng; giảm thao tác thủ công cho admin.<br>- RPC chuyển trạng thái `delivered` đồng thời cập nhật `payment_status`. |
| **D-17** | Lý do hủy đơn trong kho | - Đổi giá trị `customer_cancelled` thành **`order_cancelled`** trong `inventory_movements.reason`, dùng chung cho cả khách hủy và admin hủy.<br>- Phân biệt ai hủy thông qua trường `created_by` và bảng `order_status_history`. | - `inventory_movements.reason` gồm: `order_created`, `order_cancelled`, `return_received`, `restock`, `adjustment`. |

## 2. Các quyết định chi tiết còn lại (áp dụng theo đề xuất mặc định)

| ID | Vấn đề | Đề xuất mặc định | Ghi chú |
|---|---|---|---|
| D-01 | Review comment | Tùy chọn, tối đa 1.000 ký tự; rating 1–5 bắt buộc | Validation UI/Schema |
| D-02 | Ngưỡng sắp hết hàng | Thêm `low_stock_threshold integer DEFAULT 5` vào `store_settings` | Admin cấu hình được |
| D-03 | SKU | Admin nhập SKU duy nhất cho mỗi variant; không tự sinh ở MVP | Quản trị catalog |
| D-04 | Order code | Mã dễ đọc có tiền tố `MVN-`, phần ngẫu nhiên đủ entropy; unique constraint | Hỗ trợ khách, tránh đoán đơn |
| D-08 | `store_settings` | Một dòng duy nhất được quản lý bằng cơ chế singleton | Tránh cấu hình phí ship không xác định |
| D-09 | Địa chỉ | Chuẩn hóa danh mục Tỉnh/Huyện/Xã ở client; `orders.shipping_address` lưu snapshot text kèm JSON | Form checkout và bảo toàn lịch sử |
| D-12 | Bảo vệ báo cáo review | Unique composite `(reporter_id, review_id)`; mỗi user báo cáo tối đa 1 lần/review | Chống spam |
| D-13 | Điều kiện đánh giá | Đánh giá 1 lần/user/product sau khi có đơn `delivered`; không phân theo biến thể | Khớp SRS |
| D-14 | Admin provisioning | Cấp role admin trực tiếp qua console/migration; không qua UI public | Bảo mật tuyệt đối |
| D-15 | Banner link | Allowlist internal category/product; external link chỉ cho phép https | Chống URL nguy hiểm |
| D-16 | Xóa sản phẩm/variant | Soft delete / archive (đặt `is_active=false`), không xóa cứng | Bảo toàn đơn hàng cũ |

