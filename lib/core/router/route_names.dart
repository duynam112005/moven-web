/// Định danh đường dẫn (path) và tên (name) của tất cả route trong MOVEN
class RouteNames {
  RouteNames._();

  // Public Routes
  static const String home = 'home';
  static const String homePath = '/';

  static const String catalog = 'catalog';
  static const String catalogPath = '/catalog';

  static const String productDetail = 'product_detail';
  static const String productDetailPath = '/product/:slug';

  static const String contact = 'contact';
  static const String contactPath = '/contact';

  static const String shippingPolicy = 'shipping_policy';
  static const String shippingPolicyPath = '/shipping-policy';

  static const String returnPolicy = 'return_policy';
  static const String returnPolicyPath = '/return-policy';

  // Auth Routes
  static const String login = 'login';
  static const String loginPath = '/login';

  static const String register = 'register';
  static const String registerPath = '/register';

  static const String forgotPassword = 'forgot_password';
  static const String forgotPasswordPath = '/forgot-password';

  static const String resetPassword = 'reset_password';
  static const String resetPasswordPath = '/reset-password';

  // Customer Routes (Yêu cầu đăng nhập)
  static const String cart = 'cart';
  static const String cartPath = '/cart';

  static const String checkout = 'checkout';
  static const String checkoutPath = '/checkout';

  static const String orders = 'orders';
  static const String ordersPath = '/orders';

  static const String orderDetail = 'order_detail';
  static const String orderDetailPath = '/orders/:code';

  static const String profile = 'profile';
  static const String profilePath = '/profile';

  static const String addresses = 'addresses';
  static const String addressesPath = '/addresses';

  // Admin Routes (Yêu cầu vai trò Admin)
  static const String adminDashboard = 'admin_dashboard';
  static const String adminDashboardPath = '/admin';

  static const String adminCatalog = 'admin_catalog';
  static const String adminCatalogPath = '/admin/catalog';

  static const String adminInventory = 'admin_inventory';
  static const String adminInventoryPath = '/admin/inventory';

  static const String adminOrders = 'admin_orders';
  static const String adminOrdersPath = '/admin/orders';

  static const String adminBanners = 'admin_banners';
  static const String adminBannersPath = '/admin/banners';

  static const String adminReviews = 'admin_reviews';
  static const String adminReviewsPath = '/admin/reviews';

  static const String adminSettings = 'admin_settings';
  static const String adminSettingsPath = '/admin/settings';
}
