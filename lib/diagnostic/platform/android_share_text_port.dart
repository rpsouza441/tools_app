import 'package:flutter/services.dart';

import '../contracts/share_text_port.dart';

/// Android share port over a MethodChannel to a native Intent.ACTION_SEND.
/// No share_plus dependency (keeps AGP 8.11.1); no persistence.
class AndroidShareTextPort implements ShareTextPort {
  AndroidShareTextPort({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(kShareTextChannel);

  final MethodChannel _channel;

  @override
  Future<void> share(String text) async {
    await _channel.invokeMethod<void>('shareText', text);
  }
}

/// MethodChannel name shared with the Kotlin ShareTextPlugin.
const String kShareTextChannel = 'br.dev.rodrigopinheiro.tools_app/share_text';
