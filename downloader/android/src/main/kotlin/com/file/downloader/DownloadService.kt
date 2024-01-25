package com.file.downloader

import android.app.Notification
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.file.downloader.download.IDownload
import com.file.downloader.download.IDownload.ResultReceiver_Progress
import com.file.downloader.download.IDownload.ResultReceiver_Status
import com.file.downloader.download.IDownload.SRC_URL_KEY
import com.file.downloader.download.IDownloadService
import com.file.downloader.download.model_download.entity.DownloadModel
import com.file.downloader.utils.NotificationUtils


class DownloadService : IDownloadService() {
    var notificationUtils: NotificationUtils? = null
    override fun onStartCommandCustom(intent: Intent?) {
        notificationUtils = NotificationUtils(this)
    }

    override fun notifyProgress(notification: Notification?) {
        notificationUtils?.manager?.notify( /*FOREGROUND_ID*/downloadNotId, notification)
    }

    override fun notifySuccess(url: String?, notification: Notification?) {
        notificationUtils?.manager?.notify(
            url, downloadNotId,
            notification
        )
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun callback_before_error(downloadErrorMessage:String) {
         // displayToast(downloadErrorMessage)
    }

    fun displayToast(message: String?) {
        val mHandler = Handler(mainLooper)
        mHandler.post { Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show() }
    }


    public override fun getNotificationBuilderOfDownload(downloadModel: DownloadModel): NotificationCompat.Builder {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentText(downloadModel.notification_progress_message
                    + " " + downloadModel.notification_message)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setTicker(downloadModel.notification_progress_message + " "
                    + downloadModel.notification_message)
        return notificationBuilder
    }

    override fun getNotificationBuilderOfCompleteDownload(downloadModel: DownloadModel): NotificationCompat.Builder? {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentText(downloadModel.notification_complete_message
                    + " " + downloadModel.notification_message)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setTicker(downloadModel.notification_complete_message
                    + " " + downloadModel.notification_message)
        return notificationBuilder
    }

    override val downloadNotId: Int
        get() = 1

    override fun sendEvent(message: Bundle) {
        val downloadEvent = IDownload.getDownloadEvent(this,message)
        val mHandler = Handler(mainLooper)
        mHandler.post {
            val bundle = Bundle()
            bundle.putString(ResultReceiver_Status, downloadEvent.status)
            downloadEvent.progress?.let { bundle.putInt(ResultReceiver_Progress, it) }
            resultReceiver?.send(0, bundle)
        }
    }

    companion object {

        fun sendCancelItem(context: Context, srcUrl: String?) {
            val intent = Intent(context, DownloadService::class.java)
            intent.action = context.getString(
                R.string.download_ACTION_CANCEL_ITEM
            )
            intent.putExtra(SRC_URL_KEY, srcUrl)
            context.startService(intent)
        }

        fun cancelAndClearAll(context: Context) {
            val intent = Intent(context, DownloadService::class.java)
            intent.action = context.getString(
                R.string.download_ACTION_CANCEL_AND_CLEAR_ALL
            )
            context.startService(intent)
        }
    }
}