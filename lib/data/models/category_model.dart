/// Category data model
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  /// Create from database map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      description: map['description'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }

  /// Copy with new values
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
