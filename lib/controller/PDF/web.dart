import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:terreenvie/controller/PDF/custom_pdf.dart';

CustomPdf getInstance() => CustomWebPdf();

class CustomWebPdf implements CustomPdf {
  // Future<void> pdf(PdfDocument document) async {
  //   List<int> bytes = await document.save();
  //   html.AnchorElement anchorElement = html.AnchorElement(href: html.Url.createObjectUrlFromBlob(html.Blob([bytes])));
  //   anchorElement.download = "Bénévoles_kikeou.pdf";
  //   anchorElement.click();
  // }
}
