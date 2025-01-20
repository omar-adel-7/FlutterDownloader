package com.file.downloader

import android.app.Notification
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.file.downloader.IDownload.ResultReceiver_Error
import com.file.downloader.IDownload.ResultReceiver_Progress
import com.file.downloader.IDownload.ResultReceiver_Status
import com.file.downloader.IDownload.ResultReceiver_Url


class DownloadService : IDownloadService() {
    var notificationUtils: NotificationUtils? = null
    override fun onStartCommandCustom(intent: Intent?) {
        notificationUtils = NotificationUtils(this)
    }

    override fun notifyProgress(url:String,notification: Notification?) {
        notificationUtils?.manager?.notify( url,notificationId, notification)
    }

    override fun notifySuccess(url:String,notification: Notification?) {
        notificationUtils?.manager?.cancel(notificationId)
        notificationUtils?.manager?.notify(url,notificationId,notification)
    }

    override fun notifyError(url:String) {
        notificationUtils?.manager?.cancel(url,notificationId)
    }

    override fun notifyStoppedService() {
        notificationUtils?.manager?.cancel(notificationId)
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun callback_before_error(downloadErrorMessage: String) {
        // displayToast(downloadErrorMessage)
    }

    fun displayToast(message: String?) {
        val mHandler = Handler(mainLooper)
        mHandler.post { Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show() }
    }


    public override fun getNotificationBuilderOfDownload(
        notification_message: String,notification_progress_message: String
    ): NotificationCompat.Builder {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentTitle(
                "$notification_progress_message $notification_message"
            )
            .setTicker(
                "$notification_progress_message $notification_message"
            )
            .setSmallIcon(android.R.drawable.stat_sys_download)
        return notificationBuilder
    }

    override fun getNotificationBuilderOfCompleteDownload(
        notification_message: String,notification_complete_message: String
    ): NotificationCompat.Builder {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentTitle("$notification_complete_message $notification_message")
            .setTicker("$notification_complete_message $notification_message")
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
        return notificationBuilder
    }

    override val notificationId: Int
        get() = 1

    override fun sendEvent(message: Bundle) {
        val downloadEvent = IDownload.getDownloadEvent(this, message)
        val mHandler = Handler(mainLooper)
        mHandler.post {
            val bundle = Bundle()
            bundle.putString(ResultReceiver_Url, downloadEvent.url)
            bundle.putString(ResultReceiver_Status, downloadEvent.status)
            downloadEvent.progress?.let { bundle.putInt(ResultReceiver_Progress, it) }
            downloadEvent.error?.let { bundle.putString(ResultReceiver_Error, it) }
            resultReceiver?.send(0, bundle)
        }
    }

    companion object {
        fun cancelCurrentDownload(context: Context) {
            val intent = Intent(context, DownloadService::class.java)
            intent.action = context.getString(
                R.string.download_ACTION_CANCEL_CURRENT_DOWNLOAD
            )
            context.startService(intent)
        }
    }
}