import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/util/util.dart';

class RoundAvatar extends StatelessWidget {
  final String path;
  final double radius;
  final bool fromNetwork;

  const RoundAvatar(
      {Key key,
      @required this.path,
      @required this.radius,
      @required this.fromNetwork})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    p('............ avatar build ... 🔆 🔆 🔆  path: $path radius: $radius');
    assert(path != null);
    if (fromNetwork) {
      return Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
            boxShadow: customShadow, color: baseColor, shape: BoxShape.circle),
        child: CircleAvatar(
          child: Image.asset(path),
        ),
      );
    } else {
      return Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
            boxShadow: customShadow, color: baseColor, shape: BoxShape.circle),
        child: CircleAvatar(
          backgroundImage: AssetImage(path),
        ),
      );
    }
  }
}

//
class MyAvatar extends StatelessWidget {
  final Icon icon;

  const MyAvatar({Key key, this.icon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          boxShadow: customShadow, color: baseColor, shape: BoxShape.circle),
      child: icon,
    );
  }
}
