import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateService {
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables disponibles dans les templates
  static const Map<String, String> availableVariables = {
    '{nom}': 'Nom de l\'utilisateur',
    '{prenom}': 'Prénom de l\'utilisateur',
    '{poste}': 'Poste assigné',
    '{jour}': 'Jour du créneau',
    '{debut}': 'Heure de début',
    '{fin}': 'Heure de fin',
    '{email}': 'Email de l\'utilisateur',
    '{role}': 'Rôle de l\'utilisateur',
    '{date}': 'Date actuelle',
    '{heure}': 'Heure actuelle',
  };

  // Remplacer les variables dans un template
  String replaceVariables(String template, Map<String, dynamic> userData,
      Map<String, dynamic>? creneauData) {
    String result = template;

    // Variables utilisateur
    result = result.replaceAll('{nom}', userData['nom']?.toString() ?? '');
    result =
        result.replaceAll('{prenom}', userData['prenom']?.toString() ?? '');
    result = result.replaceAll('{email}', userData['email']?.toString() ?? '');
    result = result.replaceAll('{role}', userData['profil']?.toString() ?? '');

    // Variables de créneau (si disponibles)
    if (creneauData != null) {
      result =
          result.replaceAll('{poste}', creneauData['poste']?.toString() ?? '');
      result =
          result.replaceAll('{jour}', creneauData['jour']?.toString() ?? '');
      result =
          result.replaceAll('{debut}', creneauData['debut']?.toString() ?? '');
      result = result.replaceAll('{fin}', creneauData['fin']?.toString() ?? '');
    }

    // Variables de date/heure
    DateTime now = DateTime.now();
    result = result.replaceAll('{date}', '${now.day}/${now.month}/${now.year}');
    result = result.replaceAll('{heure}',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');

    return result;
  }

  // Récupérer les données de créneaux d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserCreneaux(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('pos_ben')
          .where('ben_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> creneaux = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['pos_id'] != null && data['pos_id'] is List) {
          for (var pos in data['pos_id']) {
            if (pos is Map<String, dynamic>) {
              creneaux.add({
                'poste': pos['poste'] ?? '',
                'jour': pos['jour'] ?? '',
                'debut': pos['debut'] ?? '',
                'fin': pos['fin'] ?? '',
                'desc': pos['desc'] ?? '',
              });
            }
          }
        }
      }

      return creneaux;
    } catch (e) {
      print('Erreur lors de la récupération des créneaux: $e');
      return [];
    }
  }

  // Récupérer les données complètes d'un utilisateur
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('UserId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return {};
    }
  }

  // Générer des notifications personnalisées pour tous les utilisateurs
  Future<List<Map<String, dynamic>>> generatePersonalizedNotifications(
      String titleTemplate, String bodyTemplate,
      {List<String>? selectedUserIds}) async {
    List<Map<String, dynamic>> notifications = [];

    try {
      // Récupérer tous les utilisateurs ou les utilisateurs sélectionnés
      QuerySnapshot userSnapshot;
      if (selectedUserIds != null && selectedUserIds.isNotEmpty) {
        // Utilisateurs spécifiques
        userSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: selectedUserIds)
            .get();
      } else {
        // Tous les utilisateurs
        userSnapshot = await _firestore.collection('users').get();
      }

      for (var userDoc in userSnapshot.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userId = userDoc.id;

        // Récupérer les créneaux de l'utilisateur
        final creneaux = await getUserCreneaux(userId);

        if (creneaux.isNotEmpty) {
          // Créer une notification pour chaque créneau
          for (var creneau in creneaux) {
            final personalizedTitle =
                replaceVariables(titleTemplate, userData, creneau);
            final personalizedBody =
                replaceVariables(bodyTemplate, userData, creneau);

            notifications.add({
              'userId': userId,
              'userData': userData,
              'creneau': creneau,
              'title': personalizedTitle,
              'body': personalizedBody,
              'fcmToken': userData['fcmToken'],
            });
          }
        } else {
          // Utilisateur sans créneaux - notification générique
          final personalizedTitle =
              replaceVariables(titleTemplate, userData, null);
          final personalizedBody =
              replaceVariables(bodyTemplate, userData, null);

          notifications.add({
            'userId': userId,
            'userData': userData,
            'creneau': null,
            'title': personalizedTitle,
            'body': personalizedBody,
            'fcmToken': userData['fcmToken'],
          });
        }
      }
    } catch (e) {
      print(
          'Erreur lors de la génération des notifications personnalisées: $e');
    }

    return notifications;
  }

  // Templates prédéfinis
  static const Map<String, Map<String, String>> predefinedTemplates = {
    'bienvenue': {
      'title': 'Bienvenue chez Terre en Vie, {prenom} !',
      'body':
          'Bonjour {prenom} {nom},\n\nBienvenue dans la communauté Terre en Vie ! Nous sommes ravis de vous compter parmi nos bénévoles.\n\nVotre compte a été créé avec succès avec l\'adresse email : {email}\n\nVous pouvez dès maintenant vous connecter à votre tableau de bord pour voir vos créneaux et gérer votre profil.\n\nMerci de votre engagement !\n\nL\'équipe Terre en Vie',
    },
    'rappel_benevolat': {
      'title': 'Rappel bénévolat - {jour}',
      'body':
          'Bonjour {prenom} {nom}, tu as un créneau {poste} de {debut} à {fin} le {jour}. Merci !',
    },
    'rappel_general': {
      'title': 'Rappel - {jour}',
      'body':
          'Salut {prenom}, n\'oublie pas ton créneau {poste} le {jour} de {debut} à {fin}.',
    },
    'message_personnalise': {
      'title': 'Message pour {prenom}',
      'body':
          'Bonjour {prenom} {nom}, nous avons un message important pour toi.',
    },
    'rappel_urgent': {
      'title': 'URGENT - {poste} {jour}',
      'body':
          '{prenom}, nous avons besoin de toi pour {poste} le {jour} de {debut} à {fin}. Merci !',
    },
  };
}
