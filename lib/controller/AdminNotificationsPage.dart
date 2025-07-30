import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../api/fcm_service.dart';
import '../api/template_service.dart';

class AdminNotificationsPage extends StatefulWidget {
  @override
  _AdminNotificationsPageState createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final FCMService _fcmService = FCMService();
  final TemplateService _templateService = TemplateService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _selectedUserObjects = [];
  bool _sendToAll = false;
  bool _useTemplates = false;
  String? _selectedTemplate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadTemplate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      setState(() {
        _users = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'nom': data['nom'] ?? '',
            'prenom': data['prenom'] ?? '',
            'email': data['email'] ?? '',
            'role': data['role'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  void _loadTemplate() {
    if (_selectedTemplate != null) {
      final template =
          _templateService.getPredefinedTemplate(_selectedTemplate!);
      if (template != null) {
        _titleController.text = template['title'] ?? '';
        _bodyController.text = template['body'] ?? '';
      }
    }
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir le titre et le corps de la notification',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_sendToAll && _selectedUserObjects.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner au moins un utilisateur ou cocher "Envoyer à tous"',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();

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

      Get.snackbar(
        'Succès',
        'Notification envoyée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Réinitialiser le formulaire
      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _selectedUserObjects.clear();
        _sendToAll = false;
      });
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'envoi de la notification: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        backgroundColor: Color.fromRGBO(43, 90, 114, 1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode de notification
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode de notification',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    RadioListTile<bool>(
                      title: Text('Notification simple'),
                      value: false,
                      groupValue: _useTemplates,
                      onChanged: (value) {
                        setState(() {
                          _useTemplates = value!;
                          _selectedTemplate = null;
                          _titleController.clear();
                          _bodyController.clear();
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title:
                          Text('Notification personnalisée (avec templates)'),
                      value: true,
                      groupValue: _useTemplates,
                      onChanged: (value) {
                        setState(() {
                          _useTemplates = value!;
                        });
                      },
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Templates prédéfinis',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _templateService
                            .getPredefinedTemplateNames()
                            .map((templateName) {
                          final template = _templateService
                              .getPredefinedTemplate(templateName);
                          final title = template?['title'] ?? '';
                          final displayTitle = title.length > 20
                              ? '${title.substring(0, 20)}...'
                              : title;

                          return FilterChip(
                            label: Text(displayTitle),
                            selected: _selectedTemplate == templateName,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTemplate =
                                    selected ? templateName : null;
                                _loadTemplate();
                              });
                            },
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Variables disponibles',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _templateService.availableVariables.entries
                            .map((entry) {
                          return Chip(
                            label: Text('{${entry.key}}'),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Formulaire de notification
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenu de la notification',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _bodyController,
                      decoration: InputDecoration(
                        labelText: 'Corps du message',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Sélection des destinataires
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destinataires',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text('Envoyer à tous les utilisateurs'),
                      value: _sendToAll,
                      onChanged: (value) {
                        setState(() {
                          _sendToAll = value!;
                          if (_sendToAll) {
                            _selectedUserObjects.clear();
                          }
                        });
                      },
                    ),
                    if (!_sendToAll) ...[
                      SizedBox(height: 8),
                      Text('Ou sélectionner des utilisateurs spécifiques:'),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final isSelected = _selectedUserObjects
                                .any((u) => u['id'] == user['id']);

                            return CheckboxListTile(
                              title: Text('${user['prenom']} ${user['nom']}'),
                              subtitle:
                                  Text('${user['email']} (${user['role']})'),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    _selectedUserObjects.add(user);
                                  } else {
                                    _selectedUserObjects.removeWhere(
                                        (u) => u['id'] == user['id']);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Bouton d'envoi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(43, 90, 114, 1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Envoyer la notification',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
