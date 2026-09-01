/// Contract for sharing a plain-text session summary (Android ACTION_SEND in
/// production). No share_plus, no persistence (DIAG-15, QUAL-07, D-11).
abstract class ShareTextPort {
  Future<void> share(String text);
}
