import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../api/fcm_service.dart';
import '../api/template_service.dart';
import '../api/email_service.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailBodyController = TextEditingController();
  final FCMService _fcmService = FCMService();
  final TemplateService _templateService = TemplateService();
  final EmailService _emailService = EmailService();
  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _selectedUserObjects = [];
  bool _sendToAll = false;

  // Variables séparées pour notifications et emails
  bool _useTemplatesNotifications = false;
  bool _useTemplatesEmails = false;
  String? _selectedTemplateNotifications;
  String? _selectedTemplateEmails;

  // Couleurs du thème
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFf2f0e7);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color accentColor = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
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
        _selectedTemplateNotifications = templateKey;
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

      if (_useTemplatesNotifications) {
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
        _selectedTemplateNotifications = null;
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

  Future<void> _sendEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String subject = _emailSubjectController.text.trim();
      final String body = _emailBodyController.text.trim();

      if (_useTemplatesEmails) {
        // Utiliser les emails personnalisés avec templates
        if (_sendToAll) {
          await _emailService.sendPersonalizedToAllUsers(subject, body);
        } else {
          final userIds =
              _selectedUserObjects.map((u) => u['id'] as String).toList();
          await _emailService.sendPersonalizedToSpecificUsers(
              userIds, subject, body);
        }
      } else {
        // Utiliser les emails simples
        if (_sendToAll) {
          await _emailService.sendToAllUsers(subject, body);
        } else {
          final userIds =
              _selectedUserObjects.map((u) => u['id'] as String).toList();
          await _emailService.sendToSpecificUsers(userIds, subject, body);
        }
      }

      // Réinitialiser le formulaire
      _emailSubjectController.clear();
      _emailBodyController.clear();
      setState(() {
        _selectedUserObjects.clear();
        _sendToAll = false;
        _selectedTemplateEmails = null;
      });

      Get.snackbar('Succès', 'Email(s) envoyé(s) avec succès !',
          backgroundColor: primaryColor,
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Communication',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.notifications),
              text: 'Notifications',
            ),
            Tab(
              icon: Icon(Icons.email),
              text: 'Emails',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildEmailsTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode de notification (simple ou personnalisée)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode de notification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('Notification simple'),
                              subtitle: Text('Même message pour tous'),
                              value: false,
                              groupValue: _useTemplatesNotifications,
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _useTemplatesNotifications = value!;
                                  _selectedTemplateNotifications = null;
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
                              groupValue: _useTemplatesNotifications,
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _useTemplatesNotifications = value!;
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
              if (_useTemplatesNotifications) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Templates prédéfinis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: TemplateService.predefinedTemplates.keys
                              .map((key) {
                            return ElevatedButton(
                              onPressed: () => _loadTemplate(key),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _selectedTemplateNotifications == key
                                        ? primaryColor
                                        : Colors.grey[300],
                                foregroundColor:
                                    _selectedTemplateNotifications == key
                                        ? Colors.white
                                        : textColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(key),
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
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contenu de la notification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Titre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un titre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _bodyController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un message';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Sélection des destinataires
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destinataires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      CheckboxListTile(
                        title: Text('Envoyer à tous les utilisateurs'),
                        value: _sendToAll,
                        activeColor: primaryColor,
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
                        SizedBox(height: 12),
                        Text(
                          'Ou sélectionner des utilisateurs spécifiques:',
                          style: TextStyle(color: accentColor),
                        ),
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
                                title: Text(user['name']),
                                subtitle: Text(user['email']),
                                value: isSelected,
                                activeColor: primaryColor,
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
              ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Envoyer la notification',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailsTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _emailFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode d'email (simple ou personnalisé)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode d\'email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('Email simple'),
                              subtitle: Text('Même message pour tous'),
                              value: false,
                              groupValue: _useTemplatesEmails,
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _useTemplatesEmails = value!;
                                  _selectedTemplateEmails = null;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('Email personnalisé'),
                              subtitle:
                                  Text('Message adapté à chaque utilisateur'),
                              value: true,
                              groupValue: _useTemplatesEmails,
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _useTemplatesEmails = value!;
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

              // Templates prédéfinis pour emails (si mode personnalisé)
              if (_useTemplatesEmails) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Templates d\'emails prédéfinis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Rappel créneau',
                            'Confirmation inscription',
                            'Annulation créneau',
                            'Bienvenue',
                            'Remerciement',
                          ].map((template) {
                            return ElevatedButton(
                              onPressed: () => _loadEmailTemplate(template),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _selectedTemplateEmails == template
                                        ? primaryColor
                                        : Colors.grey[300],
                                foregroundColor:
                                    _selectedTemplateEmails == template
                                        ? Colors.white
                                        : textColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(template),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Variables disponibles pour la personnalisation:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: TemplateService.availableVariables.keys
                              .map((variable) {
                            return Chip(
                              label: Text(variable),
                              backgroundColor: primaryColor.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Formulaire d'email
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contenu de l\'email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailSubjectController,
                        decoration: InputDecoration(
                          labelText: 'Objet',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un objet';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailBodyController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        maxLines: 8,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un message';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Sélection des destinataires avec autocomplete
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destinataires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      CheckboxListTile(
                        title: Text('Envoyer à tous les utilisateurs'),
                        value: _sendToAll,
                        activeColor: primaryColor,
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
                        SizedBox(height: 12),
                        Text(
                          'Ou sélectionner des utilisateurs spécifiques:',
                          style: TextStyle(color: accentColor),
                        ),
                        SizedBox(height: 8),

                        // Autocomplete pour la sélection d'utilisateurs
                        Autocomplete<Map<String, dynamic>>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _users;
                            }
                            return _users.where((user) {
                              final name =
                                  user['name'].toString().toLowerCase();
                              final email =
                                  user['email'].toString().toLowerCase();
                              final query = textEditingValue.text.toLowerCase();
                              return name.contains(query) ||
                                  email.contains(query);
                            });
                          },
                          displayStringForOption: (option) =>
                              '${option['name']} (${option['email']})',
                          onSelected: (Map<String, dynamic> selection) {
                            if (!_selectedUserObjects
                                .any((u) => u['id'] == selection['id'])) {
                              setState(() {
                                _selectedUserObjects.add(selection);
                              });
                            }
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Rechercher un utilisateur...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: primaryColor, width: 2),
                                ),
                                suffixIcon:
                                    Icon(Icons.search, color: primaryColor),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 12),

                        // Liste des utilisateurs sélectionnés avec puces
                        if (_selectedUserObjects.isNotEmpty) ...[
                          Text(
                            'Utilisateurs sélectionnés:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedUserObjects.map((user) {
                              return Chip(
                                label: Text(user['name']),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedUserObjects.removeWhere(
                                        (u) => u['id'] == user['id']);
                                  });
                                },
                                backgroundColor: primaryColor.withOpacity(0.1),
                                labelStyle: TextStyle(color: primaryColor),
                                deleteIconColor: primaryColor,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Bouton d'envoi d'email
              ElevatedButton(
                onPressed: _isLoading ? null : _sendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Envoyer l\'email',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadEmailTemplate(String templateKey) {
    final templates = {
      'Rappel créneau': {
        'subject': 'Rappel - Votre créneau Terre en Vie',
        'body':
            'Bonjour {prenom},\n\nCeci est un rappel pour votre créneau de bénévolat.\n\nCordialement,\nL\'équipe Terre en Vie',
      },
      'Confirmation inscription': {
        'subject': 'Confirmation d\'inscription - Terre en Vie',
        'body':
            'Bonjour {prenom},\n\nVotre inscription a été confirmée avec succès.\n\nMerci de votre engagement !\nL\'équipe Terre en Vie',
      },
      'Annulation créneau': {
        'subject': 'Annulation de créneau - Terre en Vie',
        'body':
            'Bonjour {prenom},\n\nVotre créneau a été annulé.\n\nNous vous remercions de votre compréhension.\nL\'équipe Terre en Vie',
      },
      'Bienvenue': {
        'subject': 'Bienvenue chez Terre en Vie',
        'body':
            'Bonjour {prenom},\n\nBienvenue dans notre communauté de bénévoles !\n\nNous sommes ravis de vous compter parmi nous.\nL\'équipe Terre en Vie',
      },
      'Remerciement': {
        'subject': 'Merci pour votre participation - Terre en Vie',
        'body':
            'Bonjour {prenom},\n\nMerci pour votre participation et votre engagement.\n\nVotre contribution est précieuse !\nL\'équipe Terre en Vie',
      },
    };

    final template = templates[templateKey];
    if (template != null) {
      setState(() {
        _emailSubjectController.text = template['subject']!;
        _emailBodyController.text = template['body']!;
        _selectedTemplateEmails = templateKey;
      });
    }
  }
}
