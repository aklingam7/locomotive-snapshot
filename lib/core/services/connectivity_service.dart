import "dart:io";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

abstract class ConnectivityService {
  Future<bool> get networkAccessible;
}

class ConnectivityServiceImpl extends ConnectivityService {
  ConnectivityServiceImpl({Connectivity? connectivity}) {
    this.connectivity = connectivity ?? Connectivity();
  }

  late final Connectivity connectivity;

  @override
  Future<bool> get networkAccessible async {
    final result =
        (await connectivity.checkConnectivity()) != ConnectivityResult.none;
    if (!kIsWeb && Platform.isMacOS && result == false) {
      const TEST_URL = "https://google.com";
      try {
        await http.get(Uri.parse(TEST_URL));
        return true;
      } on SocketException {
        return false;
      } catch (_) {
        return true;
      }
    }
    return result;
  }
}
