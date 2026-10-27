# MOVEN — Nền Tảng Thương Mại Điện Tử Thời Trang Nam (Single-Store Web)

MOVEN là ứng dụng web thương mại điện tử chuyên biệt cho một cửa hàng thời trang nam, được thiết kế theo phong cách tối giản, hiện đại (Coolmate-style minimalism), tương phản thị giác cao và tích hợp các vi tương tác/chuyển động mượt mà (150ms–350ms natural curves).

---

## 1. Công nghệ phê chuẩn (Approved Tech Stack)

- **Frontend**: Flutter Web / Dart SDK.
- **Quản lý trạng thái (State Management)**: Flutter Riverpod.
- **Điều hướng (Routing)**: GoRouter (hỗ trợ Web URL path-based, deep linking và route guards).
- **Mô hình dữ liệu bất biến (Immutable Models)**: Freezed + `json_serializable` (thông qua `build_runner`).
- **Backend & Cơ sở dữ liệu**: Supabase PostgreSQL.
- **Xác thực (Authentication)**: Supabase Auth (hỗ trợ email verification và password recovery).
- **Lưu trữ tệp (Storage)**: Supabase Storage Buckets (bảo mật qua Storage RLS Policies).
- **Nghiệp vụ cốt lõi & Giao dịch an toàn**: Trusted PostgreSQL Functions/RPCs (Security Definer) và Row-Level Security (RLS). Không sử dụng Node.js, SQL Server, MySQL hay thanh toán trực tuyến trong phạm vi MVP.

---

## 2. Các quy tắc & Bất biến cốt lõi (Core Business Invariants)

1. **Phương thức thanh toán**: Chỉ áp dụng hình thức **Thanh toán khi nhận hàng (COD)**. Tuyệt đối không tích hợp cổng thanh toán trực tuyến trong MVP.
2. **Phí vận chuyển**: Cấu hình phí ship mặc định là **20.000 VNĐ** (Admin có thể điều chỉnh tại màn hình Cài đặt cửa hàng). Phí ship được lưu cố định (**snapshot**) bất biến vào từng đơn hàng tại thời điểm khách đặt hàng.
3. **Quản lý tồn kho**: Giá và số lượng tồn kho của từng biến thể (`product_variants`) mang tính quyết định tối cao. Trừ kho nguyên tử (atomic decrement) và ghi log biến động kho (`inventory_movements`) trong cùng một giao dịch database qua RPC đáng tin cậy.
4. **Vận chuyển & Hoàn kho**:
   - Quản trị viên cập nhật trạng thái vận chuyển thủ công; không kết nối API nhà vận chuyển trong MVP.
   - Trạng thái `delivery_failed` (giao thất bại) **không đồng nghĩa với việc hàng đã hoàn về kho**.
   - Chỉ hoàn kho khi Quản trị viên vật lý xác nhận đã nhận lại hàng nguyên vẹn từ shipper (chuyển trạng thái sang **`returned`**).
5. **Số liệu Doanh thu Dashboard**: Doanh thu chỉ được tính trên tổng giá trị của các đơn hàng đã giao thành công (**`status = 'delivered'`**). Tuyệt đối không cộng dồn các đơn bị hủy (`cancelled`) hoặc giao thất bại (`delivery_failed`). Múi giờ chuẩn: `Asia/Ho_Chi_Minh` (UTC+7).
6. **Đánh giá & Kiểm duyệt sản phẩm**:
   - Mỗi khách hàng chỉ được gửi tối đa **1 đánh giá** cho mỗi sản phẩm (Unique composite `user_id + product_id`).
   - Khách hàng chỉ đủ điều kiện đánh giá sau khi đã có đơn hàng giao thành công (**`delivered`**) chứa sản phẩm đó.
   - Báo cáo vi phạm từ khách hàng chỉ tạo bản ghi chờ duyệt (`pending`), **không tự động ẩn đánh giá**.
   - Đánh giá bị ẩn (`is_hidden = true`) bị loại trừ hoàn toàn khỏi trang công khai và không tính vào điểm số/phân bổ sao trung bình.
7. **Phạm vi loại trừ trong MVP**: Không có mã giảm giá (coupons), không có chợ nhiều người bán (marketplace), không có quy trình tự đổi trả hàng/hoàn tiền tự động.

---

## 3. Cấu trúc mã nguồn (Project Architecture)

Dự án được tổ chức theo kiến trúc **Feature-First**:

```text
lib/
├── app/                        # Cấu hình gốc MaterialApp, theme, global observer
├── core/                       # Thành phần dùng chung toàn hệ thống
│   ├── constants/              # Design tokens: AppColors, AppDimensions, AppTypography
│   ├── network/                # Supabase client singleton provider
│   ├── router/                 # GoRouter, RouteNames, Route Guards
│   ├── utils/                  # CurrencyFormatter, ResponsiveLayout
│   └── widgets/                # AppButton, AppLoading, EmptyStateView, ErrorStateView
└── features/                   # Các module tính năng chuyên biệt
    ├── admin/                  # Quản trị viên: Dashboard, Catalog, Banners, Orders, Reviews, Settings
    ├── auth/                   # Đăng nhập, đăng ký, xác thực email, quên mật khẩu
    ├── cart/                   # Giỏ hàng phía khách hàng
    ├── catalog/                # Duyệt danh mục, tìm kiếm, lọc sản phẩm
    ├── checkout/               # Đặt hàng COD, snapshot thông tin & địa chỉ
    ├── home/                   # Trang chủ, Banner carousel, Danh mục nổi bật
    ├── orders/                 # Quản lý đơn hàng khách hàng & Admin fulfillment
    ├── product_detail/         # Chi tiết sản phẩm, chọn biến thể, đánh giá
    ├── profile/                # Quản lý thông tin cá nhân & sổ địa chỉ
    ├── reviews/                # Đánh giá sản phẩm, báo cáo vi phạm & kiểm duyệt
    ├── settings/               # Cấu hình cửa hàng Singleton & phí ship
    └── static_pages/           # Chính sách giao hàng, đổi trả thủ công, liên hệ
```

---

## 4. Tài liệu quyết định kiến trúc (ADRs)

Toàn bộ các quyết định kỹ thuật then chốt được ghi nhận tại thư mục `docs/adr/`:
- [ADR-0001: Order State Machine and Restocking Invariants](docs/adr/0001-order-state-machine-and-restocking.md)
- [ADR-0002: Customer Order Cancellation Window](docs/adr/0002-customer-order-cancellation-window.md)
- [ADR-0003: Administrative Restocking Confirmation](docs/adr/0003-administrative-restocking-confirmation.md)
- [ADR-0004: Product Reviews and Moderation Architecture](docs/adr/0004-product-reviews-and-moderation.md)
- [ADR-0005: Store Settings, Shipping Fee, and Dashboard Metrics](docs/adr/0005-store-settings-and-dashboard-metrics.md)
- [ADR-0006: Admin Inventory Management, Catalog Synchronization, and Audit Trail](docs/adr/0006-admin-inventory-and-management.md)

---

## 5. Hướng dẫn khởi chạy & Phát triển (Getting Started)

### Cài đặt môi trường
- Flutter SDK `>=3.3.0`
- Chrome Browser (cho Flutter Web)

### Cài đặt thư viện dependencies
```bash
flutter pub get
```

### Sinh mã Freezed & JSON Serializer
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Khởi chạy ứng dụng Web
```bash
flutter run -d chrome
```

### Chạy bộ kiểm thử tự động (Automated Test Suite)
Dự án được bảo vệ bởi **120 test cases tự động** (bao gồm Unit tests cho Domain Models, Repositories và Widget tests cho Storefront & Admin):
```bash
flutter test
```
*Kết quả xác nhận: 120/120 tests pass (exit code 0).*
