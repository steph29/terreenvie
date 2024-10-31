import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:terreenvie/controller/PDF/custom_pdf.dart';

CustomPdf getInstance() => CustomWebPdf();

class CustomWebPdf implements CustomPdf {
  @override
  Future<void> pdf(PdfDocument document) async {
    List<int> bytes = await document.save();
    //Dispose the document
    document.dispose();
    //Download the output file
    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "Bénévole_de_TEV_web.pdf")
      ..click();
    throw UnimplementedError();
  }
}
