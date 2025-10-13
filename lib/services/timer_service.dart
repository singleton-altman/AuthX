import 'dart:async';

class TimerService {
  final StreamController<int> _streamController = StreamController.broadcast();
  Timer? _timer;
  
  Stream<int> get secondsStream => _streamController.stream;
  
  void startTimer() {
    if (_timer != null) return;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _streamController.add(DateTime.now().second);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopTimer();
    _streamController.close();
  }
}