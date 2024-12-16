import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline, restored }

class InternetConnectivity {
  static final StreamController<NetworkStatus> _networkController =
      StreamController<NetworkStatus>.broadcast();

  static Stream<NetworkStatus> get networkStream => _networkController.stream;

  static NetworkStatus _status = NetworkStatus.online;

  static NetworkStatus get status => _status;

  static Future<void> networkStatusService() async {
    Connectivity()
        .onConnectivityChanged
        .listen((final List<ConnectivityResult> statuses) async {
      final ConnectivityResult status = statuses.last;
      if (status != ConnectivityResult.none) {
        _networkController.add(NetworkStatus.restored);
        await Future<void>.delayed(const Duration(seconds: 5));
        if (status != ConnectivityResult.none) {
          _networkController.add(NetworkStatus.online);
        }
      } else {
        _networkController.add(NetworkStatus.offline);
      }
    });
    _networkController.stream.listen((final NetworkStatus event) {
      _status = event;
    });
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      _networkController.add(NetworkStatus.offline);
    }
  }

  void dispose() {
    unawaited(_networkController.close());
  }
}
