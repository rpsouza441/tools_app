import '../contracts/share_text_port.dart';

/// Share stub: does nothing (non-Android / tests). No Intent, no persistence.
class NoopShareTextPort implements ShareTextPort {
  const NoopShareTextPort();

  @override
  Future<void> share(String text) async {}
}
