import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables disponibles dans les templates
  final Map<String, String> availableVariables = {
    'nom': 'Nom de l\'utilisateur',
    'prenom': 'Prénom de l\'utilisateur',
    'email': 'Email de l\'utilisateur',
    'role': 'Rôle de l\'utilisateur',
    'poste': 'Nom du poste de bénévolat',
    'debut': 'Heure de début du créneau',
    'fin': 'Heure de fin du créneau',
    'jour': 'Jour de la semaine',
    'desc': 'Description du poste',
    'date': 'Date actuelle',
    'heure': 'Heure actuelle',
  };

  // Templates prédéfinis
  final Map<String, Map<String, String>> predefinedTemplates = {
    'rappel_creneau': {
      'title': 'Rappel: Votre créneau {poste} {jour}',
      'body':
          'Bonjour {prenom}, rappel pour votre créneau {poste} de {debut} à {fin} le {jour}.',
    },
    'nouveau_poste': {
      'title': 'Nouveau poste disponible: {poste}',
      'body':
          'Un nouveau poste "{poste}" est disponible le {jour} de {debut} à {fin}.',
    },
    'annulation_creneau': {
      'title': 'Annulation: Créneau {poste} {jour}',
      'body': 'Le créneau {poste} du {jour} de {debut} à {fin} a été annulé.',
    },
    'bienvenue': {
      'title': 'Bienvenue {prenom} !',
      'body':
          'Merci de vous être inscrit sur Terre en Vie. Votre compte a été créé avec succès.',
    },
    'modification_poste': {
      'title': 'Modification: Poste {poste}',
      'body':
          'Le poste "{poste}" a été modifié. Consultez les détails dans l\'application.',
    },
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
    result = result.replaceAll('{role}', userData['role']?.toString() ?? '');

    // Variables de créneau
    if (creneauData != null) {
      result =
          result.replaceAll('{poste}', creneauData['poste']?.toString() ?? '');
      result =
          result.replaceAll('{debut}', creneauData['debut']?.toString() ?? '');
      result = result.replaceAll('{fin}', creneauData['fin']?.toString() ?? '');
      result =
          result.replaceAll('{jour}', creneauData['jour']?.toString() ?? '');
      result =
          result.replaceAll('{desc}', creneauData['desc']?.toString() ?? '');
    }

    // Variables de date/heure
    final now = DateTime.now();
    result = result.replaceAll('{date}', '${now.day}/${now.month}/${now.year}');
    result = result.replaceAll('{heure}',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');

    return result;
  }

  // Récupérer les créneaux d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserCreneaux(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('pos_ben')
          .where('ben_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> creneaux = [];
      for (var doc in querySnapshot.docs) {
        List<dynamic> posIds = doc.data()['pos_id'] ?? [];
        for (var pos in posIds) {
          creneaux.add(Map<String, dynamic>.from(pos));
        }
      }

      return creneaux;
    } catch (e) {
      print('Erreur lors de la récupération des créneaux: $e');
      return [];
    }
  }

  // Récupérer les données d'un utilisateur
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Générer des notifications personnalisées
  Future<List<Map<String, String>>> generatePersonalizedNotifications(
    String titleTemplate,
    String bodyTemplate, {
    List<String>? userIds,
  }) async {
    try {
      List<Map<String, String>> notifications = [];

      // Récupérer tous les utilisateurs ou les utilisateurs spécifiés
      QuerySnapshot querySnapshot;
      if (userIds != null && userIds.isNotEmpty) {
        querySnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds)
            .get();
      } else {
        querySnapshot = await _firestore.collection('users').get();
      }

      for (var doc in querySnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final userId = doc.id;
        final fcmToken = userData['fcmToken'] as String?;

        if (fcmToken == null || fcmToken.isEmpty) {
          continue;
        }

        // Récupérer les créneaux de l'utilisateur
        final creneaux = await getUserCreneaux(userId);

        // Si l'utilisateur a des créneaux, créer une notification pour chaque créneau
        if (creneaux.isNotEmpty) {
          for (var creneau in creneaux) {
            final title = replaceVariables(titleTemplate, userData, creneau);
            final body = replaceVariables(bodyTemplate, userData, creneau);

            notifications.add({
              'title': title,
              'body': body,
              'token': fcmToken,
              'userId': userId,
            });
          }
        } else {
          // Si l'utilisateur n'a pas de créneaux, créer une notification sans données de créneau
          final title = replaceVariables(titleTemplate, userData, null);
          final body = replaceVariables(bodyTemplate, userData, null);

          notifications.add({
            'title': title,
            'body': body,
            'token': fcmToken,
            'userId': userId,
          });
        }
      }

      return notifications;
    } catch (e) {
      print(
          'Erreur lors de la génération des notifications personnalisées: $e');
      return [];
    }
  }

  // Récupérer un template prédéfini
  Map<String, String>? getPredefinedTemplate(String templateName) {
    return predefinedTemplates[templateName];
  }

  // Récupérer la liste des templates prédéfinis
  List<String> getPredefinedTemplateNames() {
    return predefinedTemplates.keys.toList();
  }
}
