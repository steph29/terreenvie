import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environnement {
  static String get fileName {
    //TODO change before delivery in production
    if (kDebugMode) {
      return '.env.production';
    }
    return '.env.developpement';
  }

  static String get apiKey {
    return dotenv.env['APIKEY'] ?? 'APIKEY not found';
  }

  static String get appId {
    return dotenv.env['APPID'] ?? 'APPID not found';
  }

  static String get messagingSenderId {
    return dotenv.env['MESSAGINGSENDERID'] ?? 'MESSAGINGSENDERID not found';
  }

  static String get projectId {
    return dotenv.env['PROJECTID'] ?? 'PROJECTID not found';
  }
}
