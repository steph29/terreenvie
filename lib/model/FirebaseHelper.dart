import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {
  // Authentifier

  final auth = FirebaseAuth.instance;

  Future<User> handleSignIn(String mail, String mdp) async {
    User user;
    try {
      final signin =
          (await auth.signInWithEmailAndPassword(email: mail, password: mdp))
              .user;
      final user = signin;
      return user!;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<User> create(
      String mail, String mdp, String prenom, String nom) async {
    User user;
    try {
      final create = (await auth.createUserWithEmailAndPassword(
              email: mail, password: mdp))
          .user;
      final user = create;
      String uid = user!.uid;
      Map<String, String> map = {"prenom": prenom, "nom": nom, "uid": uid};
      addUser(uid, map);
      return user;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // Database

  static final entryPoint = FirebaseDatabase.instance.ref();

  final entry_user = entryPoint.child("users");

  addUser(String uid, Map map) {
    entry_user.child(uid).set(map);
  }
}
