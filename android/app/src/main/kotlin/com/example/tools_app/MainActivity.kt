package br.dev.rodrigopinheiro.tools_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var snapshotChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val plugin = NetworkSnapshotPlugin(applicationContext)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NetworkSnapshotPlugin.CHANNEL,
        )
        snapshotChannel = channel
        channel.setMethodCallHandler { call, result ->
            plugin.handle(call.method, result) {
                // Notify Dart that the default network changed.
                runOnUiThread {
                    snapshotChannel?.invokeMethod("onNetworkChanged", null)
                }
            }
        }
    }
}
