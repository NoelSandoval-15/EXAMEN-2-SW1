import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiClient {
  const ApiClient();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    return Platform.isAndroid ? 'http://10.0.2.2:8080/api' : 'http://localhost:8080/api';
  }
}
