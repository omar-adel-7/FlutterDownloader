package com.file.downloader

import android.app.Notification
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.ResultReceiver
import androidx.core.app.NotificationCompat
import com.file.downloader.IDownload
import com.file.downloader.R
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import java.util.*


abstract class IDownloadService : Service() {
    var resultReceiver: ResultReceiver? = null
    var lastProgressTime: Long = 0

    protected abstract fun getNotificationBuilderOfDownload(
        notification_message: String, notification_progress_message: String
    ): NotificationCompat.Builder

    protected abstract fun getNotificationBuilderOfCompleteDownload(
        notification_message: String, notification_complete_message: String
    ): NotificationCompat.Builder

    protected abstract fun onStartCommandCustom(intent: Intent?)
    protected abstract fun notifyProgress(notification: Notification?)
    protected abstract fun notifySuccess(notification: Notification?)
    abstract fun callback_before_error(downloadErrorMessage: String)
    abstract fun sendEvent(message: Bundle)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        onStartCommandCustom(intent)
        if (intent != null) {
            val id = intent.getStringExtra(IDownload.SRC_ID_KEY)
            val url = intent.getStringExtra(IDownload.SRC_URL_KEY)
            val action = intent.action
            if (action != null) {
                if (action == resources.getString(
                        R.string.download_ACTION_STOP_SERVICE
                    )
                ) {
                    stopThisService()
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
                    resultReceiver = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            IDownload.ResultReceiver_Key,
                            ResultReceiver::class.java
                        )
                    } else {
                        intent.getParcelableExtra(IDownload.ResultReceiver_Key)
                    }

                    if (
                        id!=null &&
                        url != null
                        && notificationMessage != null
                        && notificationProgressMessage != null
                        && notificationCompleteMessage != null) {
                        //foreground
//                        startForeground( /*FOREGROUND_ID*/downloadNotId,
//                            getNotificationBuilderOfDownload(
//                                notificationMessage, notificationProgressMessage
//                            ).build()
//                        )
                                    startDownload(
                                        id,
                                        url,
                                        destDirPath + fileNameWithoutExtension + extension,
                                        "$destDirPath$fileNameWithoutExtension-temp$extension",
                                        notificationMessage,
                                        notificationProgressMessage,
                                        notificationCompleteMessage)
                    }
                }
            }
        }
        return START_STICKY
    }

    fun startDownload(
        id: String,
        link: String,
        file_path: String,
        temp_file_path: String,
        notification_message: String,
        notification_progress_message: String,
        notification_complete_message:String

    ) {
        Thread(Runnable {
            var connection: HttpURLConnection? = null
            var input: InputStream? = null
            var output: OutputStream? = null
            try {
                val url = URL(link)
                connection = url.openConnection() as HttpURLConnection
                connection.connectTimeout = 15000
                connection.connect()
                if (!IDownload.createFolderIfNotExists(
                        IDownload.getFolderPathOfFile(
                            file_path
                        )
                    )
                ) {
                    sendSuccessError(
                        id,
                        link,
                        false,
                        IDownload.RESPONSE_CREATE_FOLDER_ERROR_MESSAGE,
                        notification_message,
                        notification_complete_message
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
                                file_path
                            )
                        )
                    )
                    < fileSizeInbytes
                ) {
                    sendSuccessError(
                        id,
                        link, false,
                        IDownload.RESPONSE_NO_FREE_SPACE_MESSAGE,
                        notification_message,
                        notification_complete_message)
                    return@Runnable
                }

                input = BufferedInputStream(url.openStream())
                output = FileOutputStream(temp_file_path)
                val data = ByteArray(4096)
                var totalDownloaded = 0.0
                var currentDownload: Int
                while (input.read(data).also { currentDownload = it } != -1) {
                    totalDownloaded += currentDownload.toDouble()
                    tmp = totalDownloaded / 1024
                    tmp /= 1024
                    tmp *= 100
                    if (fileSizeInbytes > 0) {
                        val progress = tmp / fileSizeInbytes
                        sendProgress(
                            id,
                            link, progress.toInt(), fileSizeInbytes,
                            notification_message, notification_progress_message
                        )
                    }
                    output.write(data, 0, currentDownload)
                }
                val tempFile = File(temp_file_path)
                val targetFile = File(file_path)
                tempFile.renameTo(targetFile)
                sendSuccessError(
                    id,
                    link, true, null,
                    notification_message,
                    notification_complete_message)
            } catch (e: Exception) {
                e.printStackTrace()
                deleteDownloadFile(temp_file_path)
                sendSuccessError(
                    id,
                    link, false,
                    IDownload.RESPONSE_CONNECTION_ERROR_MESSAGE,
                    notification_message,
                    notification_complete_message)
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
                finally {
                    stopThisService()
                }
            }
        }).start()
    }

    private fun deleteDownloadFile(temp_file_path: String) {
        IDownload.DeleteRecursive(
            this,
            temp_file_path
        )
    }

    fun sendProgress(
        id:String,
        url: String, progress: Int, size: Double,
        notification_message: String, notification_progress_message: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_ID_KEY, id)
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putInt(IDownload.RESPONSE_PROGRESS_KEY, progress)
        message.putDouble(IDownload.RESPONSE_SIZE_KEY, size)
        val time = Date().time
        if (time - lastProgressTime >= 1200) {
            sendEvent(message)
            val notificationBuilder = getNotificationBuilderOfDownload(
                notification_message, notification_progress_message
            )
            lastProgressTime = time
            notificationBuilder.setProgress(100, progress, false)
            notifyProgress(notificationBuilder.build())
        }
    }

    fun sendSuccessError(
        id:String,
        url: String,
        isSuccess: Boolean, errorMessage: String?,
        notification_message: String, notification_complete_message: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_ID_KEY, id)
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putBoolean(IDownload.RESPONSE_SUCCESS_ERROR_KEY, isSuccess)
        if (!isSuccess) {
            message.putString(IDownload.RESPONSE_ERROR_MESSAGE_KEY, errorMessage)
            if (errorMessage != null) {
                callback_before_error(errorMessage)
            }
        }
        if (isSuccess) {
            val notificationBuilder = getNotificationBuilderOfCompleteDownload(
                notification_message , notification_complete_message
            )
            notifySuccess(notificationBuilder?.build())
        }
        sendEvent(message)
    }

    fun stopThisService() {
        //foreground
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//                stopForeground(STOP_FOREGROUND_REMOVE)
//            } else {
//                stopForeground(true)
//            }
            stopSelf()
    }

    abstract val downloadNotId: Int

    companion object {
        var STATUS_DOWNLOAD_PROGRESS = "STATUS_DOWNLOAD_PROGRESS"
        var STATUS_DOWNLOAD_COMPLETED = "STATUS_DOWNLOAD_COMPLETED"
        var STATUS_DOWNLOAD_ERROR = "STATUS_DOWNLOAD_ERROR"
    }


}