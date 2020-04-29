import 'balance.dart';

class Balances {
  String date;
  String account;
  dynamic sequenceNumber;
  List<Balance> balances;

  Balances({this.account, this.sequenceNumber, this.balances, this.date}); //

  Balances.fromJson(Map data) {
    this.account = data['account'];
    this.date = data['date'];
    this.sequenceNumber = data['sequenceNumber'];
    balances = List();
    if (data['balances'] != null) {
      List mBalances = data['balances'];
      mBalances.forEach((element) {
        balances.add(Balance.fromJson(element));
      });
    }
  }

  Map<String, dynamic> toJson() {
    List<Map> mMap = List();
    balances.forEach((element) {
      mMap.add(element.toJson());
    });
    Map<String, dynamic> map = Map();
    map['account'] = account;
    map['date'] = date;
    map['sequenceNumber'] = sequenceNumber;
    map['balances'] = mMap;
    return map;
  }
}
