// Firebase options placeholder. The project has been converted to an
// offline-only build and Firebase has been removed. If any remaining
// code attempts to use DefaultFirebaseOptions, throw a helpful error so
// the call site can be updated.

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static Never get currentPlatform {
    throw UnsupportedError(
      'Firebase has been removed from this build. Remove uses of DefaultFirebaseOptions or re-enable Firebase.',
    );
  }
}
