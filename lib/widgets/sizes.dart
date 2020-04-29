import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/util/util.dart';

Size displaySize(BuildContext context) {
  p('💧Size = ' + MediaQuery.of(context).size.toString());
  return MediaQuery.of(context).size;
}

double displayHeight(BuildContext context) {
  p('💧Height = ' + displaySize(context).height.toString());
  return displaySize(context).height;
}

double displayWidth(BuildContext context) {
  p('💧Width = ' + displaySize(context).width.toString());
  return displaySize(context).width;
}