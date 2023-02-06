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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                                        .collection("pos_hor")
                                        .where("jour", isEqualTo: "5")
                                        .where("ben_id", isEqualTo: userId!.uid)
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
                                        return Center(
                                          child: GridView.builder(
                                            controller: ScrollController(),
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (ctx, i) {
                                              var poste = snapshot.data!.docs[i]
                                                  ['poste'];
                                              var desc = snapshot.data!.docs[i]
                                                  ['desc'];
                                              var hor = snapshot.data!.docs[i]
                                                  ['debut'];

                                              return Card(
                                                color: Color(0xFFf2f0e7),
                                                child: Container(
                                                  height: 290,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  margin: EdgeInsets.all(5),
                                                  padding: EdgeInsets.all(5),
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              poste,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          // Text(poste),
                                                          Row(
                                                            children: [
                                                              Flexible(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      desc,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      hor,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1.0,
                                              crossAxisSpacing: 0.0,
                                              mainAxisSpacing: 5,
                                              mainAxisExtent: 264,
                                            ),
                                          ),
                                        );
                                      }

                                      return Container();
                                    },
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Get.to(() => Create());
                          },
                          child: Text(
                            "Je choisi un nouveau créneau",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(43, 90, 114, 1)),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(242, 240, 231, 1),
                          ),
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
                    child: AdminPage(),
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
