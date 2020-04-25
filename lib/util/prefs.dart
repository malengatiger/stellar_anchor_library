import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_anchor_library/models/anchor.dart';
import 'package:stellar_anchor_library/models/stokvel.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';

class Prefs {
  static Future saveAnchor(Anchor anchor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = anchor.toJson();
    var jx = json.encode(mJson);
    prefs.setString('anchor', jx);
    print("🌽 🌽 🌽 Prefs. ANCHOR  SAVED: 💦  ...... ${anchor.name} 💦 ");
    return null;
  }

  static Future saveAnchorUser(AnchorUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('anchorUser', jx);
    print(
        "🌽 🌽 🌽 Prefs. ANCHOR USER  SAVED: 💦  ...... ${user.firstName} 💦 ");
    return null;
  }

  static void setThemeIndex(int index) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('index', index);
    print('🔵 🔵 🔵 Prefs: theme index set to: $index 🍎 🍎 ');
  }

  static Future<int> getThemeIndex() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getInt('index');
    if (b == null) {
      return 0;
    } else {
      print('🔵 🔵 🔵  theme index retrieved: $b 🍏 🍏 ');
      return b;
    }
  }

  static Future<Anchor> getAnchor() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('anchor');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var name = new Anchor.fromJson(jx);
    print("🌽 🌽 🌽 Prefs.getAnchor 🧩 ......  ${name.name} retrieved");
    return name;
  }

  static Future<AnchorUser> getAnchorUser() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('anchorUser');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var name = new AnchorUser.fromJson(jx);
    print(
        "🌽 🌽 🌽 Prefs.getAnchorUser 🧩 ......  ${name.firstName} retrieved");
    return name;
  }

  static Future saveMember(Member member) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = member.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('member', jx);
    print("🌽 🌽 🌽 Prefs.saveMember  SAVED: 🌽 ${member.toJson()}");
    return null;
  }

  static Future<Member> getMember() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('member');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var member = new Member.fromJson(jx);
    return member;
  }

  static void addStokvelAccountResponseBag(AccountResponseBag bag) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString('stokvelaccount', jsonEncode(bag.toJson()));
    print(
        '🔵 🔵 🔵 Prefs: Stellar Stokvel AccountResponseBag cached ... 🍎 🍎 ');
  }

  static Future<AccountResponseBag> getStokvelAccountResponseBag() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('stokvelaccount');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = AccountResponseBag.fromJson(mJson);
      print('🔵 🔵 🔵 Prefs: Stokvel AccountResponseBag retrieved, 🍏 🍏 ');
      return creds;
    }
  }

  static void addMemberAccountResponseBag(AccountResponseBag bag) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString('memberaccount', jsonEncode(bag.toJson()));
    print(
        '🔵 🔵 🔵 Prefs: Stellar Member AccountResponseBag cached ... 🍎 🍎 ');
  }

  static Future<AccountResponseBag> getMemberAccountResponseBag() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('memberaccount');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = AccountResponseBag.fromJson(mJson);
      print('🔵 🔵 🔵 Prefs: Member AccountResponseBag retrieved, 🍏 🍏 ');
      return creds;
    }
  }
}
