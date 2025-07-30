// import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'pdf_helper.dart'
    if (dart.library.io) 'mobile.dart'
    if (dart.library.html) 'web.dart';

abstract class CustomPdf {
  // Future<void> pdf(PdfDocument document);
}
