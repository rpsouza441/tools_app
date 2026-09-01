package br.dev.rodrigopinheiro.tools_app

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

/**
 * Reads a snapshot of the active network from ConnectivityManager,
 * NetworkCapabilities and LinkProperties/RouteInfo. Returns only serializable
 * facts over the MethodChannel — never SSID/BSSID/transportInfo, never a made-up
 * gateway (DIAG-02/03/04, QUAL-06, D-11).
 */
class NetworkSnapshotPlugin(private val context: Context) {

    companion object {
        const val CHANNEL = "br.dev.rodrigopinheiro.tools_app/network_snapshot"
    }

    private val connectivityManager: ConnectivityManager
        get() = context.getSystemService(Context.CONNECTIVITY_SERVICE)
            as ConnectivityManager

    private var callback: ConnectivityManager.NetworkCallback? = null

    /** Builds the serializable snapshot map for the active network. */
    fun getSnapshot(): Map<String, Any?> {
        val cm = connectivityManager
        val active: Network? = cm.activeNetwork
        if (active == null) {
            return mapOf(
                "hasActiveNetwork" to false,
                "transports" to emptyList<String>(),
                "hasInternet" to false,
                "validated" to false,
                "captive" to false,
                "notMetered" to false,
                "localIpv4" to null,
                "gatewayIpv4" to null,
                "networkHandle" to null,
            )
        }

        val caps: NetworkCapabilities? = cm.getNetworkCapabilities(active)
        val link: LinkProperties? = cm.getLinkProperties(active)

        val transports = mutableListOf<String>()
        if (caps != null) {
            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) transports.add("wifi")
            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) transports.add("cellular")
            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) transports.add("vpn")
            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) transports.add("ethernet")
        }

        val hasInternet = caps?.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_INTERNET,
        ) ?: false
        val validated = caps?.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_VALIDATED,
        ) ?: false
        val captive = caps?.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_CAPTIVE_PORTAL,
        ) ?: false
        val notMetered = caps?.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_NOT_METERED,
        ) ?: false

        val localIpv4 = extractLocalIpv4(link)
        val gatewayIpv4 = extractGatewayIpv4(link)

        return mapOf(
            "hasActiveNetwork" to true,
            "transports" to transports,
            "hasInternet" to hasInternet,
            "validated" to validated,
            "captive" to captive,
            "notMetered" to notMetered,
            "localIpv4" to localIpv4,
            "gatewayIpv4" to gatewayIpv4,
            "networkHandle" to active.networkHandle,
        )
    }

    /**
     * Selects the active-network IPv4: prefers a non-link-local address; only
     * falls back to a 169.254/16 link-local if it is the only IPv4. Returns null
     * when there is no IPv4 — never invents one (DIAG-03).
     */
    private fun extractLocalIpv4(link: LinkProperties?): String? {
        if (link == null) return null
        var linkLocal: String? = null
        for (linkAddress in link.linkAddresses) {
            val addr = linkAddress.address
            if (addr is Inet4Address) {
                val host = addr.hostAddress ?: continue
                if (addr.isLinkLocalAddress) {
                    linkLocal = linkLocal ?: host
                } else {
                    return host
                }
            }
        }
        return linkLocal
    }

    /**
     * Reads the default-route gateway IPv4 from RouteInfo. Returns null when no
     * default route has a gateway — never assumes 192.168.x.1 (DIAG-04).
     */
    private fun extractGatewayIpv4(link: LinkProperties?): String? {
        if (link == null) return null
        for (route in link.routes) {
            if (route.isDefaultRoute && route.hasGateway()) {
                val gw = route.gateway
                if (gw is Inet4Address) {
                    return gw.hostAddress
                }
            }
        }
        return null
    }

    /** Registers a default-network callback only while the session asks for it. */
    fun startWatching(onChanged: () -> Unit) {
        if (callback != null) return
        val cb = object : ConnectivityManager.NetworkCallback() {
            // Do not read capabilities inside onAvailable; wait for the
            // capability/link callbacks which carry a consistent view.
            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities,
            ) {
                onChanged()
            }

            override fun onLinkPropertiesChanged(
                network: Network,
                linkProperties: LinkProperties,
            ) {
                onChanged()
            }

            override fun onLost(network: Network) {
                onChanged()
            }
        }
        callback = cb
        connectivityManager.registerDefaultNetworkCallback(cb)
    }

    /** Unregisters the default-network callback. Idempotent. */
    fun stopWatching() {
        val cb = callback ?: return
        try {
            connectivityManager.unregisterNetworkCallback(cb)
        } catch (_: IllegalArgumentException) {
            // Already unregistered; ignore.
        }
        callback = null
    }

    fun handle(method: String, result: MethodChannel.Result, notifyChange: () -> Unit) {
        when (method) {
            "getSnapshot" -> result.success(getSnapshot())
            "startWatching" -> {
                startWatching(notifyChange)
                result.success(null)
            }
            "stopWatching" -> {
                stopWatching()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
