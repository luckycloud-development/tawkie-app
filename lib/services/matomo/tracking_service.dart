import 'package:flutter/foundation.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

class TrackingService extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();

  void startStopwatch() {
    _stopwatch.start();
    if (kDebugMode) {
      print("Stopwatch started: ${_stopwatch.elapsedMilliseconds} ms");
    }
  }

  void stopAndTrackEvent(String eventName) {
    _stopwatch.stop();
    final elapsedTime = _stopwatch.elapsedMilliseconds;

    if (kDebugMode) {
      print("Stopwatch stopped: $elapsedTime ms");
    }

    _stopwatch.reset();
    notifyListeners();
  }

  Future<void> trackConnectionTimes() async {
    final elapsedTime = _stopwatch.elapsedMilliseconds;
    if (kDebugMode) {
      print('Elapsed Time: $elapsedTime ms');
    }

    MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        category: 'bridge',
        action: 'connection',
        name: 'Average Connection Time',
        value: elapsedTime.toDouble(),
      ),
    );
  }

  void trackAuthError(String authType, String errorType) {
    MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        category: 'auth',
        action: authType,
        name: errorType,
      ),
    );
    if (kDebugMode) {
      print('Auth error tracked: $authType - $errorType');
    }
  }
}
