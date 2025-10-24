/// Minimal, dependency-free service locator.
/// Keeps neutral/offline policy intact and avoids global state beyond a small registry.
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  final Map<Type, dynamic> _services = {};

  T get<T>() {
    final svc = _services[T];
    if (svc == null) {
      throw StateError('Service of type $T not found.');
    }
    return svc as T;
  }

  void registerSingleton<T>(T value) {
    _services[T] = value;
  }

  bool isRegistered<T>() => _services.containsKey(T);
}
