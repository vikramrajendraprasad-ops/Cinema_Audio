
package com.example.cinema_audio

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "cinema.engine/termux"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "runEngine") {
                val cmd = call.argument<String>("cmd") ?: ""

                runTermux(cmd)
                result.success(true)

            } else {
                result.notImplemented()
            }
        }
    }

    private fun runTermux(command: String) {
        val intent = Intent("com.termux.RUN_COMMAND")

        intent.setClassName(
            "com.termux",
            "com.termux.app.RunCommandReceiver"
        )

        intent.putExtra(
            "com.termux.RUN_COMMAND_PATH",
            "/data/data/com.termux/files/usr/bin/bash"
        )

        intent.putExtra(
            "com.termux.RUN_COMMAND_ARGUMENTS",
            arrayOf("-lc", command)
        )

        intent.putExtra(
            "com.termux.RUN_COMMAND_WORKDIR",
            "/data/data/com.termux/files/home"
        )

        intent.putExtra(
            "com.termux.RUN_COMMAND_BACKGROUND",
            false   // TRUE = silent but unreliable
        )

        startActivity(intent)
    }
}
