import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:terreenvie/controller/DashboardPage.dart';
import 'package:terreenvie/controller/TerreEnVie.dart';
import 'package:terreenvie/controller/NotificationsPage.dart';
import 'package:terreenvie/controller/AdminNotificationsPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'AdminPage.dart';
import 'Analyse.dart';
import 'LogOutController.dart';
import 'Logcontroller.dart';
import 'SignUpPage.dart';
import 'comptePage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MainAppController extends StatefulWidget {
  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  User? userId; //= FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser;
    if (userId != null) {
      _checkUserAdminStatus();
      _saveFcmTokenForCurrentUser(); // Sauvegarder le token FCM
    } else {
      setState(() {
        isAdminVisible = false;
      });
    }
  }

  // Méthode pour sauvegarder automatiquement le token FCM
  Future<void> _saveFcmTokenForCurrentUser() async {
    try {
      if (userId != null) {
        String? token;

        if (kIsWeb) {
          // Sur le web, on simule un token FCM
          token = 'WEB_TOKEN_${DateTime.now().millisecondsSinceEpoch}';
          print('Token FCM simulé pour le web: $token');
        } else {
          // Sur mobile, on demande les permissions et on récupère le vrai token
          NotificationSettings settings =
              await FirebaseMessaging.instance.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            // Obtenir le token FCM
            token = await FirebaseMessaging.instance.getToken();
            print('Token FCM mobile: $token');
          } else {
            print('Notifications non autorisées par l\'utilisateur');
            return;
          }
        }

        if (token != null) {
          // Sauvegarder le token dans Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .where('UserId', isEqualTo: userId!.uid)
              .get()
              .then((QuerySnapshot snapshot) {
            if (snapshot.docs.isNotEmpty) {
              // Mettre à jour le document utilisateur avec le token FCM
              snapshot.docs.first.reference.update({
                'fcmToken': token,
                'lastTokenUpdate': FieldValue.serverTimestamp(),
              });
              print('Token FCM sauvegardé pour l\'utilisateur: ${userId!.uid}');
              print('Token: $token');
            }
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde du token FCM: $e');
    }
  }

  int _selectedIndex = 0;
  int _selectedIndexLog = 0;
  int _selectedIndexAdmin = 0;
  bool isAdminVisible = false;

  final List<Widget> _pagesLog = [
    Container(
      color: Colors.yellow.shade100,
      alignment: Alignment.center,
      child: LogController(),
    ),
    Container(
      color: Colors.yellow.shade100,
      alignment: Alignment.center,
      child: SignUpPage(),
    ),
    Container(
      color: Colors.pink.shade100,
      alignment: Alignment.center,
      child: TerreEnVie(),
    ),
  ];
  final List<Widget> _pagesAdmin = [
    Container(
      color: Colors.yellow.shade100,
      alignment: Alignment.center,
      child: DashboardPage(),
    ),
    Container(
      color: Colors.purple.shade100,
      alignment: Alignment.center,
      child: ComptePage(),
    ),
    // Container(
    //     color: Colors.red.shade100,
    //     alignment: Alignment.center,
    //     child: ContactPage()),
    Container(
      color: Colors.pink.shade100,
      alignment: Alignment.center,
      child: AdminPage(),
    ),
    Container(
      color: Colors.pink.shade100,
      alignment: Alignment.center,
      child: Analyse(),
    ),
    Container(
      color: Colors.pink.shade100,
      alignment: Alignment.center,
      child: TerreEnVie(),
    ),
    Container(
        color: Colors.orange.shade100,
        alignment: Alignment.center,
        child: LogOutController()),
    Container(
      color: Colors.blue.shade100,
      alignment: Alignment.center,
      child: NotificationsPage(),
    ),
    Container(
      color: Colors.green.shade100,
      alignment: Alignment.center,
      child: AdminNotificationsPage(),
    ),
  ];
  final List<Widget> _pages = [
    Container(
      color: Colors.yellow.shade100,
      alignment: Alignment.center,
      child: DashboardPage(),
    ),
    Container(
      color: Colors.purple.shade100,
      alignment: Alignment.center,
      child: ComptePage(),
    ),
    // Container(
    //   color: Colors.red.shade100,
    //   alignment: Alignment.center,
    //   child: ContactPage(),
    // ),
    Container(
      color: Colors.blue.shade100,
      alignment: Alignment.center,
      child: TerreEnVie(),
    ),
    Container(
        color: Colors.orange.shade100,
        alignment: Alignment.center,
        child: LogOutController())
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: MediaQuery.of(context).size.width < 640
            ? (userId != null
                ? (isAdminVisible
                    ? BottomNavigationBar(
                        currentIndex: _selectedIndexAdmin,
                        unselectedItemColor: Colors.grey,
                        selectedItemColor: Colors.indigoAccent,
                        onTap: (int index) {
                          setState(() {
                            _selectedIndexAdmin = index;
                          });
                        },
                        items: [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home), label: 'Mes créneaux'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.calendar_today),
                              label: 'Choisir mes postes'),
                          // BottomNavigationBarItem(
                          //     icon: Icon(Icons.contact_mail), label: 'Contact'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.admin_panel_settings),
                              label: 'Admin'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.auto_graph), label: 'Analyse'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.web), label: 'Terre En Vie'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.exit_to_app),
                              label: 'Deconnexion'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.notifications),
                              label: 'Notifications'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.send),
                              label: 'Envoyer Notifications'),
                        ],
                      )
                    : BottomNavigationBar(
                        currentIndex: _selectedIndex,
                        unselectedItemColor: Colors.grey,
                        selectedItemColor: Colors.indigoAccent,
                        onTap: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        items: [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home), label: 'Mes créneaux'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.calendar_today),
                              label: 'Choisir mes postes'),
                          // BottomNavigationBarItem(
                          //     icon: Icon(Icons.contact_mail), label: 'Contact'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.web),
                              label:
                                  'Terre En Vie'), // Afficher uniquement si isAdminVisible est vrai
                          BottomNavigationBarItem(
                              icon: Icon(Icons.exit_to_app),
                              label: 'Deconnexion'),
                        ],
                      ))
                : BottomNavigationBar(
                    currentIndex: _selectedIndexLog,
                    unselectedItemColor: Colors.grey,
                    selectedItemColor: Colors.indigoAccent,
                    onTap: (int index) {
                      setState(() {
                        _selectedIndexLog = index;
                      });
                    },
                    items: const [
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.login), label: 'Se connecter'),
                      BottomNavigationBarItem(
                          icon: const Icon(Icons.add), label: "S'inscrire"),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.web), label: 'Terre En Vie'),
                    ],
                  ))
            : null,
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 640)
              userId != null
                  ? (isAdminVisible
                      ? NavigationRail(
                          onDestinationSelected: (int index) {
                            setState(() {
                              _selectedIndexAdmin = index;
                            });
                          },
                          labelType: NavigationRailLabelType.all,
                          selectedIndex: _selectedIndexAdmin,
                          destinations: [
                            NavigationRailDestination(
                                icon: Icon(Icons.home),
                                label: Text('Mes créneaux')),
                            NavigationRailDestination(
                                icon: Icon(Icons.calendar_today),
                                label: Text('Choisir mes postes')),
                            // NavigationRailDestination(
                            //     icon: Icon(Icons.contact_mail),
                            //     label: Text('Contact')),
                            NavigationRailDestination(
                                icon: Icon(Icons.admin_panel_settings),
                                label: Text('Admin')),
                            NavigationRailDestination(
                                icon: Icon(Icons.auto_graph),
                                label: Text('Analyses')),
                            NavigationRailDestination(
                                icon: Icon(Icons.web),
                                label: Text('Terre En Vie')),
                            NavigationRailDestination(
                                icon: Icon(Icons.exit_to_app),
                                label: Text('Deconnexion')),
                            NavigationRailDestination(
                                icon: Icon(Icons.notifications),
                                label: Text('Notifications')),
                            NavigationRailDestination(
                                icon: Icon(Icons.send),
                                label: Text('Envoyer Notifications')),
                          ],
                        )
                      : NavigationRail(
                          onDestinationSelected: (int index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          labelType: NavigationRailLabelType.all,
                          selectedIndex: _selectedIndex,
                          destinations: [
                            NavigationRailDestination(
                                icon: Icon(Icons.home),
                                label: Text('Mes créneaux')),
                            NavigationRailDestination(
                                icon: Icon(Icons.calendar_today),
                                label: Text('Choisir mes postes')),
                            // NavigationRailDestination(
                            //     icon: Icon(Icons.contact_mail),
                            //     label: Text('Contact')),
                            NavigationRailDestination(
                                icon: Icon(Icons.web),
                                label: Text('Terre En Vie')),
                            NavigationRailDestination(
                                icon: Icon(Icons.exit_to_app),
                                label: Text('Deconnexion')),
                          ],
                        ))
                  : NavigationRail(
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndexLog = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: _selectedIndexLog,
                      destinations: const [
                        NavigationRailDestination(
                            icon: Icon(Icons.login),
                            label: Text('Se connecter')),
                        NavigationRailDestination(
                            icon: Icon(Icons.add), label: Text("S'inscrire")),
                        NavigationRailDestination(
                            icon: Icon(Icons.web), label: Text('Terre En Vie')),
                      ],
                    ),
            Expanded(
                child: userId != null
                    ? (isAdminVisible
                        ? _pagesAdmin[_selectedIndexAdmin]
                        : _pages[_selectedIndex])
                    : _pagesLog[_selectedIndexLog]),
          ],
        ));
  }

  void _checkUserAdminStatus() {
    FirebaseFirestore.instance
        .collection("users")
        .where('UserId', isEqualTo: userId!.uid)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        final profil = data['profil'];
        setState(() {
          isAdminVisible = (profil == 'admin');
        });
        // Mettre à jour le token FCM après avoir vérifié le statut admin
        _updateFcmTokenForUser(snapshot.docs.first.reference);
      } else {
        setState(() {
          isAdminVisible = false;
        });
      }
    }).catchError((error) {
      // Gestion des erreurs
    });
  }

  // Méthode pour mettre à jour le token FCM pour un utilisateur spécifique
  Future<void> _updateFcmTokenForUser(DocumentReference userRef) async {
    try {
      String? token;

      if (kIsWeb) {
        // Sur le web, on simule un token FCM
        token = 'WEB_TOKEN_${DateTime.now().millisecondsSinceEpoch}';
        print('Token FCM simulé pour le web: $token');
      } else {
        // Sur mobile, on demande les permissions et on récupère le vrai token
        NotificationSettings settings =
            await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          // Obtenir le token FCM
          token = await FirebaseMessaging.instance.getToken();
          print('Token FCM mobile: $token');
        } else {
          print('Notifications non autorisées par l\'utilisateur');
          return;
        }
      }

      if (token != null) {
        // Mettre à jour le document utilisateur avec le token FCM
        await userRef.update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('Token FCM mis à jour pour l\'utilisateur: ${userId!.uid}');
        print('Token: $token');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du token FCM: $e');
    }
  }
}
