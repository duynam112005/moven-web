import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moven/features/profile/data/address_repository.dart';
import 'package:moven/features/profile/domain/models/address.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';

/// Dialog thêm hoặc chỉnh sửa địa chỉ giao hàng
class AddressDialog extends ConsumerStatefulWidget {
  final String userId;
  final Address? existingAddress;

  const AddressDialog({
    super.key,
    required this.userId,
    this.existingAddress,
  });

  @override
  ConsumerState<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends ConsumerState<AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipientNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  late final TextEditingController _addressLineController;
  bool _isDefault = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    _recipientNameController =
        TextEditingController(text: a?.recipientName ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _provinceController = TextEditingController(text: a?.province ?? '');
    _districtController = TextEditingController(text: a?.district ?? '');
    _wardController = TextEditingController(text: a?.ward ?? '');
    _addressLineController =
        TextEditingController(text: a?.addressLine ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressLineController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(addressRepositoryProvider);

      if (_isEditing) {
        final updated = widget.existingAddress!.copyWith(
          recipientName: _recipientNameController.text.trim(),
          phone: _phoneController.text.trim(),
          province: _provinceController.text.trim(),
          district: _districtController.text.trim(),
          ward: _wardController.text.trim(),
          addressLine: _addressLineController.text.trim(),
          isDefault: _isDefault,
        );
        await repo.updateAddress(updated);
      } else {
        final newAddress = Address(
          id: '', // Will be set by DB
          userId: widget.userId,
          recipientName: _recipientNameController.text.trim(),
          phone: _phoneController.text.trim(),
          province: _provinceController.text.trim(),
          district: _districtController.text.trim(),
          ward: _wardController.text.trim(),
          addressLine: _addressLineController.text.trim(),
          isDefault: _isDefault,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.addAddress(newAddress);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Không thể lưu địa chỉ. Vui lòng thử lại.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding:
                                const EdgeInsets.all(AppDimensions.space12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radius8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.error),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),
                        ],

                        // Recipient name
                        TextFormField(
                          controller: _recipientNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên người nhận *',
                            prefixIcon:
                                Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Vui lòng nhập họ tên người nhận'
                                  : null,
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại *',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (!RegExp(r'^(0|\+84)\d{9,10}$')
                                .hasMatch(value.trim())) {
                              return 'Số điện thoại không đúng định dạng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // Province
                        TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(
                            labelText: 'Tỉnh / Thành phố *',
                            prefixIcon:
                                Icon(Icons.location_city_outlined, size: 20),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Vui lòng nhập tỉnh/thành phố'
                                  : null,
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // District
                        TextFormField(
                          controller: _districtController,
                          decoration: const InputDecoration(
                            labelText: 'Quận / Huyện *',
                            prefixIcon:
                                Icon(Icons.map_outlined, size: 20),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Vui lòng nhập quận/huyện'
                                  : null,
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // Ward
                        TextFormField(
                          controller: _wardController,
                          decoration: const InputDecoration(
                            labelText: 'Phường / Xã *',
                            prefixIcon:
                                Icon(Icons.place_outlined, size: 20),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Vui lòng nhập phường/xã'
                                  : null,
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // Address line
                        TextFormField(
                          controller: _addressLineController,
                          decoration: const InputDecoration(
                            labelText: 'Số nhà, tên đường *',
                            prefixIcon:
                                Icon(Icons.home_outlined, size: 20),
                            hintText: 'VD: 123 Đường Lê Lợi',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Vui lòng nhập số nhà và tên đường'
                                  : null,
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // Is default
                        CheckboxListTile(
                          value: _isDefault,
                          onChanged: (v) =>
                              setState(() => _isDefault = v ?? false),
                          title: const Text('Đặt làm địa chỉ mặc định'),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),

                        const SizedBox(height: AppDimensions.space16),
                        AppButton(
                          label: _isEditing ? 'Cập nhật' : 'Thêm địa chỉ',
                          isLoading: _isSaving,
                          isFullWidth: true,
                          onPressed: _handleSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
