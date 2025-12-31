import 'dart:convert';

/// User data model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String role; // 'buyer' or 'seller'
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    required this.role,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if user is a seller
  bool get isSeller => role == 'seller';

  /// Check if user is a buyer
  bool get isBuyer => role == 'buyer';

  /// Create from database map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      role: map['role'] as String,
      avatar: map['avatar'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'role': role,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJson() => json.encode(toMap());

  /// Create from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Copy with new values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? role,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
