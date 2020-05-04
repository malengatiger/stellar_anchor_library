import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stellar_anchor_library/api/constants.dart';
import 'package:stellar_anchor_library/api/net.dart';
import 'package:stellar_anchor_library/models/agent.dart';
import 'package:stellar_anchor_library/models/anchor.dart';
import 'package:stellar_anchor_library/models/balances.dart';
import 'package:stellar_anchor_library/models/client.dart';
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
      getAgents(_anchor.anchorId);
    } else {
      await DotEnv().load(".env");
      String email = DotEnv().env["email"];
      String password = DotEnv().env["password"];
      if (email == null) {
        throw Exception("admin email not found in .env ");
      }
      p('🍐 🍐 🍐 email retrieved from .env  🍐 $email');
      var authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        Anchor anchor;
        var qs = await firestore
            .collection(Constants.ANCHORS)
            .limit(1)
            .getDocuments();
        qs.documents.forEach((doc) {
          anchor = Anchor.fromJson(doc.data);
        });
        if (anchor == null) {
          throw Exception("Unable to find Anchor");
        }
        p('🍐 🍐 🍐 Anchor retrieved from Database  🍐 ${anchor.toJson()}');
        Prefs.saveAnchor(anchor);
        return anchor;
      } else {
        p("👿👿👿👿 Unable to log in the bootUp Admin from .env : $email");
        throw Exception("👿 Unable to log in the bootUp Admin from .env");
      }
    }
    return _anchor;
  }

  Future<AnchorUser> getAnchorUser() async {
    _anchorUser = await Prefs.getAnchorUser();
    return _anchorUser;
  }

  Future<List<Agent>> getAgents(String anchorId) async {
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
      var qs = await firestore
          .collection('agents')
          .where('anchorId', isEqualTo: anchorId)
          .getDocuments();

      _agents.clear();
      qs.documents.forEach((doc) {
        _agents.add(Agent.fromJson(doc.data));
      });

      _busies.clear();
      _busies.add(false);
      _busyController.sink.add(_busies);
      _agentController.sink.add(_agents);
      p('🌿 🌿 🌿 Agents found on database : 🎁  ${_agents.length} 🎁 ');
    } catch (e) {
      p(e);
      _errors.clear();
      _errors.add('Firestore agent query failed');
      _errorController.sink.add(_errors);
    }
    return _agents;
  }

  Future<List<Client>> getClients(String agentId) async {
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
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
    } catch (e) {
      p(e);
      _errors.clear();
      _errors.add('Firestore agent query failed');
      _errorController.sink.add(_errors);
    }
    return _clients;
  }

  Future<Balances> getBalances(String accountId) async {
    try {
      _busies.add(true);
      _busyController.sink.add(_busies);
      //todo - get balances
      var result = await NetUtil.get(
          headers: null,
          apiRoute: 'getAccountUsingAccountId?accountId=$accountId');
      p('\n\n🔆 🔆 🔆 AgentBloc:getBalances ️️❤️  printing the result from the get call ...');
      p(result);
      var mBalances = Balances.fromJson(result);
      _balances.clear();
      _balances.add(mBalances);
      _balancesController.sink.add(_balances);

      _busies.clear();
      _busies.add(false);
      _busyController.sink.add(_busies);
      _balancesController.sink.add(_balances);

      p('🌿 🌿 🌿 Balances found on database : 🎁 in stream: ${_balances.length} 🎁 ');
    } catch (e) {
      p(e);
      _errors.clear();
      _errors.add('Firestore balances query failed');
      _errorController.sink.add(_errors);
    }
    return _balances.last;
  }

  closeStreams() {
    _agentController.close();
    _errorController.close();
    _busyController.close();
    _clientController.close();
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
