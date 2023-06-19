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
import 'comptePage.dart';
import 'Logcontroller.dart';
import 'package:url_launcher/url_launcher.dart';

class MainAppController extends StatefulWidget {
  MainAppController({Key? key}) : super(key: key);

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  PageController page = PageController();
  SideMenuController sideMenu = SideMenuController();
  User? userId = FirebaseAuth.instance.currentUser;

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
                title: 'Dashboard',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                },
                icon: const Icon(Icons.home),
                badgeContent: const Text(
                  '3',
                  // Conserver le badge pour informer le nombre de poste
                  style: TextStyle(color: Colors.white),
                ),
                tooltipContent: "This is a tooltip for Dashboard item",
              ),
              SideMenuItem(
                priority: 1,
                title: 'Compte',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                },
                icon: const Icon(Icons.supervisor_account),
              ),
              SideMenuItem(
                priority: 2,
                title: 'Contact',
                onTap: (page, _) {
                  sideMenu.changePage(page);
                },
                icon: const Icon(Icons.contact_page),
                // trailing: Container(
                //     decoration: const BoxDecoration(
                //         color: Colors.amber,
                //         borderRadius: BorderRadius.all(Radius.circular(6))),
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 6.0, vertical: 3),
                //       child: Text(
                //         'New',
                //         style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                //       ),
                //     )),
              ),
              SideMenuItem(
                priority: 3,
                title: 'Admin',
                onTap: (page, _) {
                  sideMenu.changePage(page);
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
