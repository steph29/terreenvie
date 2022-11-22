import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  // const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

bool _checked = false;
bool _checked2 = false;

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    //  const DashboardPage({Key? key}) : super(key: key);

    return Card(
        elevation: 8,
        child: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
              Row(
                children: [
                  poste(),
                  poste(),
                  poste(),
                ],
              ),
            ],
          )),
        ));
  }

  Widget poste() {
    return Expanded(
        flex: 1,
        child: Card(
          margin: EdgeInsets.all(8),
          elevation: 8,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Buvette Principale"),
                    // Image.asset("assets/logoTEV.png"),
                    Icon(Icons.wine_bar),
                  ],
                ),
                Text(
                  'Allez! Viens boire un p\'tit coup à la maison !',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
                ),
                CheckboxListTile(
                  title: const Text('1200h - 14h00'),
                  autofocus: false,
                  controlAffinity: ListTileControlAffinity.platform,
                  value: _checked,
                  onChanged: (bool? value) {
                    setState(() {
                      _checked = value!;
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ), //CheckboxListT
                CheckboxListTile(
                  title: const Text('1200h - 14h00'),
                  autofocus: false,
                  controlAffinity: ListTileControlAffinity.platform,
                  value: _checked2,
                  onChanged: (bool? value) {
                    setState(() {
                      _checked2 = value!;
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ), //CheckboxListT
              ]),
        ));
  }
}
