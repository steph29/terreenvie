import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controller/MainAppController.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'api/firebase_api.dart';

//final DotEnv rootEnv = DotEnv();
// Utilisé pour passer les messages de l'event handler à l'UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement avec gestion d'erreur
  try {
    // Pour Flutter Web, on utilise le chemin asset
    if (kIsWeb) {
      await dotenv.load(fileName: "assets/.env");
    } else {
      await dotenv.load(fileName: ".env");
    }
    print('✅ Variables d\'environnement chargées avec succès');

    // Vérifier que les variables importantes sont chargées
    final emailPassword = dotenv.env['EMAIL_PASSWORD'];
    if (emailPassword != null &&
        emailPassword != 'votre_mot_de_passe_d_application') {
      print('✅ EMAIL_PASSWORD configuré');
    } else {
      print('⚠️ EMAIL_PASSWORD non configuré ou valeur par défaut');
    }
  } catch (e) {
    print('⚠️ Erreur lors du chargement du fichier .env: $e');
    print('📝 Assurez-vous que le fichier .env existe à la racine du projet');
    print('📝 Copiez env.example vers .env si nécessaire');

    // En cas d'erreur, on peut continuer avec des valeurs par défaut
    print('🔄 Utilisation des valeurs par défaut pour l\'email');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialiser les notifications Firebase
  if (!kIsWeb) {
    await FirebaseApi().initNotifications();
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Ceci est appelé chaque fois qu'un message FCM est reçu
    // pendant que l'application est au premier plan.

    // Pour le débogage, vous pouvez imprimer les détails du message :
    // if (kDebugMode) { // Importez 'package:flutter/foundation.dart' pour kDebugMode
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification title: ${message.notification?.title}');
    print('Message notification body: ${message.notification?.body}');
    // }

    // Publiez le message vers notre contrôleur de flux pour que l'UI puisse le récupérer
    _messageStreamController.sink.add(message);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  String _lastMessage = "";
  bool _isLoading = true;
  // Ajoutez un Subscription pour pouvoir l'annuler proprement
  // lorsque le widget est détruit
  late StreamSubscription<RemoteMessage> _messageSubscription;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _messageSubscription = _messageStreamController.listen((message) {
      setState(() {
        if (message.notification != null) {
          // Si le message contient un titre et un corps de notification
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
        } else {
          // Si c'est seulement un message de données (sans notification visible)
          _lastMessage = 'Received a data message: ${message.data}';
        }
      });
    });

    // Simuler un temps de chargement plus long pour couvrir l'initialisation complète
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel(); // Annule l'abonnement
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: _isLoading ? const SplashScreen() : MainAppController(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFFf2f0e7)),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation du logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animation de pulsation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animation de fade
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

    // Animation de pulsation en boucle
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf2f0e7), // Couleur de fond beige/ivoire
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
                            color: const Color(0xFF4CAF50), // Vert pour le logo
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
                            color: Colors.white, // Icône blanche sur fond vert
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
                    'Terre en Vie',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50), // Vert pour le titre
                      letterSpacing: 2.0,
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
                    'Gestion des Bénévoles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666), // Gris foncé pour le sous-titre
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

            const SizedBox(height: 20),

            // Texte de chargement
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'Chargement...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(
                          0xFF666666), // Gris foncé pour le texte de chargement
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
