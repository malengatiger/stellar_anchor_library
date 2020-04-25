import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getBaseUrl() async {
  await DotEnv().load('.env');
  String devURL = DotEnv().env['devURL'];
  String prodURL = DotEnv().env['prodURL'];
  String status = DotEnv().env['status'];
  if (status == null) {
    throw Exception('Development or Production Status unknown or unavailable');
  }
  p('🔵 🔵 Properties Data from dot.env file; 🔆 devURL: $devURL 🔵 🔆 prodURL: $prodURL 🔵 🔵 ');
  if (status == 'dev') {
    return devURL;
  } else {
    return prodURL;
  }
}

Future<bool> isProductionMode() async {
  await DotEnv().load('.env');
  String status = DotEnv().env['status'];
  if (status == null) {
    throw Exception(
        'Development or Production Status unknown or unavailable in environment');
  }

  if (status == 'dev') {
    p('🔵 🔵 Properties Data from dot.env file; 🔆 status: $status 🔵 🔵 🔵  DEVELOPMENT');
    return false;
  } else {
    p('🔵 🔵 Properties Data from dot.env file; 🔆 status: $status 🔵 🔵 🔵  PRODUCTION');
    return true;
  }
}

Future<String> getAnchorId() async {
  await DotEnv().load('.env');
  String anchorId = DotEnv().env['anchorId'];
  p('🔵 🔵 Properties Data from dot.env file; 🔆 anchorName: $anchorId 🔵 🔆  🔵 🔵 ');
  return anchorId;
}

String lorem =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

String dummy =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. ";

Color baseColor = Color(0xFFCADCED);
Color secondaryColor = Colors.brown[100];

List<BoxShadow> customShadow = [
  BoxShadow(
      color: Colors.white.withOpacity(0.5),
      spreadRadius: -3,
      offset: Offset(-3, -3),
      blurRadius: 20),
  BoxShadow(
      color: Colors.blue[900].withOpacity(0.2),
      spreadRadius: 2,
      offset: Offset(5, 5),
      blurRadius: 12),
];

void p(dynamic message) {
  print(message);
}
