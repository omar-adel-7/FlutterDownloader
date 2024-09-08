package com.file.downloader.download

import android.app.Notification
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.ResultReceiver
import androidx.core.app.NotificationCompat
import com.file.downloader.R
import com.file.downloader.download.IDownload.getDownloads
import com.file.downloader.download.IDownload.isInDownloading
import com.file.downloader.download.model_download.DownloadDbUtil
import com.file.downloader.download.model_download.entity.DownloadModel
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import java.util.*


abstract class IDownloadService : Service() {
    var resultReceiver:ResultReceiver?=null
    var lastProgressTime: Long = 0

    fun getNotificationOfDownload(downloadModel: DownloadModel): Notification {
        return getNotificationBuilderOfDownload(downloadModel).build()
    }

    protected abstract fun getNotificationBuilderOfDownload(downloadModel: DownloadModel): NotificationCompat.Builder
    protected open fun getNotificationBuilderOfCompleteDownload(downloadModel: DownloadModel): NotificationCompat.Builder? {
        return null
    }

    protected abstract fun onStartCommandCustom(intent: Intent?)
    protected abstract fun notifyProgress(notification: Notification?)
    protected abstract fun notifySuccess(url: String?, notification: Notification?)
    abstract fun callback_before_error( downloadErrorMessage:String)
    abstract fun sendEvent(message: Bundle)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        onStartCommandCustom(intent)
        if (intent != null) {
            val srcUrl = intent.getStringExtra(IDownload.SRC_URL_KEY)
            val action = intent.action
            if (action != null) {
                if (action == resources.getString(
                        R.string.download_ACTION_CANCEL_AND_CLEAR_ALL
                    )
                ) {
                    removeAll()
                } else if (action == resources.getString(
                        R.string.download_ACTION_CANCEL_ITEM
                    )
                ) {
                    removeDownload(
                        srcUrl, false,
                        true, false
                    )
                } else if (action == resources.getString(
                        R.string.download_ACTION_DOWNLOAD_ITEM
                    )
                ) {
                    val destDirPath = intent.getStringExtra(IDownload.SRC_DEST_DIR_PATH_KEY)
                    val fileNameWithoutExtension =
                        intent.getStringExtra(IDownload.SRC_FILE_NAME_WITHOUT_EXTENSION_KEY)
                    val extension = intent.getStringExtra(IDownload.SRC_FILE_EXTENSION_KEY)
                    val notificationMessage =
                        intent.getStringExtra(IDownload.SRC_NOTIFICATION_MESSAGE)
                    val notificationProgressMessage =
                        intent.getStringExtra(IDownload.SRC_NOTIFICATION_PROGRESS_MESSAGE)
                    val notificationCompleteMessage =
                        intent.getStringExtra(IDownload.SRC_NOTIFICATION_COMPLETE_MESSAGE)
                    resultReceiver = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU){
                        intent.getParcelableExtra(
                            IDownload.ResultReceiver_Key,
                            ResultReceiver::class.java
                        )
                    }else{
                        intent.getParcelableExtra(IDownload.ResultReceiver_Key)
                    }
                    if (!isInDownloading(this, srcUrl)) {
                        if (destDirPath != null
                            && fileNameWithoutExtension != null
                            && extension != null
                            && notificationMessage != null
                            && notificationProgressMessage != null
                            && notificationCompleteMessage != null
                        ) {
                            val downloadModel = srcUrl?.let {
                                DownloadModel(
                                    it,
                                    destDirPath,
                                    fileNameWithoutExtension,
                                    extension,
                                    notificationMessage,
                                    notificationProgressMessage,
                                    notificationCompleteMessage,
                                )
                            }
                            if (downloadModel != null) {
                                DownloadDbUtil.insertDownload(this, downloadModel)
                                sendAdded(downloadModel)
                            }
                            val downloadModels = getDownloads(this)
                            if (downloadModels != null) {
                                if (downloadModels.size == 1) {
                                    if (isInDownloading(this, downloadModels[0].url)) {
                                        try {
                                            startForeground( /*FOREGROUND_ID*/downloadNotId,
                                                getNotificationOfDownload(downloadModels[0])
                                            )
                                            startDownload(downloadModels[0])
                                        }
                                        catch (e:java.lang.Exception)
                                        {
                                            DownloadDbUtil.clearDownloads(this)
                                            sendStartForegroundException(downloadModels[0])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return START_REDELIVER_INTENT
    }
    fun startDownload(downloadModel: DownloadModel) {
         Thread(Runnable {
             var connection: HttpURLConnection? = null
             var input: InputStream? = null
             var output: OutputStream? = null
             try {
                 val url = URL(downloadModel.url)
                 connection = url.openConnection() as HttpURLConnection
                 connection.connectTimeout = 15000
                 connection.connect()
                 if (!IDownload.createFolderIfNotExists(IDownload.getFolderPathOfFile(downloadModel.dest_file_full_path))) {
                     sendSuccessError(
                         downloadModel,
                         false,
                         IDownload.RESPONSE_CREATE_FOLDER_ERROR_MESSAGE
                     )
                     return@Runnable
                 }

                 var tmp = 0.0
                 var fileSizeInbytes = connection.contentLength.toDouble()
                 fileSizeInbytes /= 1024
                 fileSizeInbytes /= 1024
                 if (IDownload.getAvailableStorageInBytes(
                         File(
                             IDownload.getFolderPathOfFile(
                                 downloadModel.dest_file_full_path
                             )
                         )
                     )
                     < fileSizeInbytes
                 ) {
                     sendSuccessError(downloadModel, false, IDownload.RESPONSE_NO_FREE_SPACE_MESSAGE)
                     return@Runnable
                 }

                 input = BufferedInputStream(url.openStream())
                 output = FileOutputStream(downloadModel.temp_dest_file_full_path)
                 val data = ByteArray(4096)
                 var totalDownloaded = 0.0
                 var currentDownload: Int
                 while (input.read(data).also { currentDownload = it } != -1) {
                     if (!isInDownloading(
                             this, downloadModel.url
                         )
                     ) {
                         deleteDownloadFile(downloadModel)
                         sendCancel(downloadModel)
                         return@Runnable
                     }
                     totalDownloaded += currentDownload.toDouble()
                     tmp = totalDownloaded / 1024
                     tmp /= 1024
                     tmp *= 100
                     if (fileSizeInbytes > 0) {
                         val progress = tmp / fileSizeInbytes
                         sendProgress(downloadModel, progress.toInt(), fileSizeInbytes)
                     }
                     output.write(data, 0, currentDownload)
                 }
                 val tempFile = File(downloadModel.temp_dest_file_full_path)
                 val targetFile = File(downloadModel.dest_file_full_path)
                 tempFile.renameTo(targetFile)
                 sendSuccessError(downloadModel, true, null)
             } catch (e: Exception) {
                 e.printStackTrace()
                 deleteDownloadFile(downloadModel)
                 sendSuccessError(downloadModel, false, IDownload.RESPONSE_CONNECTION_ERROR_MESSAGE)
             } finally {
                 try {
                     if (output != null) {
                         output.flush()
                         output.close()
                     }
                     input?.close()
                     connection?.disconnect()
                 } catch (e: Exception) {
                     e.printStackTrace()
                 }
             }
         }).start()
    }

    private fun deleteDownloadFile(downloadModel: DownloadModel) {
            IDownload.DeleteRecursive(
                this,
                downloadModel.temp_dest_file_full_path
            )
    }

    fun sendProgress(downloadModel: DownloadModel, progress: Int, size: Double) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, downloadModel.url)
        message.putInt(IDownload.RESPONSE_PROGRESS_KEY, progress)
        message.putDouble(IDownload.RESPONSE_SIZE_KEY, size)
        val time = Date().time
        if (time - lastProgressTime >= 1200) {
            sendEvent(message)
            val notificationBuilder = getNotificationBuilderOfDownload(downloadModel)
            lastProgressTime = time
            notificationBuilder.setProgress(100, progress, false)
            notifyProgress(notificationBuilder.build())
        }
    }

    fun sendAdded(downloadModel: DownloadModel) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, downloadModel.url)
        message.putString(IDownload.RESPONSE_ADDED_KEY, IDownload.RESPONSE_ADDED_KEY)
        sendEvent(message)
    }

    fun sendRemoved(downloadModel: DownloadModel) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, downloadModel.url)
        message.putString(RESPONSE_REMOVED_KEY, RESPONSE_REMOVED_KEY)
        sendEvent(message)
    }

    fun sendAllRemoved() {
        val message = Bundle()
        message.putString(RESPONSE_ALL_REMOVED_KEY, RESPONSE_ALL_REMOVED_KEY)
        sendEvent(message)
    }


    fun sendCancel(downloadModel: DownloadModel) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, downloadModel.url)
        message.putString(RESPONSE_CANCEL_KEY, RESPONSE_CANCEL_KEY)
        sendEvent(message)
        removeDownload(
            downloadModel.url, false,
            false, true
        )
    }

    fun sendSuccessError(downloadModel: DownloadModel, success: Boolean, errorMessage: String?) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, downloadModel.url)
        message.putBoolean(IDownload.RESPONSE_SUCCESS_ERROR_KEY, success)
        if (!success) {
            message.putString(IDownload.RESPONSE_ERROR_MESSAGE_KEY, errorMessage)
            if (errorMessage != null) {
                callback_before_error(errorMessage)
            }
        }
        removeDownload(
            downloadModel.url, success, false,
            true
        )
        sendEvent(message)
    }

    fun sendStartForegroundException(downloadModel: DownloadModel) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, downloadModel.url)
        message.putString(RESPONSE_FOREGROUND_EXCEPTION_KEY, RESPONSE_FOREGROUND_EXCEPTION_KEY)
        sendEvent(message)
    }

    fun removeDownload(
        url: String?, isSuccess: Boolean, cancelledByAction: Boolean, checkToNext: Boolean
    ) {
        val downloads = getDownloads(this)
        if (downloads != null) {
            for (i in downloads.indices.reversed()) {
                if (downloads.size > i) {
                    if (downloads[i].url == url) {
                        if (isSuccess) {
                            val notificationBuilder = getNotificationBuilderOfCompleteDownload(
                                downloads[i]
                            )
                            notifySuccess(url, notificationBuilder?.build())
                            DownloadDbUtil.removeDownload(this, url)
                        } else {
                            if (cancelledByAction) {
                                deleteDownloadFile(downloads[i])
                            }
                            val downloadModel = downloads[i]
                            DownloadDbUtil.removeDownload(this, url)
                            sendRemoved(downloadModel)
                        }
                        break
                    }
                }
            }
        }
        if (checkToNext) {
            checkToNextDownload()
        }
    }

    fun removeAll() {
        DownloadDbUtil.clearDownloads(this)
        sendAllRemoved()
        stopThisServiceOrNot()
    }

    fun checkToNextDownload() {
        val downloads = getDownloads(this)
        if (downloads.isNullOrEmpty()) {
            stopThisServiceOrNot()
        } else {
            startDownload(downloads[0])
        }
    }

    fun stopThisServiceOrNot() {
        val downloads = getDownloads(this)
        if (downloads.isNullOrEmpty()) {
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            {
                stopForeground(STOP_FOREGROUND_REMOVE)
            }
            else
            {
                stopForeground(true)
            }
            stopSelf()
        }
    }

    abstract val downloadNotId: Int

    companion object {
        const val RESPONSE_ALL_REMOVED_KEY = "response_all_removed"
        const val RESPONSE_REMOVED_KEY = "response_removed"
        const val RESPONSE_CANCEL_KEY = "response_cancel"
        const val RESPONSE_FOREGROUND_EXCEPTION_KEY = "response_foreground_exception_key"
        var STATUS_DOWNLOAD_ADDED = "STATUS_DOWNLOAD_ADDED"
        var STATUS_DOWNLOAD_QUEUED = "STATUS_DOWNLOAD_QUEUED"
        var STATUS_DOWNLOAD_PROGRESS = "STATUS_DOWNLOAD_PROGRESS"
        var STATUS_DOWNLOAD_COMPLETED = "STATUS_DOWNLOAD_COMPLETED"
        var STATUS_DOWNLOAD_ERROR = "STATUS_DOWNLOAD_ERROR"
        var STATUS_DOWNLOAD_FOREGROUND_EXCEPTION = "STATUS_DOWNLOAD_FOREGROUND_EXCEPTION"
        var STATUS_DOWNLOAD_REMOVED = "STATUS_DOWNLOAD_REMOVED"
        var STATUS_DOWNLOAD_ALL_REMOVED = "STATUS_DOWNLOAD_ALL_REMOVED"
        var STATUS_DOWNLOAD_CANCELLED = "STATUS_DOWNLOAD_CANCELLED"
    }


}