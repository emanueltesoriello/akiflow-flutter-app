package com.akiflow.mobile

import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.akiflow.mobile/firstDayOfWeek"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFirstDayOfWeek") {
                val firstDayOfWeek = FirstDayOfWeekUtil.getFirstDayOfWeek(applicationContext)
                result.success(firstDayOfWeek)
            } else {
                result.notImplemented()
            }
        }
    }
}
