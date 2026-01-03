
package com.example.cinema_audio

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "cinema/termux"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "runEngine") {
                val input = call.argument<String>("input")!!
                val profile = call.argument<String>("profile")!!
                val channels = call.argument<String>("channels")!!
                val intensity = call.argument<String>("intensity")!!

                val intent = Intent("com.termux.RUN_COMMAND").apply {
                    setClassName(
                        "com.termux",
                        "com.termux.app.RunCommandService"
                    )
                    putExtra("com.termux.RUN_COMMAND_PATH",
                        "/data/data/com.termux/files/home/cinema_engine/run.sh")
                    putExtra(
                        "com.termux.RUN_COMMAND_ARGUMENTS",
                        arrayOf(input, profile, channels, intensity)
                    )
                    putExtra("com.termux.RUN_COMMAND_BACKGROUND", true)
                }

                startService(intent)
                result.success("Engine started")
            } else {
                result.notImplemented()
            }
        }
    }
}
