import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainAppController extends StatelessWidget {
  const MainAppController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Le coin du bénévoles"),
      ),
      body: Center(
        child: Text("Nous sommes connectés"),
      ),
    );
  }
}
