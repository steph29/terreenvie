import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> saveAndLaunchFile(List<int> bytes, String FileName) async {
  final path = (await getExternalStorageDirectory())!.path;
  final file = File('$path/$FileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$FileName');
}
