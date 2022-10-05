import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA3TfCMtvxlJRFt9ibeBmyjt46hX_VKiUY",
      appId: "1:1094407773095:web:4259b1ba7d80d1ee2df482",
      messagingSenderId: "1094407773095",
      projectId: "terre-en-vie-766c7",
    ),
  );

  static const String _title = 'Le coin des bénévoles';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(title: const Text(_title)),
                body: const MyStatefulWidget());
          }
          return CircularProgressIndicator();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Terre en Vie',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Connexion',
                  style: TextStyle(fontSize: 20),
                )),
            TextFieldLogin(nameController, 'Email'),
            TextFieldLogin(passwordController, 'Mot de passe'),
            TextButton(
              onPressed: () {
                //forgot password screen
              },
              child: const Text(
                'Mot de passe perdu? ',
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () {
                    print(nameController.text);
                    print(passwordController.text);
                  },
                )),
            Row(
              children: <Widget>[
                const Text('Pas encore inscrit'),
                TextButton(
                  child: const Text(
                    'C\'est par ici ! ',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    //signup screen
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ));
  }

  Widget TextFieldLogin(TextEditingController controller, String labelText) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: true,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
        ),
      ),
    );
  }
}
