import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stellar_anchor_library/models/owzo_request.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/util.dart';

class NetUtil {
  static const Map<String, String> xHeaders = {
    'Content-type': 'application/json',
    'Accept': '*/*',
  };

  static const timeOutInSeconds = 30;

  static Future<String> getOwzoHash(
      {OwzoPaymentRequest request, BuildContext context}) async {
    p('🐳 🐳 Building concatenated string from PaymentRequest ...');
    var privateKey = await getOwzoPrivateKey();
    var site = await getOwzoSiteCode();
    var country = await getCountryCode();
    var currency = await getCurrencyCode();
    var success = await getOwzoSuccessUrl();
    var cancel = await getOwzoCancelUrl();
    var error = await getOwzoErrorUrl();
    var notify = await getOwzoNotifyUrl();
    var sb = StringBuffer();
    sb.write(site.toLowerCase());
    sb.write(country.toLowerCase());
    sb.write(currency.toLowerCase());
    sb.write(
        '${getFormattedAmount('${request.amount}', context)}'.toLowerCase());
    sb.write(request.transactionReference.toLowerCase());
    sb.write(request.bankReference.toLowerCase());
    sb.write(request.customer.toLowerCase());
    sb.write(cancel.toLowerCase());
    sb.write(error.toLowerCase());
    sb.write(success.toLowerCase());
    sb.write(notify.toLowerCase());
    sb.write(request.isTest ? 'true' : 'false');
    sb.write(privateKey.toLowerCase());
    var string = sb.toString();
    p('NetUtil: ⏰ ⏰ ⏰ String to be Hashed on the backend: 🔆 $string ..... 🔆');
    var hashedObject = await get(
        headers: null, apiRoute: 'getOzowHash?string=${sb.toString()}');
    p('NetUtil: 💚 💚 💚 Hashed result string from backend: 🧩 ${hashedObject['hashed']} 🧩');
    return hashedObject['hashed'];
  }

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

  static Future uploadIDDocuments(
      {@required String id,
      @required File idFront,
      @required File idBack}) async {
    p('🐸  🐸  🐸 Uploading the front and back of ID document ...');
    var url = await getBaseUrl();
    var finalUrl = url + 'uploadID';
    var frontBytes = await idFront.length();
    var backBytes = await idBack.length();
    p('🐸  🐸  🐸 frontBytes size: $frontBytes bytes ...');
    p('🐸  🐸  🐸 backBytes size: $backBytes bytes ...');
    var frontFile = await http.MultipartFile.fromPath('idFront', idFront.path);
    var backFile = await http.MultipartFile.fromPath('idBack', idBack.path);
    var req = http.MultipartRequest('POST', Uri.parse(finalUrl))
      ..fields['id'] = id
      ..files.add(frontFile)
      ..files.add(backFile);

    var response = await req.send();

    p('🐸  🐸  🐸 ... ID Upload response: ${response.toString()}');
    if (response.statusCode == 200) {
      var msg = '🍐 🍐 🍐 ID document uploaded OK : $response';
      p(msg);
      return msg;
    } else {
      p('😈 👿 Reason Phrase: ${response.reasonPhrase}');
      print(response);
      throw Exception('ID Document Upload Failed');
    }
  }

  static Future uploadProofOfResidence(
      {@required String id, @required File proofOfResidence}) async {
    var url = await getBaseUrl();
    var finalUrl = url + 'uploadProofOfResidence';
    var frontBytes = await proofOfResidence.length();
    p('🐸  🐸  🐸 proofOfResidence size: $frontBytes bytes ...');
    var frontFile = await http.MultipartFile.fromPath(
        'proofOfResidence', proofOfResidence.path);
    var req = http.MultipartRequest('POST', Uri.parse(finalUrl))
      ..fields['id'] = id
      ..files.add(frontFile);
    var response = await req.send();
    p('🥏 🥏 🥏 ProofOfResidence uploaded, response: $response');
    if (response.statusCode == 200) {
      var msg = '🍐 🍐 🍐 ProofOfResidence document uploaded OK : $response';
      p(msg);
      return msg;
    } else {
      throw Exception('ProofOfResidence Document Upload Failed');
    }
  }

  static Future uploadSelfie(
      {@required String id, @required File selfie}) async {
    p('🐸  🐸  🐸 Uploading the selfie file ...');
    var url = await getBaseUrl();
    var finalUrl = url + 'uploadSelfie';
    var frontBytes = await selfie.length();
    p('🐸  🐸  🐸 Selfie size: $frontBytes bytes ...');
    var frontFile = await http.MultipartFile.fromPath('selfie', selfie.path);
    var req = http.MultipartRequest('POST', Uri.parse(finalUrl))
      ..fields['id'] = id
      ..files.add(frontFile);
    var response = await req.send();
    p('🚘  🚘  🚘 Selfie uploaded, response : $response');
    if (response.statusCode == 200) {
      var msg = '🍐 🍐 🍐 Selfie document uploaded OK : $response';
      p(msg);
      return msg;
    } else {
      throw Exception('Selfie Document Upload Failed');
    }
  }
}
