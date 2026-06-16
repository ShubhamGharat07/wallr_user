import 'package:connectivity_plus/connectivity_plus.dart';

/// WALLR — Network Info
///
/// Wraps [connectivity_plus] to check internet availability.
/// Repository implementations inject this via GetIt to guard remote calls.
///
/// Usage (inside repository):
///   if (!await _networkInfo.isConnected) throw NetworkException();

abstract interface class NetworkInfo {
  Future<bool> get isConnected;

  /// Stream of connectivity changes — use for real-time offline banner.
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  const NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => _hasConnection(results));

  // ConnectivityResult list me se ek bhi non-none ho to connected.
  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
