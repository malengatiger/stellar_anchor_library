import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/util.dart';

class RoundNumberWidget extends StatelessWidget {
  final int number;
  final double radius, margin;

  const RoundNumberWidget({Key key, @required this.number,  @required this.radius,  @required this.margin})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius + margin,
      height: radius + margin,
      decoration: BoxDecoration(
          boxShadow: customShadow,
          color: secondaryColor,
          shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
              boxShadow: customShadow,
              color: baseColor,
              shape: BoxShape.circle),
          child: Center(
            child: Text(
              "$number",
              style: Styles.blackBoldSmall,
            ),
          ),
        ),
      ),
    );
  }
}
