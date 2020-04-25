import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stellar_anchor_library/models/anchor.dart';
import 'package:stellar_anchor_library/util/prefs.dart';

class Auth {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static var _firestore = Firestore.instance;

  static Future<bool> checkAuthenticated() async {
    var user = await _auth.currentUser();
    if (user == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<AnchorUser> signIn({String email, String password}) async {
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
      user = AnchorUser.fromJson(element.data);
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
      anchor = Anchor.fromJson(element.data);
    });
    Prefs.saveAnchor(anchor);
    return user;
  }
}
