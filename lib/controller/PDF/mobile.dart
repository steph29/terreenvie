// import 'package:syncfusion_flutter_pdf/src/pdf/implementation/pdf_document/pdf_document.dart';
import 'dart:io';
import 'custom_pdf.dart';

CustomPdf getInstance() => CustomMobilePdf();

class CustomMobilePdf implements CustomPdf {
  // @override
  // ignore: non_constant_identifier_names
  // Future<void> pdf(PdfDocument document) async {
  //   File('Bénévole_pdf_mobile.pdf').writeAsBytesSync(await document.save());
  //   throw UnimplementedError();
  // }
}
