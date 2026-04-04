import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map(
      (results) =>
          results.isNotEmpty && !results.contains(ConnectivityResult.none),
    );
  }

  static Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
