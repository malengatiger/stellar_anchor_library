import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/api/anchor_db.dart';
import 'package:stellar_anchor_library/api/net.dart';
import 'package:stellar_anchor_library/models/agent.dart';
import 'package:stellar_anchor_library/models/anchor.dart';
import 'package:stellar_anchor_library/models/balances.dart';
import 'package:stellar_anchor_library/models/client.dart';
import 'package:stellar_anchor_library/models/payment_request.dart';
import 'package:stellar_anchor_library/util/prefs.dart';
import 'package:stellar_anchor_library/util/util.dart';

final AgentBloc agentBloc = AgentBloc();

class AgentBloc {
  AgentBloc() {
    p('🥬 🥬 🥬 🥬 🥬 AgentBloc starting engines ... 🥬 ...');
    getAnchor();
    getAnchorUser();
  }

  StreamController<List<Agent>> _agentController = StreamController.broadcast();
  StreamController<List<Client>> _clientController =
      StreamController.broadcast();
  StreamController<List<Balances>> _balancesController =
      StreamController.broadcast();

  List<String> _errors = List();
  List<bool> _busies = List();
  List<Client> _clients = List();
  List<Balances> _balances = List();
  StreamController<List<String>> _errorController =
      StreamController.broadcast();

  StreamController<List<bool>> _busyController = StreamController.broadcast();

  Stream<List<Agent>> get agentStream => _agentController.stream;

  Stream<List<bool>> get busyStream => _busyController.stream;

  Stream<List<String>> get errorStream => _errorController.stream;

  Stream<List<Client>> get clientStream => _clientController.stream;

  Stream<List<Balances>> get balancesStream => _balancesController.stream;

  List<Agent> get agents => _agents;

  List<Client> get clients => _clients;

  FirebaseAuth _auth = FirebaseAuth.instance;

  List<Agent> _agents = List();
  Anchor _anchor;
  AnchorUser _anchorUser;

  Future<Anchor> getAnchor() async {
    _anchor = await Prefs.getAnchor();
    if (_anchor != null) {
      getAgents(anchorId: _anchor.anchorId, refresh: false);
    }
    return _anchor;
  }

// public PaymentRequest sendPayment(PaymentRequest paymentRequest) throws Exception {
  Future<Balances> sendMoneyToAgent(
      {@required Agent agent,
      @required String amount,
      @required String assetCode}) async {
    assert(amount != null);
    assert(assetCode != null);
    var fundRequest = AgentFundingRequest(
        anchorId: agent.anchorId,
        amount: amount,
        date: DateTime.now().toIso8601String(),
        agentId: agent.agentId,
        assetCode: assetCode,
        userId: _anchorUser.userId);
    p('agentBloc:  🏈  🏈  🏈 sendMoneyToAgent ... check asset code is not null: ${fundRequest.toJson()}');

    var result = await NetUtil.post(
        headers: NetUtil.xHeaders,
        apiRoute: 'fundAgent',
        bag: fundRequest.toJson());
    p(result);
    p("💧 💧 💧 💧 💧 refreshing agent account balances after payment. check balance of 🌼 $assetCode ....");
    return await _readRemoteBalances(agent.stellarAccountId);
  }

  Future<AnchorUser> getAnchorUser() async {
    _anchorUser = await Prefs.getAnchorUser();
    return _anchorUser;
  }

  Future<List<Agent>> getAgents({String anchorId, bool refresh = false}) async {
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
      if (refresh) {
        await _readAgentsFromDatabase(anchorId);
      } else {
        _agents = await AnchorLocalDB.getAgents();
      }
      if (_agents.isEmpty) {
        await _readAgentsFromDatabase(anchorId);
      }
      _busies.clear();
      _busies.add(false);
      _busyController.sink.add(_busies);
      _agentController.sink.add(_agents);
      p('🌿 🌿 🌿 Agents found either locally or from remote database : 🎁  ${_agents.length} 🎁 ');
    } catch (e) {
      p(e);
      _errors.clear();
      _errors.add('Firestore agent query failed');
      _errorController.sink.add(_errors);
    }
    return _agents;
  }

  Future _readAgentsFromDatabase(String anchorId) async {
    var qs = await firestore
        .collection('agents')
        .where('anchorId', isEqualTo: anchorId)
        .getDocuments();

    _agents.clear();
    qs.documents.forEach((doc) {
      _agents.add(Agent.fromJson(doc.data));
    });
    _agents.forEach((element) async {
      await AnchorLocalDB.addAgent(agent: element);
    });
    return _agents;
  }

  Future<List<Client>> getClients({String agentId, bool refresh}) async {
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
      if (refresh) {
        await _getRemoteClients(agentId);
      } else {
        _clients = await AnchorLocalDB.getClientsByAgent(agentId);
        p('🔵 🔵 🔵 🔵  Agent\'s clients found on LOCAL cache : 🎁  ${_clients.length} 🎁 ');
        if (clients.isEmpty) {
          await _getRemoteClients(agentId);
        }
      }
    } catch (e) {
      p(e);
      _errors.clear();
      _errors.add('Firestore agent query failed');
      _errorController.sink.add(_errors);
    }
    return _clients;
  }

  Future _getRemoteClients(String agentId) async {
    var qs = await firestore
        .collection('clients')
        .where('agentId', isEqualTo: agentId)
        .getDocuments();
    _clients.clear();
    qs.documents.forEach((doc) {
      _clients.add(Client.fromJson(doc.data));
    });
    _busies.clear();
    _busies.add(false);
    _busyController.sink.add(_busies);
    _clientController.sink.add(_clients);
    p('🌿 🌿 🌿 Agent\'s clients found on REMOTE database : 🎁  ${_clients.length} 🎁 ');
    _clients.forEach((element) async {
      await AnchorLocalDB.addClient(client: element);
    });
  }

  Future<Balances> _readRemoteBalances(String accountId) async {
    var result = await NetUtil.get(
        headers: null,
        apiRoute: 'getAccountUsingAccountId?accountId=$accountId');
    var mBalances = Balances.fromJson(result);
    p('\n🔆 🔆 🔆 AgentBloc:_readRemoteBalances ️️❤️  printing the result from the get call ...');
    p(result);
    await AnchorLocalDB.addBalance(balances: mBalances);

    Balances newBal = _processAssetCodes(mBalances);
    p('👌 New Balances after processing native to XLM: 👌 ${newBal.toJson()} 👌');
    return newBal;
  }

  Future<Balances> getLocalBalances(String accountId) async {
    Balances mBalances;
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
      p('🍎 AgentBloc: getLocalBalances .... $accountId ..... ');
      mBalances = await AnchorLocalDB.getLastBalances(accountId);
      if (mBalances == null) {
        return null;
      }
      _doBalancesStream(mBalances);
    } catch (e) {
      p(e);
      _balanceError();
    }
    Balances newBal = _processAssetCodes(mBalances);
    return newBal;
  }

  Balances _processAssetCodes(Balances mBalances) {
    var newBal = Balances();
    newBal.account = mBalances.account;
    newBal.date = mBalances.date;
    newBal.sequenceNumber = mBalances.sequenceNumber;
    newBal.balances = [];
    mBalances.balances.forEach((element) {
      if (element.assetCode == null) {
        element.assetCode = 'XLM';
      }
      newBal.balances.add(element);
    });

    p('_processAssetCodes: 🔆 🔆 🔆 ${newBal.toJson()}');
    return newBal;
  }

  Future<Balances> getRemoteBalances(String accountId) async {
    Balances mBalances;
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
      //todo - get balances
      mBalances = await _readRemoteBalances(accountId);
      mBalances.balances.sort((a, b) => a.assetCode.compareTo(b.assetCode));
      if (mBalances != null) {
        await AnchorLocalDB.addBalance(balances: mBalances);
      } else {
        return null;
      }
      _doBalancesStream(mBalances);
    } catch (e) {
      p(e);
      _balanceError();
    }

    return mBalances;
  }

  void _balanceError() {
    var msg = 'Balances not found on Stellar';
    _errors.clear();
    _errors.add(msg);
    _errorController.sink.add(_errors);
    p(' 🍎 $msg');
    throw Exception(msg);
  }

  void _doBalancesStream(Balances mBalances) {
    _balances.clear();
    _balances.add(mBalances);
    _balancesController.sink.add(_balances);

    _busies.clear();
    _busies.add(false);
    _busyController.sink.add(_busies);
    _balancesController.sink.add(_balances);

    p('🌿 🌿 🌿 Balances found on database : 🎁 in stream: ${_balances.length} 🎁 ');
  }

  closeStreams() {
    _agentController.close();
    _errorController.close();
    _busyController.close();
    _clientController.close();
    _balancesController.close();
  }

  final FirebaseMessaging fcm = FirebaseMessaging();
  final Firestore firestore = Firestore.instance;

  void _subscribeToArrivalsFCM() async {
//    List<String> topics = List();
//    topics
//        .add('${Constants.COMMUTER_ARRIVAL_LANDMARKS}_${landmark.landmarkID}');
//    topics.add('${Constants.VEHICLE_ARRIVALS}_${landmark.landmarkID}');
//    topics
//        .add('${Constants.ROUTE_DISTANCE_ESTIMATIONS}_${landmark.landmarkID}');
//    topics
//        .add('${Constants.COMMUTER_FENCE_DWELL_EVENTS}_${landmark.landmarkID}');
//    topics
//        .add('${Constants.COMMUTER_FENCE_EXIT_EVENTS}_${landmark.landmarkID}');
//    topics.add('${Constants.COMMUTER_REQUESTS}_${landmark.landmarkID}');
//
//    if (landmarksSubscribedMap.containsKey(landmark.landmarkID)) {
//      myDebugPrint(
//          '🍏 Landmark ${landmark.landmarkName} has already subscribed to FCM');
//    } else {
//      await _subscribe(topics, landmark);
//      myDebugPrint('MarshalBloc:: 🧩 Subscribed to ${topics.length} FCM topics'
//          ' for landmark: 🍎 ${landmark.landmarkName} 🍎 ');
//    }
//
//    myDebugPrint(
//        'MarshalBloc:... 💜 💜 Subscribed to FCM ${landmarksSubscribedMap.length} topics for '
//        'landmark ✳️ ${_landmark == null ? 'unknown' : _landmark.landmarkName}\n');
  }

//  _subscribe(List<String> topics, Landmark landmark) async {
//    for (var t in topics) {
//      await fcm.subscribeToTopic(t);
//      myDebugPrint(
//          'MarshalBloc: 💜 💜 Subscribed to FCM topic: 🍎  $t ✳️ at ${landmark.landmarkName}');
//    }
//    landmarksSubscribedMap[landmark.landmarkID] = landmark;
//    return;
//  }

}
