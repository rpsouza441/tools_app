package br.dev.rodrigopinheiro.tools_app

import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel

/**
 * Shares plain text via Intent.ACTION_SEND with a chooser. No extra permission
 * or queries; user-initiated only. No share_plus dependency.
 */
class ShareTextPlugin(private val context: Context) {

    companion object {
        const val CHANNEL = "br.dev.rodrigopinheiro.tools_app/share_text"
    }

    fun handle(method: String, arguments: Any?, result: MethodChannel.Result) {
        when (method) {
            "shareText" -> {
                val text = arguments as? String
                if (text == null) {
                    result.error("INVALID_ARGUMENT", "text must be a String", null)
                    return
                }
                val sendIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                }
                val chooser = Intent.createChooser(sendIntent, "Compartilhar diagnóstico")
                chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(chooser)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
