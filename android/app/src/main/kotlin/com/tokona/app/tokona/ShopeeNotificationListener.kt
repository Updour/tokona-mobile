package com.tokona.app.tokona

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class ShopeeNotificationListener : NotificationListenerService() {

    companion object {
        var listenerCallback: ((packageName: String, title: String, text: String, subText: String, time: Long) -> Unit)? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        val pkg = sbn.packageName ?: ""
        // Filter spesifik Shopee / Marketplace kurir
        if (pkg.contains("shopee") || pkg.contains("spx") || pkg.contains("jne") || pkg.contains("jnt") || pkg.contains("sicepat")) {
            val extras = sbn.notification?.extras ?: return
            val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: text
            val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() ?: ""
            val postTime = sbn.postTime

            listenerCallback?.invoke(pkg, title, bigText, subText, postTime)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}
