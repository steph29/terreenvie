import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../api/fcm_service.dart';
import '../api/template_service.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FCMService _fcmService = FCMService();
  final TemplateService _templateService = TemplateService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _selectedUserObjects = [];
  bool _sendToAll = false;
  bool _useTemplates = false;
  String? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _users = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'.trim(),
            'email': data['email'] ?? '',
            'fcmToken': data['fcmToken'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  void _loadTemplate(String templateKey) {
    final template = TemplateService.predefinedTemplates[templateKey];
    if (template != null) {
      setState(() {
        _titleController.text = template['title']!;
        _bodyController.text = template['body']!;
        _selectedTemplate = templateKey;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final String title = _titleController.text.trim();
      final String body = _bodyController.text.trim();

      if (_useTemplates) {
        // Utiliser les notifications personnalisées avec templates
        if (_sendToAll) {
          await _fcmService.sendPersonalizedToAllUsers(title, body);
        } else {
          final userIds =
              _selectedUserObjects.map((u) => u['id'] as String).toList();
          await _fcmService.sendPersonalizedToSpecificUsers(
              userIds, title, body);
        }
      } else {
        // Utiliser les notifications simples (ancienne méthode)
        if (_sendToAll) {
          await _fcmService.sendToAllUsers(title, body);
        } else {
          final userIds =
              _selectedUserObjects.map((u) => u['id'] as String).toList();
          await _fcmService.sendToSpecificUsers(userIds, title, body);
        }
      }

      // Réinitialiser le formulaire
      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _selectedUserObjects.clear();
        _sendToAll = false;
        _selectedTemplate = null;
      });

      Get.snackbar('Succès', 'Notification(s) envoyée(s) avec succès !',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3));
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'envoi: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Envoi de Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mode de notification (simple ou personnalisée)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mode de notification',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text('Notification simple'),
                                subtitle: Text('Même message pour tous'),
                                value: false,
                                groupValue: _useTemplates,
                                onChanged: (value) {
                                  setState(() {
                                    _useTemplates = value!;
                                    _selectedTemplate = null;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text('Notification personnalisée'),
                                subtitle:
                                    Text('Message adapté à chaque utilisateur'),
                                value: true,
                                groupValue: _useTemplates,
                                onChanged: (value) {
                                  setState(() {
                                    _useTemplates = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Templates prédéfinis (si mode personnalisé)
                if (_useTemplates) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Templates prédéfinis',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: TemplateService.predefinedTemplates.keys
                                .map((key) {
                              final template =
                                  TemplateService.predefinedTemplates[key]!;
                              String displayText = template['title']!
                                  .replaceAll('{', '')
                                  .replaceAll('}', '');
                              if (displayText.length > 20) {
                                displayText =
                                    displayText.substring(0, 20) + '...';
                              }
                              return ElevatedButton(
                                onPressed: () => _loadTemplate(key),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedTemplate == key
                                      ? Colors.green
                                      : Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(displayText),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Variables disponibles (si mode personnalisé)
                if (_useTemplates) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Variables disponibles',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: TemplateService.availableVariables.entries
                                .map((entry) {
                              return Chip(
                                label: Text(entry.key),
                                backgroundColor: Colors.blue.shade100,
                                onDeleted: () {
                                  // Copier la variable dans le presse-papiers
                                  // (pour l'instant, on affiche juste)
                                  Get.snackbar('Variable',
                                      'Variable ${entry.key} disponible',
                                      duration: Duration(seconds: 1));
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8),
                          Text('Cliquez sur une variable pour la copier',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Titre de la notification
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre de la notification',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Corps de la notification
                TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: 'Description (2 lignes max)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La description est requise';
                    }
                    if (value.length > 200) {
                      return 'La description est trop longue (max 200 caractères)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Sélection des destinataires
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Destinataires',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        CheckboxListTile(
                          title: Text('Envoyer à tous les utilisateurs'),
                          value: _sendToAll,
                          onChanged: (bool? value) {
                            setState(() {
                              _sendToAll = value ?? false;
                              if (_sendToAll) {
                                _selectedUserObjects.clear();
                              }
                            });
                          },
                        ),
                        if (!_sendToAll) ...[
                          SizedBox(height: 8),
                          Text('Ou sélectionner des utilisateurs spécifiques :',
                              style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Autocomplete<Map<String, dynamic>>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<
                                    Map<String, dynamic>>.empty();
                              }
                              return _users.where((user) =>
                                  user['name'].toLowerCase().contains(
                                      textEditingValue.text.toLowerCase()) &&
                                  !_selectedUserObjects.contains(user));
                            },
                            displayStringForOption: (user) => user['name'],
                            fieldViewBuilder: (context, controller, focusNode,
                                onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'Rechercher un nom',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              );
                            },
                            onSelected: (user) {
                              setState(() {
                                _selectedUserObjects.add(user);
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _selectedUserObjects
                                .map((user) => Chip(
                                      label: Text(user['name']),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedUserObjects.remove(user);
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Bouton d'envoi
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendNotification,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.send),
                  label: Text(_isLoading
                      ? 'Envoi en cours...'
                      : 'Envoyer la notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                SizedBox(height: 16),

                // Informations
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ℹ️ Informations',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800)),
                        SizedBox(height: 8),
                        Text(
                          _useTemplates
                              ? '• Notifications personnalisées avec variables\n'
                                  '• Chaque utilisateur reçoit un message adapté\n'
                                  '• Utilise les créneaux de bénévolat pour personnaliser'
                              : '• Notifications simples (même message pour tous)\n'
                                  '• Les utilisateurs doivent avoir accepté les notifications\n'
                                  '• Les tokens FCM sont récupérés automatiquement',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32), // Espace en bas pour le scroll
              ],
            ),
          ),
        ),
      ),
    );
  }
}
