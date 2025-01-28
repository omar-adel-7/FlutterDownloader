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
import kotlin.collections.get


class DownloadService : IDownloadService() {
    var notificationUtils: NotificationUtils? = null
    override fun onStartCommandCustom(intent: Intent?) {
        notificationUtils = NotificationUtils(this)
    }

    override fun notifyProgress(url: String, notification: Notification?) {
        if (isSerial) {
            notificationUtils?.manager?.notify(
                notificationId,
                notification
            )
        } else {
            notificationUtils?.manager?.notify(
                notificationPrefixTag + url,
                notificationId,
                notification
            )
        }
    }

    override fun notifySuccess(url: String, notification: Notification?) {
        if (isSerial) {
            notificationUtils?.manager?.notify(
                url,notificationId,
                notification
            )
        } else {
            notificationUtils?.manager?.cancel(
                notificationPrefixTag + url, notificationId)
            notificationUtils?.manager?.notify(
                url,notificationId,
                notification
            )
        }
    }

    override fun notifyError(url: String) {
        if(!isSerial)
        {
            notificationUtils?.manager?.cancel(notificationPrefixTag + url, notificationId)
        }
    }

    override fun notifyCanceled(url: String) {
        if(!isSerial)
        {
            notificationUtils?.manager?.cancel(notificationPrefixTag + url, notificationId)
        }
    }

    override fun notifyStoppedService() {
        val notificationList = notificationUtils?.manager?.activeNotifications
        if (notificationList?.isNotEmpty() == true) {
            for (i in 0 until notificationList.size) {
                if(notificationList[i].tag!=null){
                    if (notificationList[i].tag.startsWith(notificationPrefixTag)) {
                        notificationUtils?.manager?.cancel(notificationList[i].tag, notificationId)
                    }
                }
            }
        }
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun callbackBeforeError(downloadErrorMessage: String) {
        // displayToast(downloadErrorMessage)
    }

    fun displayToast(message: String?) {
        val mHandler = Handler(mainLooper)
        mHandler.post { Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show() }
    }

    public override fun getParallelMainNotificationBuilder(
    ): NotificationCompat.Builder {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentTitle(
                parallelMainNotificationMessage
            )
            .setTicker(
                parallelMainNotificationMessage
            )
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
        return notificationBuilder
    }

    public override fun getNotificationBuilderOfDownload(
        notificationMessage: String
    ): NotificationCompat.Builder {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentTitle(
                "$notificationProgressMessage $notificationMessage"
            )
            .setTicker(
                "$notificationProgressMessage $notificationMessage"
            )
            .setSmallIcon(android.R.drawable.stat_sys_download)
        return notificationBuilder
    }

    override fun getNotificationBuilderOfCompleteDownload(
        notificationMessage: String
    ): NotificationCompat.Builder {
        val notificationBuilder =
            NotificationCompat.Builder(this, NotificationUtils.ANDROID_CHANNEL_ID)
        notificationBuilder
            .setContentTitle("$notificationCompleteMessage $notificationMessage")
            .setTicker("$notificationCompleteMessage $notificationMessage")
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
        return notificationBuilder
    }


    val notificationPrefixTag: String
        get() = "DownloadServiceNotificationPrefixTag"


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
        fun cancelDownloadFile(context: Context, url: String?) {
            val intent = Intent(context, DownloadService::class.java)
            intent.action =
                context.resources.getString(
                    R.string.download_ACTION_CANCEL_SINGLE
                )
            intent.putExtra(IDownload.SRC_URL_KEY, url)
            context.startService(intent)
        }

        fun cancelDownloads(context: Context) {
            val intent = Intent(context, DownloadService::class.java)
            intent.action = context.getString(
                R.string.download_ACTION_CANCEL_ALL
            )
            context.startService(intent)
        }
    }
}