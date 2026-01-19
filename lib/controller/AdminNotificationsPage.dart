import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/fcm_service.dart';
import '../api/email_service.dart';
import 'dart:convert'; // pour base64Encode
import '../api/email_config.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _emailSubjectController = TextEditingController();
  final _emailBodyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  final FCMService _fcmService = FCMService();
  final EmailService _emailService = EmailService();

  bool _isLoading = false;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _selectedUserObjects = [];
  TextEditingController? _userSearchController;
  FocusNode? _userSearchFocusNode;

  bool _sendToAll = false;

  bool _useTemplatesNotifications = false;
  bool _useTemplatesEmails = false;
  String? _selectedEmailTemplateKey;

  PlatformFile? _selectedAttachment;

  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFf2f0e7);

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

  // ----------------------------------------------------------
  // DATA
  // ----------------------------------------------------------

  Future<void> _loadUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (!mounted) return;

      setState(() {
        _users = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'.trim(),
            'email': data['email'] ?? '',
            'fcmToken': data['fcmToken'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Erreur chargement users: $e');
    }
  }

  // ----------------------------------------------------------
  // NOTIFICATIONS
  // ----------------------------------------------------------

  Future<void> _sendNotification() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();

      if (_useTemplatesNotifications) {
        if (_sendToAll) {
          await _fcmService.sendPersonalizedToAllUsers(title, body);
        } else {
          final ids =
              _selectedUserObjects.map((u) => u['id'] as String).toList();
          await _fcmService.sendPersonalizedToSpecificUsers(ids, title, body);
        }
      } else {
        if (_sendToAll) {
          await _fcmService.sendToAllUsers(title, body);
        } else {
          final ids =
              _selectedUserObjects.map((u) => u['id'] as String).toList();
          await _fcmService.sendToSpecificUsers(ids, title, body);
        }
      }

      _resetNotificationForm();

      Get.snackbar(
        'Succès',
        'Notification(s) envoyée(s) avec succès !',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'envoi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetNotificationForm() {
    _titleController.clear();
    _bodyController.clear();
    setState(() {
      _selectedUserObjects.clear();
      _sendToAll = false;
    });
  }

  // ----------------------------------------------------------
  // EMAILS (100% Firebase Functions onCall)
  // ----------------------------------------------------------

  Future<void> _sendEmail() async {
    FocusScope.of(context).unfocus();
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
            'Utilisateur non authentifié. Veuillez vous reconnecter.');
      }

      // 🔹 Refresh token pour debug / web
      final idToken = await user.getIdToken(true);
      print('USER ID: ${user.uid}');
      if (idToken != null) {
        print('ID TOKEN: ${idToken.substring(0, 20)}...');
      }

      final subject = _emailSubjectController.text.trim();
      final body = _emailBodyController.text.trim();

      // Préparer la pièce jointe si présente
      Map<String, dynamic>? attachmentMap;
      if (_selectedAttachment != null && _selectedAttachment!.bytes != null) {
        attachmentMap = {
          'content': base64Encode(_selectedAttachment!.bytes!),
          'filename': _selectedAttachment!.name,
          'type': _selectedAttachment!.extension == null
              ? 'application/octet-stream'
              : 'application/${_selectedAttachment!.extension}',
        };
      }

      // Destinataires
      final selectedEmails = !_sendToAll
          ? _selectedUserObjects.map((u) => u['email'] as String).toList()
          : null;

      if (_useTemplatesEmails) {
        // ----- EMAILS PERSONNALISÉS -----
        if (_selectedEmailTemplateKey == 'Résumé inscriptions') {
          final selectedUserIds =
              _selectedUserObjects.map((u) => u['id'] as String).toList();

          if (_sendToAll) {
            await _emailService.sendRegistrationSummaryToAllUsers(
              subject: subject,
              bodyTemplate: body,
              attachment: attachmentMap,
            );
          } else if (selectedUserIds.isNotEmpty) {
            await _emailService.sendRegistrationSummaryToSpecificUsers(
              userIds: selectedUserIds,
              subject: subject,
              bodyTemplate: body,
              attachment: attachmentMap,
            );
          } else {
            throw Exception('Aucun destinataire sélectionné pour le résumé.');
          }
        } else {
          if (_sendToAll) {
            await _emailService.sendPersonalizedToAllUsers(
              subject: subject,
              bodyTemplate: body,
              attachment: attachmentMap,
            );
          } else if (selectedEmails != null && selectedEmails.isNotEmpty) {
            await _emailService.sendPersonalizedToSpecificUsers(
              selectedEmails: selectedEmails,
              subject: subject,
              bodyTemplate: body,
              attachment: attachmentMap,
            );
          } else {
            throw Exception(
                'Aucun destinataire sélectionné pour les emails personnalisés.');
          }
        }
      } else {
        // ----- EMAILS SIMPLES / EN MASSE -----
        if (_sendToAll) {
          final allEmails = _users.map((u) => u['email'] as String).toList();
          await _emailService.sendBulkEmails(
            emails: allEmails,
            subject: subject,
            body: body,
            attachment: attachmentMap,
          );
        } else if (selectedEmails != null && selectedEmails.isNotEmpty) {
          await _emailService.sendBulkEmails(
            emails: selectedEmails,
            subject: subject,
            body: body,
            attachment: attachmentMap,
          );
        } else {
          throw Exception('Aucun destinataire sélectionné pour les emails.');
        }
      }

      _resetEmailForm();

      Get.snackbar(
        'Succès',
        'Email(s) envoyé(s) avec succès !',
        backgroundColor: primaryColor,
        colorText: Colors.white,
      );
    } catch (e, stack) {
      print('❌ _sendEmail error: $e');
      print(stack);
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'envoi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetEmailForm() {
    _emailSubjectController.clear();
    _emailBodyController.clear();
    setState(() {
      _selectedUserObjects.clear();
      _sendToAll = false;
      _selectedAttachment = null;
      _useTemplatesEmails = false;
      _selectedEmailTemplateKey = null;
    });
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Communication',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            Tab(icon: Icon(Icons.email), text: 'Emails'),
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

  // ----------------------------------------------------------
  // NOTIFICATIONS TAB (inchangé UI)
  // ----------------------------------------------------------

  Widget _buildNotificationsTab() {
    return _buildBaseTab(
      formKey: _formKey,
      titleController: _titleController,
      bodyController: _bodyController,
      onSend: _sendNotification,
      isEmail: false,
    );
  }

  // ----------------------------------------------------------
  // EMAILS TAB (inchangé UI + attachment)
  // ----------------------------------------------------------

  Widget _buildEmailsTab() {
    return _buildBaseTab(
      formKey: _emailFormKey,
      titleController: _emailSubjectController,
      bodyController: _emailBodyController,
      onSend: _sendEmail,
      isEmail: true,
    );
  }

  // ----------------------------------------------------------
  // SHARED UI
  // ----------------------------------------------------------

  Widget _buildBaseTab({
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController bodyController,
    required VoidCallback onSend,
    required bool isEmail,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRecipientsCard(isEmail: isEmail),
              const SizedBox(height: 16),
              _buildContentCard(
                titleController,
                bodyController,
                isEmail: isEmail,
              ),
              if (isEmail) ...[
                const SizedBox(height: 16),
                _buildAttachmentPicker(),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEmail
                            ? 'Envoyer l\'email'
                            : 'Envoyer la notification',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------

  Widget _buildRecipientsCard({required bool isEmail}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEmail ? 'Destinataires (sélection multiple)' : 'Destinataires',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Envoyer à tous les utilisateurs'),
            value: _sendToAll,
            onChanged: (v) {
              setState(() {
                _sendToAll = v!;
                if (_sendToAll) _selectedUserObjects.clear();
              });
            },
          ),
          if (!_sendToAll)
            isEmail ? _buildUserMultiSelect() : _buildUserAutocomplete(),
        ]),
      ),
    );
  }

  Widget _buildUserMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedUserObjects.isNotEmpty) _buildSelectedUsersChips(),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (value) {
            final query = value.text.toLowerCase();
            final candidates = _users.where((u) {
              if (_selectedUserObjects.any((s) => s['id'] == u['id'])) {
                return false;
              }
              if (query.isEmpty) return true;
              return u['name'].toLowerCase().contains(query) ||
                  u['email'].toLowerCase().contains(query);
            }).toList();
            return candidates;
          },
          displayStringForOption: (o) => '${o['name']} (${o['email']})',
          onSelected: (u) {
            if (!_selectedUserObjects.any((e) => e['id'] == u['id'])) {
              setState(() => _selectedUserObjects.add(u));
              _userSearchController?.clear();
              _userSearchFocusNode?.requestFocus();
            }
          },
          fieldViewBuilder: (c, t, f, s) {
            _userSearchController ??= t;
            _userSearchFocusNode ??= f;
            return TextFormField(
              controller: t,
              focusNode: f,
              decoration: const InputDecoration(
                labelText: 'Ajouter un utilisateur...',
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedUsersChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedUserObjects.map((u) {
          return InputChip(
            label: Text('${u['name']}'),
            onDeleted: () {
              setState(() {
                _selectedUserObjects.removeWhere((e) => e['id'] == u['id']);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserAutocomplete() {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (value) {
        if (value.text.isEmpty) return _users;
        return _users.where((u) {
          final q = value.text.toLowerCase();
          return u['name'].toLowerCase().contains(q) ||
              u['email'].toLowerCase().contains(q);
        });
      },
      displayStringForOption: (o) => '${o['name']} (${o['email']})',
      onSelected: (u) {
        if (!_selectedUserObjects.any((e) => e['id'] == u['id'])) {
          setState(() => _selectedUserObjects.add(u));
        }
      },
      fieldViewBuilder: (c, t, f, s) => TextFormField(
        controller: t,
        focusNode: f,
        decoration: const InputDecoration(
          labelText: 'Rechercher un utilisateur...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildContentCard(
    TextEditingController title,
    TextEditingController body, {
    required bool isEmail,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (isEmail) ...[
            SwitchListTile(
              title: const Text('Utiliser un template d’email'),
              value: _useTemplatesEmails,
              onChanged: (v) {
                setState(() {
                  _useTemplatesEmails = v;
                  if (!_useTemplatesEmails) {
                    _selectedEmailTemplateKey = null;
                  }
                });
              },
            ),
            if (_useTemplatesEmails)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Template d’email',
                  border: OutlineInputBorder(),
                ),
                value: _selectedEmailTemplateKey,
                items: EmailConfig.emailTemplates.keys
                    .map((key) => DropdownMenuItem(
                          value: key,
                          child: Text(key),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmailTemplateKey = value;
                  });
                  _applyEmailTemplate(value, title, body);
                },
                validator: (value) {
                  if (_useTemplatesEmails && value == null) {
                    return 'Veuillez sélectionner un template';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: title,
            decoration: const InputDecoration(
                labelText: 'Titre / Objet', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: body,
            maxLines: 6,
            decoration: const InputDecoration(
                labelText: 'Message', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
        ]),
      ),
    );
  }

  void _applyEmailTemplate(
    String? templateKey,
    TextEditingController title,
    TextEditingController body,
  ) {
    if (templateKey == null) return;
    final template = EmailConfig.emailTemplates[templateKey];
    if (template == null) return;

    title.text = template['subject'] ?? '';
    body.text = template['body'] ?? '';
  }

  Widget _buildAttachmentPicker() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pièce jointe (optionnel)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: Text(
                    _selectedAttachment?.name ?? 'Sélectionner un fichier'),
                onPressed: _pickAttachment,
              ),
            ),
            if (_selectedAttachment != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() => _selectedAttachment = null),
              ),
          ])
        ]),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedAttachment = result.files.first);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sélection du fichier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
