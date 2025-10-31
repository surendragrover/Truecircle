import 'dart:async';

// A simple global event bus for decoupling features.

class EventBus {
  EventBus._privateConstructor();
  static final EventBus instance = EventBus._privateConstructor();

  final StreamController _controller = StreamController.broadcast();

  Stream<T> on<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void fire(dynamic event) {
    _controller.add(event);
  }

  void destroy() {
    _controller.close();
  }
}

// --- Event Classes ---

class CoinRewardedEvent {
  final int amount;
  const CoinRewardedEvent(this.amount);
}
