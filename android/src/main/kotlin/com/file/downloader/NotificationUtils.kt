package com.file.downloader

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.os.Build

class NotificationUtils(base: Context?) : ContextWrapper(base) {
    private var mManager: NotificationManager? = null

    companion object {
        const val ANDROID_CHANNEL_ID = "com.file.downloader"
        const val ANDROID_CHANNEL_NAME = "Downloader Plugin Channel"
    }

    init {
        createChannels()
    }

    fun createChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // create android channel
            val androidChannel = NotificationChannel(
                ANDROID_CHANNEL_ID,
                ANDROID_CHANNEL_NAME, NotificationManager.IMPORTANCE_LOW
            )
            // Sets whether notifications posted to this channel should display notification lights
            androidChannel.enableLights(true)
            // Sets whether notification posted to this channel should vibrate.
            androidChannel.enableVibration(false)
            // Sets the notification light color for notifications posted to this channel
            androidChannel.lightColor = Color.GREEN
            // Sets whether notifications posted to this channel appear on the lockscreen or not
            androidChannel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
            manager?.createNotificationChannel(androidChannel)
        }
    }

    val manager: NotificationManager?
        get() {
            if (mManager == null) {
                mManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            }
            return mManager
        }

}