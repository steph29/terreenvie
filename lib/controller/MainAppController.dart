import 'dart:developer';
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:get/get.dart';
import 'package:terreenvie/controller/DashboardPage.dart';
import 'package:terreenvie/main.dart';
import 'package:terreenvie/model/create.dart';
import 'AdminPage.dart';
import 'ContactPage.dart';
import 'LogOutController.dart';
import 'Logcontroller.dart';
import 'SignUpPage.dart';
import 'comptePage.dart';

import 'package:url_launcher/url_launcher.dart';

class MainAppController extends StatefulWidget {
  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  User? userId; //= FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser;
  }

  int _selectedIndex = 0;
  int _selectedIndexLog = 0;

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
      color: Colors.yellow.shade100,
      alignment: Alignment.center,
      child: ContactPage(),
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
    Container(
      color: Colors.red.shade100,
      alignment: Alignment.center,
      child: ContactPage(),
    ),
    Container(
      color: Colors.pink.shade100,
      alignment: Alignment.center,
      child: AdminPage(),
    ),
    Container(
        color: Colors.orange.shade100,
        alignment: Alignment.center,
        child: LogOutController())
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: MediaQuery.of(context).size.width < 640
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.indigoAccent,
                onTap: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: (userId == null)
                    ? const [
                        BottomNavigationBarItem(
                            icon: const Icon(Icons.login),
                            label: 'Se connecter')
                      ]
                    : const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home), label: 'Tableau de bord'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.calendar_today),
                            label: 'Choisir ses postes'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.contact_mail), label: 'Contact'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.admin_panel_settings),
                            label: 'Admin'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.exit_to_app),
                            label: 'Deconnexion'),
                      ],
              )
            : null,
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 640)
              userId != null
                  ? NavigationRail(
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: _selectedIndex,
                      destinations: const [
                        NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Tableau de bord')),
                        NavigationRailDestination(
                            icon: Icon(Icons.calendar_today),
                            label: Text('Choisir ses postes')),
                        NavigationRailDestination(
                            icon: Icon(Icons.contact_mail),
                            label: Text('Contact')),
                        NavigationRailDestination(
                            icon: Icon(Icons.admin_panel_settings),
                            label: Text('Admin')),
                        NavigationRailDestination(
                            icon: Icon(Icons.exit_to_app),
                            label: Text('Deconnexion')),
                      ],
                    )
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
                            icon: Icon(Icons.schedule),
                            label: Text('Programmation')),
                      ],
                    ),
            Expanded(
                child: userId != null
                    ? _pages[_selectedIndex]
                    : _pagesLog[_selectedIndexLog]),
          ],
        ));
  }

  _launchURL() async {
    const url = 'https://www.terreenvie.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
