import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

const String url = 'https://www.terreenvie.com/';

class TerreEnVie extends StatelessWidget {
  const TerreEnVie({key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Direction: La programmation !"),
        backgroundColor: Color(0xFF2b5a72),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: _launchURL,
            style: ElevatedButton.styleFrom(
              primary: Color(
                  0xFF2b5a72), // Définit la couleur de fond sur transparent
              elevation: 0, // Supprime l'ombre du bouton
            ),
            child: Text("Terre En Vie, C'est par ici !")),
      ),
    );
  }

  void _launchURL() async {
    if (!await launch(url)) throw 'Could not launch $url';
  }
}
