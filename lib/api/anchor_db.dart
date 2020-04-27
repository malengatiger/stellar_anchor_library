import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobmongo/carrier.dart';
import 'package:mobmongo/mobmongo.dart';
import 'package:stellar_anchor_library/models/agent.dart';
import 'package:stellar_anchor_library/models/client.dart';
import 'package:stellar_anchor_library/models/loan.dart';
import 'package:stellar_anchor_library/util/functions.dart';

import 'constants.dart';

class AnchorLocalDB {
  static const APP_ID = 'anchorAppID';
  static bool dbConnected = false;
  static int cnt = 0;

  static String databaseName = 'anchor001';

  static Future _connectToLocalDB() async {
    if (dbConnected) {
      return null;
    }

    try {
      await MobMongo.setAppID({
        'appID': APP_ID,
        'type': MobMongo.LOCAL_DATABASE,
      });
      await _createIndices();
      dbConnected = true;
      print(
          '👌 Connected to MongoDB Mobile. 🥬 DATABASE: $databaseName  🥬 APP_ID: $APP_ID  👌 👌 👌 '
          ' necessary indices created for all models 🧩 🧩 🧩 \n');
      return null;
    } on PlatformException catch (e) {
      print('👿👿👿👿👿👿👿👿👿👿 ${e.message}  👿👿👿👿');
      throw Exception(e);
    }
  }

  static Future _createIndices() async {
    var carr1 = Carrier(
        db: databaseName,
        collection: Constants.STOKVELS,
        index: {"stokvelId": 1});
    await MobMongo.createIndex(carr1);

    var carr3 = Carrier(
        db: databaseName,
        collection: Constants.MEMBERS,
        index: {"memberId": 1});
    await MobMongo.createIndex(carr3);

    var carr4 = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS_RECEIVED,
        index: {"stokvel.stokvelId": 1});
    await MobMongo.createIndex(carr4);

    var carr5 = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_PAYMENTS,
        index: {"fromMember.memberId": 1});
    await MobMongo.createIndex(carr5);

    var carr5a = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_PAYMENTS,
        index: {"toMember.memberId": 1});
    await MobMongo.createIndex(carr5a);

    var carr6 = Carrier(
        db: databaseName, collection: Constants.CREDS, index: {"stokvelId": 1});
    await MobMongo.createIndex(carr6);

    var carr7 = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_ACCOUNT_RESPONSES,
        index: {"accountId": 1});
    await MobMongo.createIndex(carr7);

    var carr8 = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_ACCOUNT_RESPONSES,
        index: {"accountId": 1});
    await MobMongo.createIndex(carr8);
  }

  static Future<List<Agent>> getAgents() async {
    await _connectToLocalDB();
    List<Agent> mList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.STOKVELS,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      mList.add(Agent.fromJson(jsonDecode(r)));
    });
    return mList;
  }

  static Future<List<Client>> getClientsByAgent(String agentId) async {
    List<Client> mList = await getAllClients();
    List<Client> sList = [];
    mList.forEach((m) {
      if (m.agentId == agentId) {
        sList.add(m);
      }
    });
    return sList;
  }

  static Future<List<Client>> getAllClients() async {
    await _connectToLocalDB();
    List<Client> mList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.CLIENTS,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      mList.add(Client.fromJson(jsonDecode(r)));
    });
    return mList;
  }

  static Future<Client> getClient(String clientId) async {
    await _connectToLocalDB();
    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.MEMBERS, query: {
      "eq": {"memberId": clientId}
    });
    List results = await MobMongo.query(carrier);
    List<Client> list = List();
    results.forEach((r) {
      var mm = Client.fromJson(jsonDecode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  static Future<int> addAgent({@required Agent agent}) async {
    await _connectToLocalDB();

    var start = DateTime.now();
    Carrier c = Carrier(db: databaseName, collection: Constants.AGENTS, id: {
      'field': 'agentId',
      'value': agent.agentId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of Agent delete: 🍎 $resDelete 🍎 ');

    Carrier ca = Carrier(
        db: databaseName, collection: Constants.AGENTS, data: agent.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of Agent insert: 🍎 $res 🍎 ');
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addAgent: 🌼 1 added...: ${agent.personalKYCFields.getFullName()} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addClient({@required Client client}) async {
    await _connectToLocalDB();
    prettyPrint(client.toJson(),
        ",,,,,,,,,,,,,,,,,,,,,,, CLIENT TO BE ADDED TO local DB, check name etc.");

    var start = DateTime.now();
    Carrier c = Carrier(db: databaseName, collection: Constants.CLIENTS, id: {
      'field': 'clientId',
      'value': client.clientId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of client delete: 🍎 $resDelete 🍎 ');

    Carrier ca = Carrier(
        db: databaseName, collection: Constants.CLIENTS, data: client.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of client insert: 🍎 $res 🍎 ');
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addclient: 🌼 1 added...: ${client.personalKYCFields.getFullName()} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addLoanApplication(
      {@required LoanApplication loanApplication}) async {
    await _connectToLocalDB();
    var start = DateTime.now();
    Carrier c =
        Carrier(db: databaseName, collection: Constants.LOAN_APPLICATIONS, id: {
      'field': 'loanId',
      'value': loanApplication.loanId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of LoanApplication delete: 🍎 $resDelete 🍎 ');

    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.LOAN_APPLICATIONS,
        data: loanApplication.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addLoanApplication: 🌼 1 added...: ${loanApplication.date} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<Agent> getAgentById(String agentId) async {
    await _connectToLocalDB();
    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.AGENTS, query: {
      "eq": {"agentId": agentId}
    });
    List results = await MobMongo.query(carrier);
    List<Agent> list = List();
    results.forEach((r) {
      var mm = Agent.fromJson(jsonDecode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }

    return list.first;
  }
}
