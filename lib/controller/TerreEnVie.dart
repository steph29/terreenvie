import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

const String url = 'https://www.terreenvie.com/';

class TerreEnVie extends StatelessWidget {
  const TerreEnVie({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Direction: La programmation !")),
      body: Center(
        child: ElevatedButton(
            onPressed: _launchURL,
            child: Text("Terre En Vie, C'est par ici !")),
      ),
    );
  }

  void _launchURL() async {
    if (!await launch(url)) throw 'Could not launch $url';
  }
}
