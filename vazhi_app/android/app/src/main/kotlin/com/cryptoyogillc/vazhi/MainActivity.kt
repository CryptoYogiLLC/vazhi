package com.cryptoyogillc.vazhi

import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cryptoyogillc.vazhi/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getMemoryInfo") {
                    val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val memInfo = ActivityManager.MemoryInfo()
                    activityManager.getMemoryInfo(memInfo)

                    val info = mapOf(
                        "totalRam" to (memInfo.totalMem / (1024 * 1024)),
                        "availableRam" to (memInfo.availMem / (1024 * 1024)),
                        "lowMemory" to memInfo.lowMemory,
                        "threshold" to (memInfo.threshold / (1024 * 1024))
                    )
                    result.success(info)
                } else {
                    result.notImplemented()
                }
            }
    }
}
