import 'dart:convert';
import 'package:http/http.dart' as http;

class WebEmailService {
  // Utiliser un service d'email tiers comme alternative
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      // Configuration pour EmailJS (service gratuit)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': 'YOUR_SERVICE_ID', // À configurer
          'template_id': 'YOUR_TEMPLATE_ID', // À configurer
          'user_id': 'YOUR_USER_ID', // À configurer
          'template_params': {
            'to_email': to,
            'subject': subject,
            'message': body,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email envoyé via API externe');
        return true;
      } else {
        print('❌ Erreur API: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi via API: $e');
      return false;
    }
  }

  // Alternative avec un service SMTP en ligne
  static Future<bool> sendEmailViaSMTP({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      // Utiliser un service comme SendGrid, Mailgun, etc.
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer YOUR_SENDGRID_API_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': to}
              ]
            }
          ],
          'from': {'email': 'benevole@terreenvie.com', 'name': 'Terre en Vie'},
          'subject': subject,
          'content': [
            {'type': 'text/plain', 'value': body}
          ]
        }),
      );

      if (response.statusCode == 202) {
        print('✅ Email envoyé via SendGrid');
        return true;
      } else {
        print('❌ Erreur SendGrid: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi via SendGrid: $e');
      return false;
    }
  }
}
