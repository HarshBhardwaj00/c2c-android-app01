package com.example.c2c

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableHighRefreshRate()
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display
            } else {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay
            }
            val modes = display?.supportedModes ?: return
            var maxRefreshRate = 0f
            var selectedModeId = 0
            for (mode in modes) {
                if (mode.refreshRate > maxRefreshRate) {
                    maxRefreshRate = mode.refreshRate
                    selectedModeId = mode.modeId
                }
            }
            if (selectedModeId != 0) {
                window.attributes = window.attributes.apply {
                    preferredDisplayModeId = selectedModeId
                }
            }
        }
    }
}
