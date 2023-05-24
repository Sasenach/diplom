// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ToDo {
  int id;
  String toDo;
  ToDo({
    required this.id,
    required this.toDo,
  });

  ToDo copyWith({
    int? id,
    String? toDo,
  }) {
    return ToDo(
      id: id ?? this.id,
      toDo: toDo ?? this.toDo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'toDo': toDo,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'] as int,
      toDo: map['toDo'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ToDo.fromJson(String source) => ToDo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ToDo(id: $id, toDo: $toDo)';

  @override
  bool operator ==(covariant ToDo other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.toDo == toDo;
  }

  @override
  int get hashCode => id.hashCode ^ toDo.hashCode;
}
