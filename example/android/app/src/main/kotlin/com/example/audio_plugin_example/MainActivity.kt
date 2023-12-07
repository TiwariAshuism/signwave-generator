package com.example.audio_plugin_example

import com.example.audio_plugin.AudioPlugin
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Add your com.example.audio_plugin.AudioPlugin here
        flutterEngine?.plugins?.add(AudioPlugin())
    }
}
