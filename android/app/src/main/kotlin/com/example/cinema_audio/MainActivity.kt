package com.example.cinema_audio

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "cinema_audio/engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "processAudio") {
                val input = call.argument<String>("inputPath") ?: ""
                val profile = call.argument<String>("profile") ?: "Dolby"
                val channels = call.argument<String>("channels") ?: "Stereo"
                val intensity = call.argument<String>("intensity") ?: "Medium"

                try {
                    val cmd = buildTermuxCommand(
                        input, profile, channels, intensity
                    )

                    Runtime.getRuntime().exec(cmd)

                    result.success("Processing started in Termux")

                } catch (e: Exception) {
                    Log.e("CinemaAudio", "Engine error", e)
                    result.error("ENGINE_FAIL", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun buildTermuxCommand(
        input: String,
        profile: String,
        channels: String,
        intensity: String
    ): String {

        val script = "/data/data/com.termux/files/home/cinema_engine.sh"

        return arrayOf(
            "sh", "-c",
            "am start --user 0 -n com.termux/.app.TermuxActivity " +
                    "--es cmd \"$script '$input' '$profile' '$channels' '$intensity'\""
        ).joinToString(" ")
    }
}
