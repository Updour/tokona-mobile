package com.tokona.app.tokona

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.ContactsContract
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
    private val contactChannelName = "com.tokona.app/native_contacts"
    private val pickContactRequestCode = 9042
    private val pickAddressRequestCode = 9043
    private var pendingContactResult: MethodChannel.Result? = null

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

        // MethodChannel untuk import kontak & alamat bawaan HP (ACTION_PICK tanpa izin penuh)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, contactChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickContact" -> {
                    if (pendingContactResult != null) {
                        result.error("BUSY", "Pemilih kontak sedang terbuka", null)
                        return@setMethodCallHandler
                    }
                    try {
                        pendingContactResult = result
                        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, pickContactRequestCode)
                    } catch (e: Exception) {
                        pendingContactResult = null
                        result.error("ERR_CONTACT", e.message, null)
                    }
                }
                "pickAddress" -> {
                    if (pendingContactResult != null) {
                        result.error("BUSY", "Pemilih kontak sedang terbuka", null)
                        return@setMethodCallHandler
                    }
                    try {
                        pendingContactResult = result
                        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_URI)
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, pickAddressRequestCode)
                    } catch (e: Exception) {
                        pendingContactResult = null
                        result.error("ERR_ADDRESS", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pickContactRequestCode) {
            val callback = pendingContactResult
            pendingContactResult = null
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                try {
                    val uri = data.data!!
                    val projection = arrayOf(
                        ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                        ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                        ContactsContract.CommonDataKinds.Phone.NUMBER
                    )
                    contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val contactId = cursor.getString(0) ?: ""
                            val name = cursor.getString(1) ?: ""
                            val phone = cursor.getString(2) ?: ""
                            var address = ""
                            if (contactId.isNotEmpty()) {
                                try {
                                    contentResolver.query(
                                        ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_URI,
                                        arrayOf(ContactsContract.CommonDataKinds.StructuredPostal.FORMATTED_ADDRESS),
                                        "${ContactsContract.CommonDataKinds.StructuredPostal.CONTACT_ID} = ?",
                                        arrayOf(contactId),
                                        null
                                    )?.use { postalCursor ->
                                        if (postalCursor.moveToFirst()) {
                                            address = postalCursor.getString(0) ?: ""
                                        }
                                    }
                                } catch (_: Exception) {}
                            }
                            callback?.success(mapOf("name" to name, "phone" to phone, "address" to address))
                            return
                        }
                    }
                    callback?.success(null)
                } catch (e: Exception) {
                    callback?.error("ERR_READ_CONTACT", e.message, null)
                }
            } else {
                callback?.success(null)
            }
            return
        } else if (requestCode == pickAddressRequestCode) {
            val callback = pendingContactResult
            pendingContactResult = null
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                try {
                    val uri = data.data!!
                    val projection = arrayOf(
                        ContactsContract.CommonDataKinds.StructuredPostal.FORMATTED_ADDRESS,
                        ContactsContract.CommonDataKinds.StructuredPostal.STREET,
                        ContactsContract.CommonDataKinds.StructuredPostal.CITY
                    )
                    contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            var addr = cursor.getString(0) ?: ""
                            if (addr.isEmpty()) {
                                val street = cursor.getString(1) ?: ""
                                val city = cursor.getString(2) ?: ""
                                addr = listOf(street, city).filter { it.isNotEmpty() }.joinToString(", ")
                            }
                            callback?.success(mapOf("address" to addr))
                            return
                        }
                    }
                    callback?.success(null)
                } catch (e: Exception) {
                    callback?.error("ERR_READ_ADDRESS", e.message, null)
                }
            } else {
                callback?.success(null)
            }
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
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
