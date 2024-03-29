import 'package:firebase_database/firebase_database.dart';

class MyUser {
  String? uid;
  String? prenom;
  String? nom;

  MyUser(DataSnapshot snapshot, {String? uid}) {
    uid = snapshot.key;
    prenom = (snapshot.value as Map)['prenom'];
    nom = (snapshot.value as Map)['nom'];
  }
  Map toMap() {
    return {"prenom": prenom, "nom": nom, "uid": uid};
  }
}
