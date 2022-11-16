import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:terreenvie/model/FirebaseHelper.dart';

class LogController extends StatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  State<LogController> createState() => _LogControllerState();
}

class _LogControllerState extends State<LogController> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _log = true;
  String _adresseMail = "";
  String _motDePasse = "";
  String _prenom = "";
  String _name = "";
  String _tel = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Authentification")),
      body: AuthLog(_prenom, _adresseMail, _motDePasse),
    );
  }

  Widget AuthLog(String prenom, String email, String password) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40,
            height: MediaQuery.of(context).size.height / 2,
            child: Card(
              elevation: 7.5,
              child: Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: textfields(),
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                _log = !_log;
              });
            },
            child: Text((_log) ? "Authentification" : "Création d'un compte"),
          ),
          RaisedButton(
            onPressed: _handleLog(),
            child: Text("C'est parti"),
          )
        ],
      )),
    );
  }

  _handleLog() {
    if (_prenom != null) {
      if (_adresseMail != null) {
        if (_motDePasse != null) {
          if (_log) {
            // Connexion
            FirebaseHelper()
                .handleSignIn(_adresseMail, _motDePasse)
                .then((user) {
              print(user.uid);
            }).catchError((error) {
              alerte(error.toString());
            });
          } else {
            // Inscription
            if (_name != null) {
              if (_tel != null) {
                // Méthode pour creer l'utilisateur
                FirebaseHelper()
                    .create(_adresseMail, _motDePasse, _prenom, _name)
                    .then((user) {
                  print(user.uid);
                }).catchError((error) {
                  print(error.toString());
                });
              } else {
                // pas de tel;
                alerte("Aucun tel n'a été renseigné");
              }
            } else {
              // pas de nom
              alerte("Aucun nom n'a été renseigné");
            }
          }
        } else {
          // Alerte pas de mdp
          alerte("Aucun mdp n'a été renseigné");
        }
      } else {
        // Alerte pas de mail
        alerte("Aucun mail n'a été renseigné");
      }
    } else {
      // pas de prenom
      alerte("Aucun prénom n'a été renseigné");
    }
  }

  List<Widget> textfields() {
    List<Widget> widgets = [];
    widgets.add(
      TextFieldLogin(prenomController, "Votre prénom", _prenom, false),
    );
    widgets.add(
      TextFieldLogin(emailController, "votre email", _adresseMail, false),
    );
    widgets.add(
      TextFieldLogin(
          passwordController, "Votre mot de passe", _motDePasse, true),
    );
    if (!_log) {
      widgets.add(TextFieldLogin(nameController, "Votre nom", _name, false));
      widgets
          .add(TextFieldLogin(telController, "Votre téléphone", _tel, false));
    }
    return widgets;
  }

  Widget TextFieldLogin(TextEditingController controller, String labelText,
      String _string, bool obscure) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: obscure,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
        ),
        onChanged: (string) {
          setState(() {
            _string = string;
          });
        },
      ),
    );
  }

  Future<void> alerte(String message) async {
    Text title = Text("Erreur");
    Text msg = Text(message);
    FloatingActionButton okButton = FloatingActionButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text("ok"),
    );
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: title,
            content: msg,
            actions: <Widget>[okButton],
          );
        });
  }
}
