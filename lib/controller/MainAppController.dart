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
import 'Logcontroller.dart';
import 'comptePage.dart';

import 'package:url_launcher/url_launcher.dart';

class MainAppController extends StatefulWidget {
  // MainAppController({Key? key}) : super(key: key);

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  PageController page = PageController();
  SideMenuController sideMenu = SideMenuController();
  User? userId = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LogController(),
    AdminPage(),
    DashboardPage(),
    ContactPage(),
    ComptePage(),
  ];

  @override
  void initState() {
    sideMenu.addListener((p0) {
      page.jumpToPage(p0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Le coin du Bénévoles"),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              hoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
            ),
            footer: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Terre en Vie',
                style: TextStyle(fontSize: 15),
              ),
            ),
            items: [
              SideMenuItem(
                priority: 0,
                title: 'Tableau de bord',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                  // Get.offNamed('/home');
                },
                icon: const Icon(Icons.home),
              ),
              SideMenuItem(
                priority: 1,
                title: 'Compte',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                  // Get.offNamed('/compte');
                },
                icon: const Icon(Icons.supervisor_account),
              ),
              SideMenuItem(
                priority: 2,
                title: 'Contact',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                  // Get.offNamed('/contact');
                },
                icon: const Icon(Icons.contact_page),
              ),
              SideMenuItem(
                priority: 3,
                title: 'Admin',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                  // Get.offNamed('/admin');
                },
                icon: const Icon(Icons.admin_panel_settings),
              ),
              SideMenuItem(
                priority: 4,
                title: 'La prog de Terre En Vie',
                onTap: (page, _) {
                  _launchURL();
                },
                icon: const Icon(Icons.calendar_month_outlined),
              ),
              SideMenuItem(
                priority: 5,
                title: 'Deconnexion',
                icon: Icon(Icons.exit_to_app),
                onTap: (page, _) {
                  FirebaseAuth.instance.signOut();
                  Get.offAll(LogController());
                  // Get.offAllNamed('/login');
                },
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: page,
              children: [
                Container(
                  color: Colors.white,
                  child: DashboardPage(),
                ),
                Container(
                  color: Colors.white,
                  child: const ComptePage(),
                ),
                Container(
                  color: Colors.white,
                  child: const ContactPage(),
                ),
                Container(
                  color: Colors.white,
                  child: AdminPage(),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'terre en vie',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: LogController(),
                ),
              ],
            ),
          ),
          // BottomNavigationBar(
          //   currentIndex: _selectedIndex,
          //   onTap: (index) {
          //     setState(() {
          //       _selectedIndex = index;
          //     });
          //   },
          //   items: const <BottomNavigationBarItem>[
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.home),
          //       label: 'Page 1',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.business),
          //       label: 'Page 2',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.school),
          //       label: 'Page 3',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.contact_mail),
          //       label: 'Page 4',
          //     ),
          //   ],
          // ),
          // Expanded(
          //   child: Navigator(
          //     key: Get.nestedKey(1),
          //     initialRoute: '/',
          //     onGenerateRoute: (settings) {
          //       WidgetBuilder builder;
          //       switch (settings.name) {
          //         case '/':
          //           builder = (_) => DashboardPage();
          //           break;
          //         case '/compte':
          //           builder = (_) => ComptePage();
          //           break;
          //         case '/admin':
          //           builder = (_) => AdminPage();
          //           break;
          //         default:
          //           throw Exception('Route inconnue: ${settings.name}');
          //       }
          //       return MaterialPageRoute(builder: builder, settings: settings);
          //     },
          //   ),
          // ),
        ],
      ),
    );
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


// class MainAppController extends StatefulWidget {
//   const MainAppController({Key? key}) : super(key: key);

//   @override
//   _MainAppControllerState createState() => _MainAppControllerState();
// }

// class _MainAppControllerState extends State<MainAppController> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     DashboardPage(),
//     AdminPage(),
//     ContactPage(),
//     ComptePage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Le coin du Bénévoles'),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               child: Text('Menu'),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//             ),
//             ListTile(
//               title: Text('Tableau de Bord'),
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 0; // Modifier l'index en conséquence
//                 });
//                 Navigator.pop(context);
//                 // Get.offAllNamed('/DashboardPage');
//               },
//             ),
//             ListTile(
//               title: Text('Admin'),
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 1; // Modifier l'index en conséquence
//                 });
//                 // Get.offAllNamed('/AdminPage');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: Text('Contact'),
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 2; // Modifier l'index en conséquence
//                 });
//                 // Get.offAllNamed('/ContactPage');
//                 Navigator.pop(context);
//               },
//             ),
//             // ListTile(
//             //   title: Text('Choisir ses postes de bénévolats'),
//             //   onTap: () {
//             //     Get.offAllNamed('/ComptePage');
//             //   },
//             // ),
//           ],
//         ),
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Tableau de Bord',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.business),
//             label: 'Admin',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.school),
//             label: 'Contact',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.contact_mail),
//             label: 'Page 4',
//           ),
//         ],
//       ),
//     );
//   }
// }
