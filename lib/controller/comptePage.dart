import 'package:flutter/material.dart';

class ComptePage extends StatelessWidget {
  const ComptePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text(
          'Compte Page',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
