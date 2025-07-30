import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  // const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    //  const DashboardPage({Key? key}) : super(key: key);

    return Scaffold(
        appBar: AppBar(
          title: Text("Mes créneaux"),
          backgroundColor: Color(0xFFf2f0e7),
        ),
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    userId != null ? buildCardList() : Text('Pas de données'),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget buildCardList() => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("pos_ben")
            .where("ben_id", isEqualTo: userId!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Oups! une erreur est survenue");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
                    "Tu n'as pas encore de créneau sélectionné. Vas dans l'onglet Choisir mes postes "));
          }
          if (snapshot.data != null) {
            return Center(
              child: ListView.builder(
                controller: ScrollController(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var pos = snapshot.data!.docs[i]['pos_id'];
                  var posteId = snapshot.data?.docs[i].id;
                  return Center(
                    child: Container(
                      constraints:
                          const BoxConstraints(minHeight: 0, maxHeight: 200.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  buildList(pos, posteId, snapshot, i),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      );

  Widget buildList(poste, posteId, snapshot, i) => ListView.builder(
      shrinkWrap: true,
      itemCount: poste.length,
      itemBuilder: (context, j) {
        var affectation = snapshot.data?.docs[i]['pos_id'][j];
        var hord = affectation["debut"];
        var horf = affectation["fin"];
        var jour = affectation['jour'];
        var postes = affectation['poste'];
        var idPoste = affectation['posteId'];

        return Card(
          child: ListTile(
            title: Text(
              postes.toString() +
                  ' - ' +
                  jour.toString() +
                  ' - ' +
                  hord +
                  '-' +
                  horf,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF2b5a72)),
            ),
            trailing: IconButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFf2f0e7),
              ),
              icon: Icon(Icons.delete),
              onPressed: () async {
                // 1. Supprimer l'affectation dans pos_ben
                await FirebaseFirestore.instance
                    .collection("pos_ben")
                    .doc(posteId.toString())
                    .update({
                  'pos_id': FieldValue.arrayRemove([affectation])
                });

                // 2. Incrémenter nbBen dans pos_hor
                final doc = await FirebaseFirestore.instance
                    .collection('pos_hor')
                    .doc(idPoste.toString())
                    .get();
                if (doc.exists) {
                  List<dynamic> horList = List.from(doc.data()!['hor']);
                  for (var h in horList) {
                    if (h['debut'] == hord && h['fin'] == horf) {
                      h['nbBen'] = (h['nbBen'] ?? 0) + 1;
                      break;
                    }
                  }
                  await FirebaseFirestore.instance
                      .collection('pos_hor')
                      .doc(idPoste.toString())
                      .update({'hor': horList});
                }

                // 3. Si le tableau pos_id est vide, supprimer le document pos_ben
                final posBenDoc = await FirebaseFirestore.instance
                    .collection("pos_ben")
                    .doc(posteId.toString())
                    .get();
                if (posBenDoc.exists) {
                  final data = posBenDoc.data();
                  if (data != null &&
                      (data['pos_id'] == null ||
                          (data['pos_id'] as List).isEmpty)) {
                    await FirebaseFirestore.instance
                        .collection("pos_ben")
                        .doc(posteId.toString())
                        .delete();
                  }
                }
                setState(() {});
              },
            ),
          ),
        );
      });

  void updatePosHor(String posteId, String debut, String fin) {
    FirebaseFirestore.instance
        .collection('pos_hor')
        .doc(posteId)
        .get()
        .then((snapshot) {
      var horList = snapshot.data()!['hor'] as List<dynamic>;
      for (var hor in horList) {
        if (hor['debut'] == debut && hor['fin'] == fin) {
          hor['nbBen'] = hor['nbBen'] + 1;
          break;
        }
      }
      FirebaseFirestore.instance
          .collection('pos_hor')
          .doc(posteId)
          .update({'hor': horList});
    });
  }

  Widget UpdateBen(String idPoste, String posteId, String debut, String fin) =>
      StreamBuilder(
        //  On récupère les informations de posteId

        stream: FirebaseFirestore.instance.collection("pos_ben").where("pos_id",
            arrayContains: {"posteId": idPoste, "debut": debut}).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(FieldPath.documentId);

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data found"));
          }
          if (snapshot != null && snapshot.data != null) {
            // var doc = snapshot.data.docs.first;
            // var documentId = doc.id;
            // print("hello");
            List<String> postesIds =
                snapshot.data!.docs.map((doc) => doc.id).toList();
            // On met à jour les informations dans pos_hor
          }
          return Container();
        },
      );
}
