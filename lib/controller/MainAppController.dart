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
import 'dart:async'; // Added for Timer

class MainAppController extends StatefulWidget {
  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController>
    with TickerProviderStateMixin {
  User? userId; //= FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser les animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Démarrer les animations
    _logoController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);

    userId = FirebaseAuth.instance.currentUser;
    if (userId != null) {
      _checkUserAdminStatus();
      _saveFcmTokenForCurrentUser(); // Sauvegarder le token FCM
    } else {
      setState(() {
        isAdminVisible = false;
      });
    }

    // Simuler un temps de chargement pour l'animation
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
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
    // Afficher l'animation de chargement si _isLoading est true
    if (_isLoading) {
      return Scaffold(
        backgroundColor:
            const Color(0xFFf2f0e7), // Couleur de fond beige/ivoire
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animé
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF4CAF50), // Vert pour le logo
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco,
                              size: 60,
                              color:
                                  Colors.white, // Icône blanche sur fond vert
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Titre animé
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'Chargement...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50), // Vert pour le titre
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Sous-titre animé
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'Préparation de votre espace',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Color(0xFF666666), // Gris foncé pour le sous-titre
                        letterSpacing: 1.0,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // Indicateur de chargement moderne
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF4CAF50)
                            .withOpacity(_pulseAnimation.value * 0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // Retourner l'interface normale une fois le chargement terminé
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
