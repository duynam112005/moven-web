import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../cart/data/cart_providers.dart';
import '../../cart/domain/models/cart_item_model.dart';
import '../../profile/data/address_repository.dart';
import '../../profile/domain/models/address.dart';
import '../../profile/presentation/widgets/address_dialog.dart';
import '../data/checkout_providers.dart';
import 'widgets/order_success_view.dart';

/// Màn hình đặt hàng COD (Storefront Checkout Screen)
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho trường hợp nhập địa chỉ mới
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _noteController = TextEditingController();

  Address? _selectedSavedAddress;
  bool _useCustomAddress = false;
  List<Address> _userAddresses = [];
  bool _isLoadingAddresses = true;
  String? _checkoutErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressLineController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAddresses() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) setState(() => _isLoadingAddresses = false);
      return;
    }

    try {
      final repo = ref.read(addressRepositoryProvider);
      final addresses = await repo.getAddresses(user.id);
      if (mounted) {
        setState(() {
          _userAddresses = addresses;
          _isLoadingAddresses = false;
          if (addresses.isNotEmpty) {
            _selectedSavedAddress = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
            _useCustomAddress = false;
          } else {
            _useCustomAddress = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
          _useCustomAddress = true;
        });
      }
    }
  }

  void _onAddNewAddress() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final created = await showDialog<Address?>(
      context: context,
      builder: (context) => AddressDialog(userId: user.id),
    );

    if (created != null && mounted) {
      await _loadUserAddresses();
      setState(() {
        _selectedSavedAddress = created;
        _useCustomAddress = false;
      });
    }
  }

  Future<void> _handleCheckout(List<CartItemModel> items) async {
    // Giải phóng focus của bàn phím / input ngay từ đầu
    FocusScope.of(context).unfocus();
    setState(() => _checkoutErrorMessage = null);

    Map<String, dynamic> shippingAddressMap;
    String recipientName;
    String recipientPhone;
    String displayAddress;

    if (!_useCustomAddress && _selectedSavedAddress != null) {
      final a = _selectedSavedAddress!;
      recipientName = a.recipientName;
      recipientPhone = a.phone;
      displayAddress = a.formattedAddress;
      shippingAddressMap = {
        'recipient_name': a.recipientName,
        'phone': a.phone,
        'province': a.province,
        'district': a.district,
        'ward': a.ward,
        'address_line': a.addressLine,
        'formatted_address': a.formattedAddress,
      };
    } else {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
      recipientName = _nameController.text.trim();
      recipientPhone = _phoneController.text.trim();
      final line = _addressLineController.text.trim();
      final ward = _wardController.text.trim();
      final district = _districtController.text.trim();
      final province = _provinceController.text.trim();
      displayAddress = '$line, $ward, $district, $province';

      shippingAddressMap = {
        'recipient_name': recipientName,
        'phone': recipientPhone,
        'province': province,
        'district': district,
        'ward': ward,
        'address_line': line,
        'formatted_address': displayAddress,
      };
    }

    final checkoutItems = items.map((item) {
      return {
        'variant_id': item.variantId,
        'quantity': item.quantity,
      };
    }).toList();

    try {
      final result = await ref
          .read(checkoutControllerProvider.notifier)
          .submitOrder(
            shippingAddress: shippingAddressMap,
            items: checkoutItems,
            customerNote: _noteController.text.trim(),
          );

      if (result != null && mounted) {
        // Giải phóng focus của bàn phím / input ngay từ đầu
        FocusScope.of(context).unfocus();

        final targetRoute = await OrderSuccessDialog.show(
          context: context,
          result: result,
          recipientName: recipientName,
          recipientPhone: recipientPhone,
          shippingAddressText: displayAddress,
        );

        if (!mounted) return;
        ref.read(checkoutControllerProvider.notifier).reset();
        await ref.read(cartNotifierProvider.notifier).loadCart();

        if (!mounted) return;
        if (targetRoute != null && targetRoute.isNotEmpty) {
          context.go(targetRoute);
        } else {
          context.go(RouteNames.catalogPath);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkoutErrorMessage = e is AppException
              ? e.message
              : e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Material(
        color: AppColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space64),
            child: EmptyStateView(
              icon: Icons.lock_outline,
              title: 'Yêu cầu đăng nhập',
              description: 'Vui lòng đăng nhập để tiến hành đặt hàng COD.',
              actionLabel: 'Đăng nhập',
              onAction: () => context.push(RouteNames.loginPath),
            ),
          ),
        ),
      );
    }

    final cartAsync = ref.watch(cartNotifierProvider);

    return Material(
      color: AppColors.background,
      child: cartAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.space64),
          child: Center(child: AppLoading()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space64),
          child: Center(
            child: ErrorStateView(
              message: err.toString(),
              onRetry: () => ref.read(cartNotifierProvider.notifier).loadCart(),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.space64),
                child: EmptyStateView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Giỏ hàng đang trống',
                  description: 'Bạn chưa có sản phẩm nào để tiến hành thanh toán.',
                  actionLabel: 'Mua sắm ngay',
                  onAction: () => context.go(RouteNames.catalogPath),
                ),
              ),
            );
          }

          final subtotal = ref.watch(cartSubtotalProvider);
          final shippingFeeAsync = ref.watch(defaultShippingFeeProvider);
          final shippingFee = shippingFeeAsync.valueOrNull ?? 20000;
          final totalAmount = subtotal + shippingFee;
          final checkoutState = ref.watch(checkoutControllerProvider);
          final isSubmitting = checkoutState.isLoading;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop =
                  constraints.maxWidth >= AppDimensions.tabletBreakpoint;
              if (isDesktop) {
                return _buildDesktopCheckout(
                  context,
                  items,
                  subtotal,
                  shippingFee,
                  totalAmount,
                  isSubmitting,
                );
              }
              return _buildMobileCheckout(
                context,
                items,
                subtotal,
                shippingFee,
                totalAmount,
                isSubmitting,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopCheckout(
    BuildContext context,
    List<CartItemModel> items,
    int subtotal,
    int shippingFee,
    int totalAmount,
    bool isSubmitting,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space32,
        vertical: AppDimensions.space32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  const Text(
                    'Thanh toán COD',
                    style: AppTypography.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShippingAddressSection(),
                        const SizedBox(height: AppDimensions.space24),
                        _buildCustomerNoteSection(),
                        const SizedBox(height: AppDimensions.space24),
                        _buildPaymentMethodSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space32),
                  Expanded(
                    flex: 2,
                    child: _buildOrderReviewCard(
                      items,
                      subtotal,
                      shippingFee,
                      totalAmount,
                      isSubmitting,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCheckout(
    BuildContext context,
    List<CartItemModel> items,
    int subtotal,
    int shippingFee,
    int totalAmount,
    bool isSubmitting,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppDimensions.space8),
              const Text(
                'Thanh toán COD',
                style: AppTypography.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          _buildShippingAddressSection(),
          const SizedBox(height: AppDimensions.space16),
          _buildCustomerNoteSection(),
          const SizedBox(height: AppDimensions.space16),
          _buildPaymentMethodSection(),
          const SizedBox(height: AppDimensions.space24),
          _buildOrderReviewCard(
            items,
            subtotal,
            shippingFee,
            totalAmount,
            isSubmitting,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.primary),
                  SizedBox(width: AppDimensions.space8),
                  Text('Địa chỉ giao hàng', style: AppTypography.titleLarge),
                ],
              ),
              if (_userAddresses.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm mới'),
                  onPressed: _onAddNewAddress,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          if (_isLoadingAddresses)
            const Center(child: AppLoading())
          else if (_userAddresses.isNotEmpty && !_useCustomAddress) ...[
            for (final addr in _userAddresses)
              Builder(
                builder: (context) {
                  final isSelected = _selectedSavedAddress?.id == addr.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedSavedAddress = addr),
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimensions.radius8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.04)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.recipientName,
                                      style: AppTypography.titleMedium,
                                    ),
                                    const SizedBox(width: AppDimensions.space8),
                                    Text(
                                      addr.phone,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    if (addr.isDefault) ...[
                                      const SizedBox(width: AppDimensions.space8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Mặc định',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.space4),
                                Text(
                                  addr.formattedAddress,
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            TextButton(
              onPressed: () => setState(() => _useCustomAddress = true),
              child: const Text('Nhập địa chỉ giao hàng khác'),
            ),
          ] else ...[
            if (_userAddresses.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _useCustomAddress = false),
                child: const Text('← Chọn từ sổ địa chỉ đã lưu'),
              ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên người nhận *',
                            hintText: 'Nguyễn Văn A',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Vui lòng nhập tên'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại *',
                            hintText: '0901234567',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().length < 9)
                                  ? 'Số điện thoại không hợp lệ'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(
                            labelText: 'Tỉnh / Thành phố *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Bắt buộc'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: TextFormField(
                          controller: _districtController,
                          decoration: const InputDecoration(
                            labelText: 'Quận / Huyện *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Bắt buộc'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: TextFormField(
                          controller: _wardController,
                          decoration: const InputDecoration(
                            labelText: 'Phường / Xã *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Bắt buộc'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  TextFormField(
                    controller: _addressLineController,
                    decoration: const InputDecoration(
                      labelText: 'Số nhà, tên đường *',
                      hintText: 'Số 123 Đường Nguyễn Trãi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập địa chỉ cụ thể'
                            : null,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerNoteSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_outlined, color: AppColors.primary),
              SizedBox(width: AppDimensions.space8),
              Text('Ghi chú cho đơn hàng', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Giao giờ hành chính, gọi trước khi giao...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.primary),
              SizedBox(width: AppDimensions.space8),
              Text('Phương thức thanh toán', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary),
                SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thanh toán khi nhận hàng (COD)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bạn chỉ cần thanh toán tiền mặt cho nhân viên giao hàng khi đã nhận và kiểm tra hàng.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderReviewCard(
    List<CartItemModel> items,
    int subtotal,
    int shippingFee,
    int totalAmount,
    bool isSubmitting,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kiểm tra đơn hàng', style: AppTypography.titleLarge),
          const SizedBox(height: AppDimensions.space16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: AppDimensions.space16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 48,
                      height: 58,
                      color: AppColors.surfaceVariant,
                      child: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.checkroom_outlined,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            )
                          : const Icon(
                              Icons.checkroom_outlined,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.displayVariantLabel} x ${item.quantity}',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.lineTotal),
                    style: AppTypography.titleMedium,
                  ),
                ],
              );
            },
          ),

          const Divider(height: AppDimensions.space24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Tạm tính:', style: AppTypography.bodyMedium),
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(subtotal),
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Phí giao hàng COD:', style: AppTypography.bodyMedium),
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(shippingFee),
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Tổng thanh toán:', style: AppTypography.titleMedium),
              ),
              const SizedBox(width: AppDimensions.space8),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(totalAmount),
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space20),

          if (_checkoutErrorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      _checkoutErrorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
          ],

          AppButton(
            label: isSubmitting ? 'Đang xử lý...' : 'Xác nhận đặt hàng COD',
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 18),
            isFullWidth: true,
            height: AppDimensions.buttonHeightLg,
            onPressed: isSubmitting ? null : () => _handleCheckout(items),
          ),
        ],
      ),
    );
  }
}
