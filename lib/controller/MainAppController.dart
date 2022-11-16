import 'dart:developer';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainAppController extends StatelessWidget {
  const MainAppController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 8,
            child: Container(
              child: Text("Choississez vos créneaux !"),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width / 3,
              child: RightColumn(),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width / 3,
              child: RightColumn(),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width / 3,
              child: RightColumn(),
            ),
          ],
        ),
      ],
    )));
  }

  Widget RightColumn() {
    return Card(
      elevation: 8,
      child: Container(
        child: Column(
          children: [
            Text("Bonjour Stéphane"),
            Text(
                "tu es connecté(e) avec l'adresse email : s.verardo29@gmail.com"),
            Spacer(),
            Text(
                "Tu peux retrouver un récapitulatif de tes créneaux sélectionnés et de les modifier sur la page :"),
            TextButton(
              onPressed: () => {},
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.focused)) return Colors.red;
                  return null; // Defer to the widget's default.
                }),
              ),
              child: Text("Mon Compte"),
            ),
          ],
        ),
      ),
    );
  }

  Widget CenterColumn() {
    return Card();
  }

  Widget LeftColumn() {
    return Card();
  }
}
