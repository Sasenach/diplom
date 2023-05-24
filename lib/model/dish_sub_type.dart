// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DishSubType {
  int id;
  String name;
  int? parentDishTypeId;
  DishSubType({
    required this.id,
    required this.name,
    this.parentDishTypeId,
  });

  DishSubType copyWith({
    int? id,
    String? name,
    int? parentDishTypeId,
  }) {
    return DishSubType(
      id: id ?? this.id,
      name: name ?? this.name,
      parentDishTypeId: parentDishTypeId ?? this.parentDishTypeId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'parentDishTypeId': parentDishTypeId,
    };
  }

  factory DishSubType.fromMap(Map<String, dynamic> map) {
    return DishSubType(
      id: map['id'] as int,
      name: map['name'] as String,
      parentDishTypeId: map['parentDishTypeId'] != null
          ? map['parentDishTypeId'] as int
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DishSubType.fromJson(String source) =>
      DishSubType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DishSubType(id: $id, name: $name, parentDishTypeId: $parentDishTypeId)';

  @override
  bool operator ==(covariant DishSubType other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.parentDishTypeId == parentDishTypeId;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ parentDishTypeId.hashCode;
}
