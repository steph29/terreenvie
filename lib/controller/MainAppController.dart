import 'dart:developer';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'AdminPage.dart';
import 'ContactPage.dart';
import 'comptePage.dart';
import 'Logcontroller.dart';
import 'package:url_launcher/url_launcher.dart';

class MainAppController extends StatelessWidget {
  MainAppController({Key? key}) : super(key: key);
  PageController page = PageController();
  late final String title;
  @override
  Widget build(BuildContext context) {
    List<SideMenuItem> items = [
      SideMenuItem(
        priority: 0,
        title: 'Dashboard',
        onTap: () {
          page.jumpToPage(0);
        },
        icon: Icon(Icons.dashboard),
      ),
      SideMenuItem(
        priority: 1,
        title: 'Compte',
        onTap: () => page.jumpToPage(1),
        icon: Icon(Icons.settings),
      ),
      SideMenuItem(
        priority: 2,
        title: 'Contact',
        onTap: () => page.jumpToPage(2),
        icon: Icon(Icons.contact_page),
      ),
      SideMenuItem(
        priority: 3,
        title: 'Admin',
        onTap: () => page.jumpToPage(3),
        icon: Icon(Icons.admin_panel_settings),
      ),
      SideMenuItem(
        priority: 4,
        title: 'Deconnexion',
        onTap: () {
          page.jumpToPage(4);
        },
        icon: Icon(Icons.exit_to_app),
      ),
      SideMenuItem(
        priority: 5,
        title: 'La prog de Terre En Vie',
        onTap: () {
          _launchURL();
        },
        icon: Icon(Icons.calendar_month_outlined),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Le coin des bénévoles"),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            // Page controller to manage a PageView
            controller: page,
            // Will shows on top of all items, it can be a logo or a Title text
            // title: Image.asset('/assets/logoTEV.png'),
            // Will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
            // footer: Text('demo'),
            // Notify when display mode changed
            onDisplayModeChanged: (mode) {
              print(mode);
            },
            // List of SideMenuItem to show them on SideMenu
            items: items,
            collapseWidth: (MediaQuery.of(context).size.width / 4).toInt(),
          ),
          Expanded(
            child: PageView(
              controller: page,
              children: [
                Container(
                  child: Center(
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
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width / 4,
                              child: RightColumn(),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width / 4,
                              child: RightColumn(),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width / 4,
                              child: RightColumn(),
                            ),
                          ],
                        ),
                      ],
                    )),
                  ),
                ),
                Container(
                  child: Center(
                    child: const ComptePage(),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const ContactPage(),
                ),
                Container(
                  color: Colors.white,
                  child: Center(
                    child: const AdminPage(),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Center(
                    child: const LogController(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  _launchURL() async {
    const url = 'https://www.terreenvie.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
