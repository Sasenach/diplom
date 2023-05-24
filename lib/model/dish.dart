// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Dish {
  int? id;
  int? cost;
  String? name;
  String? photoUrl;
  bool? status;
  Dish({
    this.id,
    this.cost,
    this.name,
    this.photoUrl,
    this.status,
  });


  Dish copyWith({
    int? id,
    int? cost,
    String? name,
    String? photoUrl,
    bool? status,
  }) {
    return Dish(
      id: id ?? this.id,
      cost: cost ?? this.cost,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cost': cost,
      'name': name,
      'photoUrl': photoUrl,
      'status': status,
    };
  }

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] != null ? map['id'] as int : null,
      cost: map['cost'] != null ? map['cost'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      status: map['status'] != null ? map['status'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Dish.fromJson(String source) => Dish.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Dish(id: $id, cost: $cost, name: $name, photoUrl: $photoUrl, status: $status)';
  }

  @override
  bool operator ==(covariant Dish other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.cost == cost &&
      other.name == name &&
      other.photoUrl == photoUrl &&
      other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      cost.hashCode ^
      name.hashCode ^
      photoUrl.hashCode ^
      status.hashCode;
  }
}
