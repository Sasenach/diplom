// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Chekk {
  int? id;
  DateTime? curentDate;
  double? amount;
  String? paymentMethod;
  double? taxes;
  String? orgName;
  String? orgAddress;
  String? orgINN;
  double? discountt;
  String? tablee;
  int? persons;
  Chekk({
    this.id,
    this.curentDate,
    this.amount,
    this.paymentMethod,
    this.taxes,
    this.orgName,
    this.orgAddress,
    this.orgINN,
    this.discountt,
    this.tablee,
    this.persons,
  });

  Chekk copyWith({
    int? id,
    DateTime? curentDate,
    double? amount,
    String? paymentMethod,
    double? taxes,
    String? orgName,
    String? orgAddress,
    String? orgINN,
    double? discountt,
    String? tablee,
    int? persons,
  }) {
    return Chekk(
      id: id ?? this.id,
      curentDate: curentDate ?? this.curentDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      taxes: taxes ?? this.taxes,
      orgName: orgName ?? this.orgName,
      orgAddress: orgAddress ?? this.orgAddress,
      orgINN: orgINN ?? this.orgINN,
      discountt: discountt ?? this.discountt,
      tablee: tablee ?? this.tablee,
      persons: persons ?? this.persons,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'curentDate': curentDate?.millisecondsSinceEpoch,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'taxes': taxes,
      'orgName': orgName,
      'orgAddress': orgAddress,
      'orgINN': orgINN,
      'discountt': discountt,
      'tablee': tablee,
      'persons': persons,
    };
  }

  factory Chekk.fromMap(Map<String, dynamic> map) {
    return Chekk(
      id: map['id'] != null ? map['id'] as int : null,
      curentDate: map['curentDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              ((map['curentDate'] as double) * 1000).toInt(),
              isUtc: false)
          : null,
      amount: map['amount'] != null ? map['amount'] as double : null,
      paymentMethod:
          map['paymentMethod'] != null ? map['paymentMethod'] as String : null,
      taxes: map['taxes'] != null ? map['taxes'] as double : null,
      orgName: map['orgName'] != null ? map['orgName'] as String : null,
      orgAddress:
          map['orgAddress'] != null ? map['orgAddress'] as String : null,
      orgINN: map['orgINN'] != null ? map['orgINN'] as String : null,
      discountt: map['discountt'] != null ? map['discountt'] as double : null,
      tablee: map['tablee'] != null ? map['tablee'] as String : null,
      persons: map['persons'] != null ? map['persons'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chekk.fromJson(String source) =>
      Chekk.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chekk(id: $id, curentDate: $curentDate, amount: $amount, paymentMethod: $paymentMethod, taxes: $taxes, orgName: $orgName, orgAddress: $orgAddress, orgINN: $orgINN, discountt: $discountt, tablee: $tablee, persons: $persons)';
  }

  @override
  bool operator ==(covariant Chekk other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.curentDate == curentDate &&
        other.amount == amount &&
        other.paymentMethod == paymentMethod &&
        other.taxes == taxes &&
        other.orgName == orgName &&
        other.orgAddress == orgAddress &&
        other.orgINN == orgINN &&
        other.discountt == discountt &&
        other.tablee == tablee &&
        other.persons == persons;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        curentDate.hashCode ^
        amount.hashCode ^
        paymentMethod.hashCode ^
        taxes.hashCode ^
        orgName.hashCode ^
        orgAddress.hashCode ^
        orgINN.hashCode ^
        discountt.hashCode ^
        tablee.hashCode ^
        persons.hashCode;
  }
}
