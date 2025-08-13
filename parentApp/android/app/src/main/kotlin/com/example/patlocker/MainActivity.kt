package com.example.patlocker
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.patlocker/blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        print("kotlin works")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "blockApp") {
                val packageName = call.argument<String>("packageName")
                if (packageName != null) {
                    blockApp(packageName)
                    result.success("App blocked: $packageName")
                } else {
                    result.error("PACKAGE_ERROR", "Package name is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun blockApp(packageName: String) {
        try {
            val packageManager: PackageManager = packageManager
            val packageInfo = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            packageManager.setApplicationEnabledSetting(packageInfo.packageName, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
    }
}
