import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stellar_anchor_library/util/util.dart';

class NetUtil {
  static const Map<String, String> xHeaders = {
    'Content-type': 'application/json',
    'Accept': '*/*',
  };

  static const timeOutInSeconds = 30;

  static Future post(
      {Map<String, String> headers, String apiRoute, Map bag}) async {
    var url = await getBaseUrl();
    apiRoute = url + apiRoute;
    print('🏈 🏈 NetUtil: POST:  ................................... 🔵 '
        '🔆 🔆 🔆 🔆 calling backend:  ......................................   💙  '
        '$apiRoute  💙  🏈 🏈 ');
    var mBag;
    if (bag != null) {
      mBag = jsonEncode(bag);
    }
    if (mBag == null) {
      print(
          '🔵 🔵 👿 Bad moon rising? :( - 🔵 🔵 👿 bag is null, may not be a problem ');
    }
    p(mBag);
    var start = DateTime.now();
    http.Response httpResponse = await http
        .post(
          apiRoute,
          headers: headers,
          body: mBag,
        )
        .timeout(const Duration(seconds: timeOutInSeconds));

    var end = DateTime.now();
    print(
        'RESPONSE: 💙  💙  status: ${httpResponse.statusCode} 💙 body: ${httpResponse.body}');
    if (httpResponse.statusCode == 200) {
      p('❤️️❤️  NetUtil: POST.... : 💙 statusCode: 👌👌👌 ${httpResponse.statusCode} 👌👌👌 💙 '
          'for $apiRoute 🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
      var mJson = json.decode(httpResponse.body);
      return mJson;
    } else {
      var end = DateTime.now();
      p('🔵 🔵  NetUtil: POST .... : 🔆 statusCode: 🔵 🔵  ${httpResponse.statusCode} 🔆🔆🔆 '
          'for $apiRoute  🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆 ... '
          'throwing exception .....................');
      p('🔵 🔵  NetUtil.post .... : 🔆 statusCode: 🔵 🔵  ${httpResponse.statusCode} 🔆🔆🔆 '
          'for $apiRoute  🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
      throw Exception(
          '🚨 🚨 Status Code 🚨 ${httpResponse.statusCode} 🚨 ${httpResponse.body}');
    }
  }

  static Future get({Map<String, String> headers, String apiRoute}) async {
    var url = await getBaseUrl();
    apiRoute = url + apiRoute;
    print('🏈 🏈 NetUtil GET:  ................................... 🔵 '
        '🔆 🔆 🔆 🔆 calling backend:  ......................................   💙  '
        '$apiRoute  💙  🏈 🏈 ');
    var start = DateTime.now();
    http.Response httpResponse = await http
        .get(
          apiRoute,
          headers: headers,
        )
        .timeout(const Duration(seconds: timeOutInSeconds));
    var end = DateTime.now();
    print(
        'RESPONSE: 💙  💙  status: ${httpResponse.statusCode} 💙 body: ${httpResponse.body}');
    if (httpResponse.statusCode == 200) {
      p('️️❤️  NetUtil: GET: .... : 💙 statusCode: 👌👌👌 ${httpResponse.statusCode} 👌👌👌 💙 for $apiRoute 🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
      var mJson = json.decode(httpResponse.body);
      return mJson;
    } else {
      var end = DateTime.now();
      p('👿👿👿 NetUtil: POST: .... : 🔆 statusCode: 👿👿👿 ${httpResponse.statusCode} 🔆🔆🔆 '
          'for $apiRoute  🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆 ... '
          'throwing exception .....................');
      p('👿👿👿 NetUtil: POST: .... : 🔆 statusCode: 👿👿👿 ${httpResponse.statusCode} 🔆🔆🔆 for $apiRoute  🔆 elapsed: ${end.difference(start).inSeconds} seconds 🔆');
      throw Exception(
          '🚨 🚨 Status Code 🚨 ${httpResponse.statusCode} 🚨 ${httpResponse.body}');
    }
  }
}
