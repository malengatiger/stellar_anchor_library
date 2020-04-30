import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/models/balances.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/image_handler/currency_icons.dart';
import 'package:stellar_anchor_library/util/util.dart';

class BalancesScroller extends StatelessWidget {
  final Axis direction;
  final Balances balances;

  const BalancesScroller(
      {Key key, @required this.direction, @required this.balances})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: balances == null ? 0 : balances.balances.length,
          scrollDirection: direction,
          itemBuilder: (context, index) {
            var currency = 'XLM';
            if (balances.balances.elementAt(index).assetCode == null) {
              currency = 'XLM';
            } else {
              currency = balances.balances.elementAt(index).assetCode;
            }
            var imagePath = CurrencyIcons.getCurrencyImagePath(currency);
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          boxShadow: customShadow,
                          color: baseColor,
                          shape: BoxShape.circle),
                      child: Image.asset(imagePath)),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    getFormattedAmount(
                        balances.balances.elementAt(index).balance, context),
                    style: Styles.tealBoldSmall,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
