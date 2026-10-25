import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/features/auth/data/auth_repository.dart';
import 'package:moven/features/auth/domain/models/user_profile.dart';
import 'package:moven/features/profile/data/address_repository.dart';
import 'package:moven/features/profile/data/profile_repository.dart';
import 'package:moven/features/profile/domain/models/address.dart';
import 'package:moven/features/profile/presentation/widgets/address_dialog.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';

/// Provider nạp danh sách địa chỉ của người dùng hiện tại
final userAddressesProvider =
    FutureProvider.autoDispose<List<Address>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(addressRepositoryProvider);
  return repo.getAddresses(user.id);
});

/// Màn hình hồ sơ cá nhân — xem và chỉnh sửa thông tin, quản lý địa chỉ
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditingProfile = false;
  bool _isSavingProfile = false;
  String? _profileError;
  String? _profileSuccess;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startEditing(UserProfile profile) {
    _fullNameController.text = profile.fullName;
    _phoneController.text = profile.phone ?? '';
    setState(() {
      _isEditingProfile = true;
      _profileError = null;
      _profileSuccess = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditingProfile = false;
      _profileError = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isSavingProfile = true;
      _profileError = null;
    });

    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            userId: user.id,
            fullName: _fullNameController.text,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
      // Invalidate profile cache so header and other providers refresh
      ref.invalidate(userProfileProvider);
      if (mounted) {
        setState(() {
          _isEditingProfile = false;
          _isSavingProfile = false;
          _profileSuccess = 'Hồ sơ đã được cập nhật thành công.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
          _profileError = 'Không thể cập nhật hồ sơ. Vui lòng thử lại.';
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(userProfileProvider);
      if (mounted) context.go(RouteNames.homePath);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng xuất không thành công.')),
        );
      }
    }
  }

  Future<void> _showAddressDialog({Address? address}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AddressDialog(
        userId: user.id,
        existingAddress: address,
      ),
    );

    if (saved == true && mounted) {
      ref.invalidate(userAddressesProvider);
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(addressRepositoryProvider).deleteAddress(address.id);
        ref.invalidate(userAddressesProvider);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể xóa địa chỉ.')),
          );
        }
      }
    }
  }

  Future<void> _setDefaultAddress(Address address) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(addressRepositoryProvider).setDefaultAddress(
            userId: user.id,
            addressId: address.id,
          );
      ref.invalidate(userAddressesProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đặt địa chỉ mặc định.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final addressesAsync = ref.watch(userAddressesProvider);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space32,
            ),
            child: profileAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('Không thể tải hồ sơ. Vui lòng thử lại.'),
              ),
              data: (profile) {
                if (profile == null) {
                  return const Center(
                    child: Text('Không tìm thấy thông tin tài khoản.'),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile section
                    _buildProfileCard(profile),
                    const SizedBox(height: AppDimensions.space32),

                    // Address section
                    _buildAddressSection(addressesAsync),
                    const SizedBox(height: AppDimensions.space32),

                    // Sign out
                    Center(
                      child: TextButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
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
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text(
                  profile.fullName.isNotEmpty
                      ? profile.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fullName, style: AppTypography.headlineMedium),
                    if (profile.phone != null && profile.phone!.isNotEmpty)
                      Text(profile.phone!, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              if (!_isEditingProfile)
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _startEditing(profile),
                ),
            ],
          ),

          if (_profileSuccess != null) ...[
            const SizedBox(height: AppDimensions.space16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Text(
                _profileSuccess!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
              ),
            ),
          ],

          if (_isEditingProfile) ...[
            const SizedBox(height: AppDimensions.space24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_profileError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radius8),
                      ),
                      child: Text(
                        _profileError!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],
                  TextFormField(
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên *',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Vui lòng nhập họ và tên'
                            : null,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!RegExp(r'^(0|\+84)\d{9,10}$')
                            .hasMatch(value.trim())) {
                          return 'Số điện thoại không đúng định dạng';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSavingProfile ? null : _cancelEditing,
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: AppButton(
                          label: 'Lưu',
                          isLoading: _isSavingProfile,
                          isFullWidth: true,
                          onPressed: _saveProfile,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressSection(AsyncValue<List<Address>> addressesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sổ địa chỉ', style: AppTypography.headlineMedium),
            TextButton.icon(
              onPressed: () => _showAddressDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm địa chỉ'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        addressesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Text('Không thể tải địa chỉ.'),
          data: (addresses) {
            if (addresses.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppDimensions.space24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radius12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Chưa có địa chỉ giao hàng nào. Thêm địa chỉ để mua hàng nhanh hơn.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  ),
                ),
              );
            }
            return Column(
              children: addresses
                  .map((a) => _buildAddressTile(a))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddressTile(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color:
              address.isDefault ? AppColors.primary : AppColors.border,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.recipientName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius8),
                  ),
                  child: const Text(
                    'Mặc định',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(address.phone, style: AppTypography.bodySmall),
          const SizedBox(height: AppDimensions.space4),
          Text(address.formattedAddress, style: AppTypography.bodySmall),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              if (!address.isDefault)
                TextButton(
                  onPressed: () => _setDefaultAddress(address),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32)),
                  child: const Text('Đặt mặc định'),
                ),
              if (!address.isDefault)
                const SizedBox(width: AppDimensions.space8),
              TextButton(
                onPressed: () => _showAddressDialog(address: address),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32)),
                child: const Text('Sửa'),
              ),
              const SizedBox(width: AppDimensions.space8),
              TextButton(
                onPressed: () => _deleteAddress(address),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
