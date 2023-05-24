// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Employee {
  int? id;
  String? surname;
  String? name;
  String? password;
  String? accessLevel;
  Employee({
    this.id,
    this.surname,
    this.name,
    this.password,
    this.accessLevel,
  });

  Employee copyWith({
    int? id,
    String? surname,
    String? name,
    String? password,
    String? accessLevel,
  }) {
    return Employee(
      id: id ?? this.id,
      surname: surname ?? this.surname,
      name: name ?? this.name,
      password: password ?? this.password,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'surname': surname,
      'name': name,
      'password': password,
      'accessLevel': accessLevel,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] != null ? map['id'] as int : null,
      surname: map['surname'] != null ? map['surname'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      accessLevel: map['accessLevel'] != null ? map['accessLevel'] as String : null,
    );
  }
  String toJson() => json.encode(toMap());

  factory Employee.fromJson(String source) => Employee.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Employee(id: $id, surname: $surname, name: $name, password: $password, accessLevel: $accessLevel)';
  }

  @override
  bool operator ==(covariant Employee other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.surname == surname &&
      other.name == name &&
      other.password == password &&
      other.accessLevel == accessLevel;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      surname.hashCode ^
      name.hashCode ^
      password.hashCode ^
      accessLevel.hashCode;
  }
}
