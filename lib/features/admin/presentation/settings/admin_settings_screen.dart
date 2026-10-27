import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/core/constants/app_colors.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/core/constants/app_typography.dart';
import 'package:moven/core/widgets/app_button.dart';
import 'package:moven/core/widgets/app_loading.dart';
import 'package:moven/features/settings/domain/models/store_settings.dart';
import 'package:moven/features/settings/presentation/providers/settings_providers.dart';

/// Màn hình Cài đặt Cửa hàng & Phí vận chuyển của Quản trị viên
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _shippingFeeController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isInitialized = false;

  @override
  void dispose() {
    _shippingFeeController.dispose();
    _thresholdController.dispose();
    _storeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFields(StoreSettings settings) {
    if (!_isInitialized) {
      _shippingFeeController.text = settings.defaultShippingFee.toString();
      _thresholdController.text = settings.lowStockThreshold.toString();
      _storeNameController.text = settings.storeName;
      _emailController.text = settings.contactEmail;
      _phoneController.text = settings.contactPhone;
      _isInitialized = true;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final shippingFee = int.tryParse(_shippingFeeController.text.trim()) ?? 20000;
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 5;
    final storeName = _storeNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final success = await ref
        .read(adminSettingsControllerProvider.notifier)
        .updateSettings(
          defaultShippingFee: shippingFee,
          lowStockThreshold: threshold,
          storeName: storeName,
          contactEmail: email,
          contactPhone: phone,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('✓ Đã cập nhật cài đặt cửa hàng thành công!'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      final err = ref.read(adminSettingsControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Lỗi: ${err ?? "Không thể lưu cài đặt."}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(storeSettingsProvider);
    final actionState = ref.watch(adminSettingsControllerProvider);
    final isLoading = actionState.isLoading;

    return settingsAsync.when(
      loading: () => const Center(
        child: AppLoading(message: 'Đang tải cấu hình cửa hàng...'),
      ),
      error: (err, _) => Center(
        child: Text(
          'Không thể tải cài đặt: $err',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (settings) {
        _populateFields(settings);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Cài đặt Cửa hàng',
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    'Quản lý phí giao hàng COD, ngưỡng cảnh báo tồn kho và thông tin liên hệ cửa hàng.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // Section 1: Phí vận chuyển COD
                  _buildSectionCard(
                    title: '1. Vận chuyển & Thanh toán COD',
                    icon: Icons.local_shipping_outlined,
                    children: [
                      TextFormField(
                        controller: _shippingFeeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Phí giao hàng mặc định (VND)',
                          suffixText: 'VNĐ',
                          hintText: '20000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                          helperText:
                              'Áp dụng cố định cho mọi đơn hàng COD và được lưu cố định (snapshot) vào từng đơn hàng khi khách đặt.',
                          helperMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập phí vận chuyển mặc định';
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Phí vận chuyển phải là số không âm';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // Section 2: Cảnh báo Tồn kho thấp (Low stock)
                  _buildSectionCard(
                    title: '2. Quản lý Kho & Cảnh báo Tồn kho',
                    icon: Icons.inventory_2_outlined,
                    children: [
                      TextFormField(
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Ngưỡng cảnh báo sắp hết hàng (Low Stock Threshold)',
                          suffixText: 'sản phẩm',
                          hintText: '5',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                          helperText:
                              'Các biến thể có số lượng tồn kho nhỏ hơn hoặc bằng ngưỡng này sẽ hiển thị cảnh báo đỏ trên Dashboard.',
                          helperMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập ngưỡng tồn kho';
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Ngưỡng tồn kho phải là số không âm';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // Section 3: Thông tin Cửa hàng
                  _buildSectionCard(
                    title: '3. Thông tin Liên hệ Cửa hàng',
                    icon: Icons.storefront_outlined,
                    children: [
                      TextFormField(
                        controller: _storeNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên cửa hàng',
                          hintText: 'MOVEN CLOTHING',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radius8),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email hỗ trợ',
                                hintText: 'contact@moven.vn',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppDimensions.radius8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Hotline liên hệ',
                                hintText: '0901234567',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppDimensions.radius8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space32),

                  // Save Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        label: 'Lưu thay đổi cài đặt',
                        icon: const Icon(Icons.check_rounded, size: 18),
                        isLoading: isLoading,
                        onPressed: _handleSave,
                        height: 48,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          ...children,
        ],
      ),
    );
  }
}
