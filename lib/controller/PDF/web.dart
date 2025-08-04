import 'dart:convert';
import 'dart:async';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:terreenvie/controller/PDF/custom_pdf.dart';
import 'package:flutter/foundation.dart';

CustomPdf getInstance() => CustomWebPdf();

class CustomWebPdf implements CustomPdf {
  @override
  Future<void> pdf(PdfDocument document) async {
    if (kIsWeb) {
      // Code spécifique au web
      List<int> bytes = await document.save();
      document.dispose();
      // Sur le web, on peut utiliser dart:html
      // Mais pour Android, on va juste afficher un message
      print('PDF généré avec succès (${bytes.length} bytes)');
    } else {
      // Code pour Android
      List<int> bytes = await document.save();
      document.dispose();
      print('PDF généré avec succès (${bytes.length} bytes)');
      // Ici on pourrait implémenter le téléchargement pour Android
    }
  }
}
