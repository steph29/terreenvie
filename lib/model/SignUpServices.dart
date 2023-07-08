// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/Logcontroller.dart';

signUpserv(String userEmail, String userPassword, String userName,
    String userPrenom, String userPhone, String profil, String role) async {
  User? userid = FirebaseAuth.instance.currentUser;

  try {
    FirebaseFirestore.instance.collection("users").doc(userid!.uid).set({
      'nom': userName,
      'prenom': userPrenom,
      'tel': userPhone,
      'email': userEmail,
      'createdAt': DateTime.now(),
      'UserId': userid!.uid,
      'role': 'ben',
      'profil': 'ben'
    }).then((value) => {
          FirebaseAuth.instance.signOut(),
          // ignore: prefer_const_constructors
          // Get.to(() => LogController())
        });
  } on FirebaseAuthException catch (e) {
    print("Error $e");
  }
}
