package com.example.project_pember

import android.os.Build
import android.os.Bundle
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.project_pember/storage"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getCustomDirectory") {
                val dir = File(Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_PICTURES), "BookingApp")

                if (!dir.exists()) {
                    val created = dir.mkdirs()
                    if (!created) {
                        result.error("DIR_ERROR", "Gagal membuat folder", null)
                        return@setMethodCallHandler
                    }
                }

                result.success(dir.absolutePath)
            } else {
                result.notImplemented()
            }
        }
    }
}
