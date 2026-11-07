package br.edu.ifb.felipemadison.compras

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val canal = "compras/dispositivo"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canal)
            .setMethodCallHandler { chamada, resultado ->
                when (chamada.method) {
                    "obterInformacoes" -> resultado.success(obterInformacoes())
                    else -> resultado.notImplemented()
                }
            }
    }

    private fun obterInformacoes(): Map<String, Any> {
        val bateria = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return mapOf(
            "fabricante" to Build.MANUFACTURER,
            "modelo" to Build.MODEL,
            "versaoAndroid" to Build.VERSION.RELEASE,
            "bateria" to bateria.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY),
        )
    }
}
