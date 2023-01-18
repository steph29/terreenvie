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
import 'package:terreenvie/model/create.dart';
import 'AdminPage.dart';
import 'ContactPage.dart';
import 'comptePage.dart';
import 'Logcontroller.dart';
import 'package:url_launcher/url_launcher.dart';

class MainAppController extends StatelessWidget {
  MainAppController({Key? key}) : super(key: key);
  PageController page = PageController();
  User? userId = FirebaseAuth.instance.currentUser;
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
          FirebaseAuth.instance.signOut();
          Get.to(() => LogController());
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
            controller: page,
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
                              padding: EdgeInsets.all(20.0),
                              child: Text("Choississez vos créneaux !"),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  padding: EdgeInsets.all(20.0),
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("pos_ben")
                                        .where("ben_id", isEqualTo: userId?.uid)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text("Something went wrong");
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child:
                                                CupertinoActivityIndicator());
                                      }
                                      if (snapshot.data!.docs.isEmpty) {
                                        return Center(
                                            child: Text("No data found"));
                                      }
                                      if (snapshot != null &&
                                          snapshot.data != null) {
                                        return ListView.builder(
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: ((context, index) {
                                              var poste = snapshot.data!
                                                  .docs[index]['pos_hor_id'];
                                              var desc = snapshot
                                                  .data!.docs[index]['ben_id'];
                                              return Card(
                                                child: ListTile(
                                                  title: Text(poste),
                                                  subtitle: Text(desc),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.delete)
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }));
                                      }

                                      return Container();
                                    },
                                  ),
                                )),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => Create());
        },
        child: Text(
          "Je choisi",
          textAlign: TextAlign.center,
        ),
        elevation: 8,
        hoverElevation: 15,
      ),
    );
  }

  Widget RightColumn() {
    return DashboardPage();
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
