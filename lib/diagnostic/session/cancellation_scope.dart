/// Collects physical abort callbacks for a single run and fires them on cancel.
/// This is the real cancellation mechanism — Future.timeout alone is forbidden
/// because it stops waiting while the underlying I/O keeps running (D-07, QUAL-02).
class CancellationScope {
  final List<void Function()> _aborts = <void Function()>[];
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  /// Register a physical abort (CancelToken.cancel, ConnectionTask.cancel,
  /// Socket.destroy, timer cancel, ...). If already cancelled, fires immediately.
  void register(void Function() abort) {
    if (_cancelled) {
      abort();
      return;
    }
    _aborts.add(abort);
  }

  /// Idempotently aborts every registered callback.
  Future<void> cancelAll() async {
    if (_cancelled) return;
    _cancelled = true;
    for (final abort in _aborts) {
      try {
        abort();
      } catch (_) {
        // An individual abort failing must not block the others.
      }
    }
    _aborts.clear();
  }
}
