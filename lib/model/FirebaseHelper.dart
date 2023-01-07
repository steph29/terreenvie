// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'MyUser.dart';

// class FirebaseHelper {
//   // Authentifier

//   final FirebaseAuth auth = FirebaseAuth.instance;
//   MyUser _userFromFirebaseUser(User user) {
//     user != null ? MyUser(uid: user.uid) : null;
//   }

//   Stream<MyUser> get user {
//     return auth.authStateChanges().map(_userFromFirebaseUser);
//   }

//   Future signInWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential result = await auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       User user = result.user!;
//       return _userFromFirebaseUser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future registerInWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential result = await auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       User user = result.user!;
//       return _userFromFirebaseUser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future signOut() async {
//     try {
//       return await auth.signOut();
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future<User> handleSignIn(String mail, String mdp) async {
//     User user;
//     try {
//       final signin =
//           (await auth.signInWithEmailAndPassword(email: mail, password: mdp))
//               .user;
//       final user = signin;
//       return user!;
//     } catch (e) {
//       print(e);
//       rethrow;
//     }
//   }

//   Future<User> create(
//       String mail, String mdp, String prenom, String nom) async {
//     User user;
//     try {
//       final create = (await auth.createUserWithEmailAndPassword(
//               email: mail, password: mdp))
//           .user;
//       final user = create;
//       String uid = user!.uid;
//       Map<String, String> map = {"prenom": prenom, "nom": nom, "uid": uid};
//       addUser(uid, map);
//       return user;
//     } catch (e) {
//       print(e);
//       rethrow;
//     }
//   }

//   // Database

//   static final entryPoint = FirebaseDatabase.instance.ref();

//   final entry_user = entryPoint.child("users");

//   addUser(String uid, Map map) {
//     entry_user.child(uid).set(map);
//   }
// }
