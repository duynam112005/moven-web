/// Mô hình hồ sơ người dùng trong hệ thống MOVEN.
///
/// Tương ứng với bảng `public.profiles` trong cơ sở dữ liệu Supabase.
class UserProfile {
  final String id;
  final String fullName;
  final String? phone;
  final String role; // 'customer' hoặc 'admin'
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    required this.role,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  /// Tạo UserProfile từ Map JSON trả về từ Supabase
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      phone: json['phone'] as String?,
      role: (json['role'] as String?) ?? 'customer',
      avatarPath: json['avatar_path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Chuyển sang JSON để cập nhật thông tin cá nhân.
  /// LƯU Ý BẢO MẬT: Tuyệt đối KHÔNG bao gồm `role` hoặc `id` trong payload cập nhật từ client.
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      if (avatarPath != null) 'avatar_path': avatarPath,
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? role,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          phone == other.phone &&
          role == other.role &&
          avatarPath == other.avatarPath;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      phone.hashCode ^
      role.hashCode ^
      avatarPath.hashCode;
}
