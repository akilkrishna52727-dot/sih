package com.farmeasy.app

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
	private val CHANNEL = "com.farmeasy.app/permissions"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"requestPermissions" -> {
						requestPermissions()
						result.success(true)
					}
					"checkPermissions" -> {
						val hasPermissions = checkPermissions()
						result.success(hasPermissions)
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun checkPermissions(): Boolean {
		val permissions = arrayOf(
			Manifest.permission.CAMERA,
			Manifest.permission.RECORD_AUDIO,
			Manifest.permission.READ_EXTERNAL_STORAGE,
			Manifest.permission.ACCESS_FINE_LOCATION
		)
		for (permission in permissions) {
			if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
				return false
			}
		}
		return true
	}

	private fun requestPermissions() {
		val permissions = arrayOf(
			Manifest.permission.CAMERA,
			Manifest.permission.RECORD_AUDIO,
			Manifest.permission.READ_EXTERNAL_STORAGE,
			Manifest.permission.ACCESS_FINE_LOCATION
		)
		ActivityCompat.requestPermissions(this, permissions, 1001)
	}
}
