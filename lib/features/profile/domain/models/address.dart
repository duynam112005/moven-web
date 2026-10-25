/// Mô hình địa chỉ giao hàng của khách hàng trong hệ thống MOVEN.
///
/// Tương ứng với bảng `public.addresses` trong cơ sở dữ liệu Supabase.
class Address {
  final String id;
  final String userId;
  final String recipientName;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String addressLine;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.addressLine,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Địa chỉ hoàn chỉnh nối các cấp hành chính
  String get formattedAddress => '$addressLine, $ward, $district, $province';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipientName: (json['recipient_name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      province: (json['province'] as String?) ?? '',
      district: (json['district'] as String?) ?? '',
      ward: (json['ward'] as String?) ?? '',
      addressLine: (json['address_line'] as String?) ?? '',
      isDefault: (json['is_default'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'recipient_name': recipientName,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'address_line': addressLine,
      'is_default': isDefault,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'recipient_name': recipientName,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'address_line': addressLine,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? recipientName,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? addressLine,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      addressLine: addressLine ?? this.addressLine,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          recipientName == other.recipientName &&
          phone == other.phone &&
          province == other.province &&
          district == other.district &&
          ward == other.ward &&
          addressLine == other.addressLine &&
          isDefault == other.isDefault;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      recipientName.hashCode ^
      phone.hashCode ^
      province.hashCode ^
      district.hashCode ^
      ward.hashCode ^
      addressLine.hashCode ^
      isDefault.hashCode;
}
