// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DishType {
  int id;
  String name;

  DishType({
    required this.id,
    required this.name,
  });

  DishType copyWith({
    int? id,
    String? name,
  }) {
    return DishType(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory DishType.fromMap(Map<String, dynamic> map) {
    return DishType(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DishType.fromJson(String source) => DishType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DishType(id: $id, name: $name)';

  @override
  bool operator ==(covariant DishType other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
