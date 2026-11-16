package com.tokona.app.tokona

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.tokona.app/native_notifications"
    private val listenerChannelName = "com.tokona.app/shopee_notification_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // EventChannel untuk stream notifikasi Shopee & kurir secara real-time
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, listenerChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    ShopeeNotificationListener.listenerCallback = { pkg, title, text, subText, time ->
                        runOnUiThread {
                            val map = HashMap<String, Any>()
                            map["packageName"] = pkg
                            map["title"] = title
                            map["text"] = text
                            map["subText"] = subText
                            map["timestamp"] = time
                            events?.success(map)
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    ShopeeNotificationListener.listenerCallback = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotification" -> {
                    val id = (call.argument<Number>("id") ?: System.currentTimeMillis()).toInt()
                    val title = call.argument<String>("title") ?: "Tokona POS"
                    val body = call.argument<String>("body") ?: ""
                    showPushNotification(id, title, body)
                    result.success(true)
                }
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 101)
                    }
                    result.success(true)
                }
                "isNotificationListenerEnabled" -> {
                    val isEnabled = NotificationManagerCompat.getEnabledListenerPackages(this).contains(packageName)
                    result.success(isEnabled)
                }
                "openNotificationListenerSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERR_SETTINGS", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun showPushNotification(id: Int, title: String, body: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "tokona_alerts"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Notifikasi Tokona POS",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Pengingat booking, kasbon jatuh tempo, dan stok"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 150, 250)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getActivity(this, id, intent, flags)

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(id, notification)
    }
}
