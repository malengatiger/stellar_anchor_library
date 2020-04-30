import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/models/balance.dart';
import 'package:stellar_anchor_library/models/balances.dart';
import 'package:stellar_anchor_library/util/image_handler/currency_icons.dart';
import 'package:stellar_anchor_library/util/util.dart';

class CurrencyDropDown extends StatelessWidget {
  final Balances balances;
  final CurrencyDropDownListener listener;

  const CurrencyDropDown({Key key, this.balances, this.listener})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(balances != null);
    var items = List<DropdownMenuItem<Balance>>();
    balances.balances.forEach((balance) {
      p('🌼 .... Balance to be put into dropDown menu: ${balance.assetCode} ${balance.balance}');
      var imagePath = CurrencyIcons.getCurrencyImagePath(balance.assetCode);
      p('🌼 .... imagePath: $imagePath');
      if (balance.assetCode != null) {
        items.add(new DropdownMenuItem(
            value: balance,
            child: Row(
              children: <Widget>[
                Image.asset(imagePath, height: 40, width: 40),
                SizedBox(width: 8),
                Text(balance.assetCode),
              ],
            )));
      }
    });

    return DropdownButton<Balance>(
        hint: Text('Select Currency'), items: items, onChanged: _onChanged);
  }

  void _onChanged(Balance value) {
    listener.onChanged(value);
  }
}

abstract class CurrencyDropDownListener {
  onChanged(Balance value);
}
