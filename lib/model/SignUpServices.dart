// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terreenvie/api/email_service.dart';

signUpserv(String userEmail, String userPassword, String userName,
    String userPrenom, String userPhone, String profil, String role) async {
  User? userid = FirebaseAuth.instance.currentUser;

  try {
    await FirebaseFirestore.instance.collection("users").doc(userid!.uid).set({
      'nom': userName,
      'prenom': userPrenom,
      'tel': userPhone,
      'email': userEmail,
      'createdAt': DateTime.now(),
      'UserId': userid.uid,
      'role': 'ben',
      'profil': 'ben'
    });

    // Envoyer l'email de bienvenue
    print('🎉 Compte créé avec succès, envoi de l\'email de bienvenue...');
    final emailService = EmailService();
    final welcomeEmailSent = await emailService.sendWelcomeEmail(
      email: userEmail,
      prenom: userPrenom,
      nom: userName,
    );

    if (welcomeEmailSent) {
      print('✅ Email de bienvenue envoyé avec succès');
    } else {
      print('⚠️ Échec de l\'envoi de l\'email de bienvenue');
    }

    // Déconnexion de l'utilisateur
    await FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (e) {
    print("Error $e");
  } catch (e) {
    print("Erreur générale lors de l'inscription: $e");
  }
}
