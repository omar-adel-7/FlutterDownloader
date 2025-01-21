package com.file.downloader

import android.app.Notification
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.ResultReceiver
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future


abstract class IDownloadService : Service() {
    var resultReceiver: ResultReceiver? = null
    var lastProgressTime: Long = 0

    //    val executorService: ExecutorService = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors())
    val executorService: ExecutorService = Executors.newFixedThreadPool(4)
    var runnableResults: HashMap<String, Future<*>?> = HashMap<String, Future<*>?>()
    protected abstract fun getNotificationBuilderOfDownload(
        notificationMessage: String, notificationProgressMessage: String
    ): NotificationCompat.Builder

    protected abstract fun getNotificationBuilderOfCompleteDownload(
        notificationMessage: String, notificationCompleteMessage: String
    ): NotificationCompat.Builder

    protected abstract fun onStartCommandCustom(intent: Intent?)
    protected abstract fun notifyProgress(url: String, notification: Notification?)
    protected abstract fun notifySuccess(url: String, notification: Notification?)
    protected abstract fun notifyError(url: String)
    protected abstract fun notifyStoppedService()
    abstract fun callbackBeforeError(downloadErrorMessage: String)
    abstract fun sendEvent(message: Bundle)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        onStartCommandCustom(intent)
        if (intent != null) {
            val action = intent.action
            if (action != null) {
                if (action == resources.getString(
                        R.string.download_ACTION_CANCEL_DOWNLOAD
                    )
                ) {
                    val url = intent.getStringExtra(IDownload.SRC_URL_KEY)
                    val result : Future<*>? = runnableResults[url]
                    if(result!=null){
                        if(!result.isDone)
                        {
                            result.cancel(true)
                        }
                    }
                } else
                    if (action == resources.getString(
                            R.string.download_ACTION_CANCEL_DOWNLOADS
                        )
                    ) {
                        executorService.shutdown()
                        executorService.shutdownNow()
                        notifyStoppedService()
                        stopSelf()
                    } else if (action == resources.getString(
                            R.string.download_ACTION_DOWNLOAD
                        )
                    ) {
                        val url = intent.getStringExtra(IDownload.SRC_URL_KEY)
                        val destDirPath = intent.getStringExtra(IDownload.SRC_DEST_DIR_PATH_KEY)
                        val fileName =
                            intent.getStringExtra(IDownload.SRC_FILE_NAME_KEY)
                        val notificationMessage =
                            intent.getStringExtra(IDownload.SRC_NOTIFICATION_MESSAGE)
                        val notificationProgressMessage =
                            intent.getStringExtra(IDownload.SRC_NOTIFICATION_PROGRESS_MESSAGE)
                        val notificationCompleteMessage =
                            intent.getStringExtra(IDownload.SRC_NOTIFICATION_COMPLETE_MESSAGE)
                        resultReceiver =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                intent.getParcelableExtra(
                                    IDownload.ResultReceiver_Key,
                                    ResultReceiver::class.java
                                )
                            } else {
                                intent.getParcelableExtra(IDownload.ResultReceiver_Key)
                            }

                        if (
                            url != null
                            && notificationMessage != null
                            && notificationProgressMessage != null
                            && notificationCompleteMessage != null
                        ) {
                            startDownload(
                                url,
                                destDirPath + fileName,
                                notificationMessage,
                                notificationProgressMessage,
                                notificationCompleteMessage
                            )
                        }
                    }
            }
        }
        return START_STICKY
    }

    fun startDownload(
        link: String,
        filePath: String,
        notificationMessage: String,
        notificationProgressMessage: String,
        notificationCompleteMessage: String

    ) {
        val result : Future<*>? = executorService.submit(Runnable {
            val tempFilePath = filePath + "temp"
            var connection: HttpURLConnection? = null
            var input: InputStream? = null
            var output: OutputStream? = null
            try {
                val url = URL(link)
                connection = url.openConnection() as HttpURLConnection
                connection.setRequestProperty("Accept-Encoding", "identity")
                connection.connectTimeout = 15000
                connection.connect()
                if (!IDownload.createFolderIfNotExists(
                        IDownload.getFolderPathOfFile(
                            filePath
                        )
                    )
                ) {
                    sendSuccessError(
                        link,
                        false,
                        IDownload.RESPONSE_CREATE_FOLDER_ERROR_MESSAGE,
                        notificationMessage,
                        notificationCompleteMessage
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
                                filePath
                            )
                        )
                    )
                    < fileSizeInbytes
                ) {
                    sendSuccessError(
                        link, false,
                        IDownload.RESPONSE_NO_FREE_SPACE_MESSAGE,
                        notificationMessage,
                        notificationCompleteMessage
                    )
                    return@Runnable
                }

                input = BufferedInputStream(url.openStream())
                output = FileOutputStream(tempFilePath)
                val data = ByteArray(4096)
                var totalDownloaded = 0.0
                var currentDownload: Int = 0
                while ((input.read(data).also { currentDownload = it }) != -1) {
                    if (Thread.currentThread().isInterrupted) {
                        // Executor has probably asked us to stop
                        Log.e("Thread.currentThread().isInterrupted ","true")
                         break
                    }
                    totalDownloaded += currentDownload.toDouble()
                    tmp = totalDownloaded / 1024
                    tmp /= 1024
                    tmp *= 100
                    if (fileSizeInbytes > 0) {
                        val progress = tmp / fileSizeInbytes
                        sendProgress(
                            link, progress.toInt(),
                            notificationMessage, notificationProgressMessage
                        )
                    }
                    output.write(data, 0, currentDownload)
                }
                if (!Thread.currentThread().isInterrupted) {
                    val tempFile = File(tempFilePath)
                    val targetFile = File(filePath)
                    tempFile.renameTo(targetFile)
                    sendSuccessError(
                        link, true, null,
                        notificationMessage,
                        notificationCompleteMessage
                    )
                } else {
                    deleteDownloadFile(tempFilePath)
                    Log.e("Thread.currentThread().isInterrupted ","true")
                }
            } catch (e: Exception) {
                e.printStackTrace()
                deleteDownloadFile(tempFilePath)
                sendSuccessError(
                    link, false,
                    IDownload.RESPONSE_CONNECTION_ERROR_MESSAGE,
                    notificationMessage,
                    notificationCompleteMessage
                )
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
        })
        runnableResults.put(link,result)
    }

    private fun deleteDownloadFile(tempFilePath: String) {
        IDownload.DeleteRecursive(
            this,
            tempFilePath
        )
    }

    fun sendProgress(
        url: String, progress: Int,
        notificationMessage: String, notificationProgressMessage: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putInt(IDownload.RESPONSE_PROGRESS_KEY, progress)
        val time = Date().time
        if (time - lastProgressTime >= 1200) {
            sendEvent(message)
            val notificationBuilder = getNotificationBuilderOfDownload(
                notificationMessage, notificationProgressMessage
            )
            lastProgressTime = time
            notificationBuilder.setProgress(100, progress, false)
            notifyProgress(url, notificationBuilder.build())
        }
    }

    fun sendSuccessError(
        url: String,
        isSuccess: Boolean, errorMessage: String?,
        notificationMessage: String, notificationCompleteMessage: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putBoolean(IDownload.RESPONSE_SUCCESS_ERROR_KEY, isSuccess)
        if (!isSuccess) {
            message.putString(IDownload.RESPONSE_ERROR_MESSAGE_KEY, errorMessage)
            if (errorMessage != null) {
                callbackBeforeError(errorMessage)
            }
            notifyError(url);
        }
        if (isSuccess) {
            val notificationBuilder = getNotificationBuilderOfCompleteDownload(
                notificationMessage, notificationCompleteMessage
            )
            notifySuccess(url, notificationBuilder.build())
        }
        sendEvent(message)
    }

    companion object {
        var STATUS_DOWNLOAD_PROGRESS = "STATUS_DOWNLOAD_PROGRESS"
        var STATUS_DOWNLOAD_COMPLETED = "STATUS_DOWNLOAD_COMPLETED"
        var STATUS_DOWNLOAD_ERROR = "STATUS_DOWNLOAD_ERROR"
    }


}