import 'dart:html';
import 'dart:convert';

Future<void> saveAndLaunchFile(List<int> bytes, String name) async {
  AnchorElement(
      href:
          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
    ..setAttribute("download", "output.pdf")
    ..click();
}
