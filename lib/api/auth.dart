import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stellar_anchor_library/models/agent.dart';
import 'package:stellar_anchor_library/models/anchor.dart';
import 'package:stellar_anchor_library/models/client.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/prefs.dart';
import 'package:stellar_anchor_library/util/util.dart';

class Auth {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static var _firestore = Firestore.instance;

  static Future<bool> checkAuthenticated() async {
    var user = _auth.currentUser;
    if (user == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<AnchorUser> signInAnchor(
      {String email, String password}) async {
    var result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (result.user == null) {
      throw Exception("Sign In Failed");
    }
    //get anchorUser
    var qs = await _firestore
        .collection("anchorUsers")
        .limit(1)
        .where("userId", isEqualTo: result.user.uid)
        .getDocuments();

    AnchorUser user;
    qs.documents.forEach((element) {
      user = AnchorUser.fromJson(element.data());
    });
    Prefs.saveAnchorUser(user);
    //get anchorUser
    qs = await _firestore
        .collection("anchors")
        .limit(1)
        .where("anchorId", isEqualTo: user.anchorId)
        .getDocuments();

    Anchor anchor;
    qs.documents.forEach((element) {
      anchor = Anchor.fromJson(element.data());
    });
    Prefs.saveAnchor(anchor);
    return user;
  }

  static Future<Agent> signInAgent({String email, String password}) async {
    p('🦕 🦕 Sign in started ......');
    var result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (result.user == null) {
      throw Exception("Sign In Failed");
    }
    //get agent
    var qs = await _firestore
        .collection("agents")
        .limit(1)
        .where("agentId", isEqualTo: result.user.uid)
        .getDocuments();

    p('🦕 🦕 Agent query executed: ${qs.documents.length} agent found ......');
    Agent agent;
    qs.documents.forEach((element) {
      agent = Agent.fromJson(element.data());
    });

    Prefs.saveAgent(agent);
    //get anchor
    qs = await _firestore
        .collection("anchors")
        .limit(1)
        .where("anchorId", isEqualTo: agent.anchorId)
        .getDocuments();
    p('🦕 🦕 Anchor query executed: ${qs.documents.length} anchor found ......');
    Anchor anchor;
    qs.documents.forEach((element) {
      anchor = Anchor.fromJson(element.data());
    });

    Prefs.saveAnchor(anchor);

    p('🦕 🦕 😎 😎 😎 Sign in executed OK: anchor saved:  ......');
    prettyPrint(anchor.toJson(), "😎 ANCHOR cached for later: ${anchor.name} ");
    p('🦕 🦕 😎 😎 😎 Sign in executed OK: returning agent  ......');
    prettyPrint(agent.toJson(),
        "😎 .... returning AGENT: ${agent.personalKYCFields.getFullName()}");
    return agent;
  }

  static Future<Client> signInClient({String email, String password}) async {
    p('🦕 🦕 ........... Sign in started ......');
    var result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (result.user == null) {
      throw Exception("Sign In Failed");
    }
    //get client
    var qs = await _firestore
        .collection("clients")
        .limit(1)
        .where("clientId", isEqualTo: result.user.uid)
        .getDocuments();

    p('🦕 🦕 Client query executed: ${qs.documents.length} client found ......');
    Client client;
    qs.documents.forEach((element) {
      client = Client.fromJson(element.data());
    });

    Prefs.saveClient(client);
    //get anchor
    qs = await _firestore
        .collection("anchors")
        .limit(1)
        .where("anchorId", isEqualTo: client.anchorId)
        .getDocuments();
    p('🦕 🦕 Anchor query executed: ${qs.documents.length} anchor found ......');
    Anchor anchor;
    qs.documents.forEach((element) {
      anchor = Anchor.fromJson(element.data());
    });

    Prefs.saveAnchor(anchor);

    p('🦕 🦕 😎 😎 😎 Sign in executed OK: anchor saved:  ......');
    prettyPrint(anchor.toJson(), "😎 ANCHOR cached for later: ${anchor.name} ");
    p('🦕 🦕 😎 😎 😎 Sign in executed OK: returning client  ......');
    prettyPrint(client.toJson(),
        "😎 .... returning AGENT: ${client.personalKYCFields.getFullName()}");
    return client;
  }

  static Future registerClient(Client client) async {}
}
