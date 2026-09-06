import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Listen for connection changes
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  // Check the current connection
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();

    return result.any(
      (connection) =>
          connection == ConnectivityResult.wifi ||
          connection == ConnectivityResult.mobile ||
          connection == ConnectivityResult.ethernet,
    );
  }
}