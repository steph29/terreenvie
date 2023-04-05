import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Poste {
  String poste;
  String desc;
  List hor;
  String ben_id;
  String poste_id;
  DateTime createAt;

  Poste(this.poste, this.desc, this.hor, this.ben_id, this.poste_id,
      this.createAt);

// formatting for upload to Firbase when creating the poste
  Map<String, dynamic> toJSON() => {
        'poste': poste,
        'desc': desc,
        'hor': hor,
        'ben_id': ben_id,
        'createAt': createAt
      };

// creating a Poste object from a firebase snapshot
  // Poste.fromSnapshot(DocumentSnapshot snapshot)
  //     : poste = snapshot.data()['poste'],
  //       desc = snapshot.data()['desc'],
  //       hor = snapshot.data()['hor'],
  //       ben_id = snapshot.data()['ben_id'],
  //       poste_id = snapshot.id,
  //       createAt = snapshot.data()['createdAt'].toDate();

  Map<String, dynamic> horItems(String debut, String fin, String nbBen) {
    return {
      'hor': FieldValue.arrayUnion([
        {
          "debut": debut,
          "fin": fin,
          "nbBen": nbBen,
        }
      ])
    };
  }

  // Map<String, dynamic> ledgerItem(String amount, String type) {
  //   var amountDouble = double.parse(amount);
  //   if (type == "spent") {
  //     amountDouble = double.parse("-" + amount);
  //   }
  //   return {
  //     'ledger': FieldValue.arrayUnion([
  //       {
  //         "date": DateTime.now(),
  //         "amount": amountDouble,
  //       },
  //     ]),
  //     'saved': FieldValue.increment(amountDouble)
  //   };
  // }
}
