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
import kotlin.String

import android.content.SharedPreferences

abstract class IDownloadService : Service() {
    var prefs: SharedPreferences? = null
    val prefsKeyPrefix = "flutter."
    var isSerial: Boolean = true
    var parallelMainNotificationMessage: String = ""
    var notificationProgressMessage: String = ""
    var notificationCompleteMessage: String = ""

    var resultReceiver: ResultReceiver? = null
    var lastProgressTime: Long = 0

    var executorService: ExecutorService? = null
    var runnableResults: HashMap<String, Future<*>?> = HashMap<String, Future<*>?>()

    val notificationId: Int
        get() = 1

    protected abstract fun getParallelMainNotificationBuilder(
    ): NotificationCompat.Builder

    protected abstract fun getNotificationBuilderOfDownload(
        notificationMessage: String
    ): NotificationCompat.Builder

    protected abstract fun getNotificationBuilderOfCompleteDownload(
        notificationMessage: String
    ): NotificationCompat.Builder

    protected abstract fun onStartCommandCustom(intent: Intent?)
    protected abstract fun notifyProgress(url: String, notification: Notification?)
    protected abstract fun notifySuccess(url: String, notification: Notification?)
    protected abstract fun notifyError(url: String)
    protected abstract fun notifyCanceled(url: String)
    protected abstract fun notifyStoppedService()
    abstract fun callbackBeforeError(downloadErrorMessage: String)
    abstract fun sendEvent(message: Bundle)

    override fun onCreate() {
        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        isSerial = prefs?.getBoolean(prefsKeyPrefix + "isSerial", isSerial) ?: isSerial
        parallelMainNotificationMessage = prefs?.getString(
            prefsKeyPrefix + "parallelMainNotificationMessage",
            parallelMainNotificationMessage
        ) ?: parallelMainNotificationMessage
        notificationProgressMessage = prefs?.getString(
            prefsKeyPrefix + "notificationProgressMessage",
            notificationProgressMessage
        ) ?: notificationProgressMessage
        notificationCompleteMessage = prefs?.getString(
            prefsKeyPrefix + "notificationCompleteMessage",
            notificationCompleteMessage
        ) ?: notificationCompleteMessage

        executorService = Executors.newFixedThreadPool(if (isSerial) 1 else 4)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        onStartCommandCustom(intent)
        if (intent != null) {
            val action = intent.action
            if (action != null) {
                if (action == resources.getString(
                        R.string.download_ACTION_START
                    )
                ) {
                    val url = intent.getStringExtra(IDownload.SRC_URL_KEY)
                    val destDirPath = intent.getStringExtra(IDownload.SRC_DEST_DIR_PATH_KEY)
                    val fileName =
                        intent.getStringExtra(IDownload.SRC_FILE_NAME_KEY)
                    val notificationMessage =
                        intent.getStringExtra(IDownload.SRC_NOTIFICATION_MESSAGE)
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
                        url != null && notificationMessage != null
                    ) {
                        if (isSerial) {
                            startForeground( /*FOREGROUND_ID*/notificationId,
                                getNotificationBuilderOfDownload(
                                    notificationMessage,
                                ).build()
                            )
                        } else {
                            startForeground( /*FOREGROUND_ID*/notificationId,
                                getParallelMainNotificationBuilder().build()
                            )
                        }
                        startDownload(
                            url,
                            destDirPath + fileName,
                            notificationMessage
                        )
                    }
                } else if (action == resources.getString(
                        R.string.download_ACTION_CANCEL_SINGLE
                    )
                ) {
                    val url = intent.getStringExtra(IDownload.SRC_URL_KEY)
                    if (url != null) {
                        val result: Future<*>? = runnableResults[url]
                        if (result != null) {
                            if (!result.isDone) {
                                val cancelResult = result.cancel(true)
                                Log.e("runnableResult isDone = ", "false")
                                Log.e("runnableResult cancel(true) = ", cancelResult.toString())
                                delete(url)
                                notifyCanceled(url)
                                sendCanceled(url)
                                checkToStopService()
                            } else {
                                Log.e("runnableResult isDone = ", "true")
                            }
                        }
                    }
                } else
                    if (action == resources.getString(
                            R.string.download_ACTION_CANCEL_ALL
                        )
                    ) {
                        runnableResults.clear()
                        downloadModelList.clear()
                        stopThisService()
                    }
            }
        }
        return START_STICKY
    }

    fun startDownload(
        link: String,
        filePath: String,
        notificationMessage: String,
    ) {
        downloadModelList.add(DownloadModel(link))
        sendAdded(link)
        val result: Future<*>? = executorService?.submit(Runnable {
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
                        Log.e("in loop Thread.currentThread().isInterrupted ", "true")
                        break
                    }
                    totalDownloaded += currentDownload.toDouble()
                    tmp = totalDownloaded / 1024
                    tmp /= 1024
                    tmp *= 100
                    if (fileSizeInbytes > 0) {
                        val progress = tmp / fileSizeInbytes
                        sendProgress(
                            link,
                            progress.toInt(),
                            notificationMessage
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
                    )
                } else {
                    deleteDownloadFile(tempFilePath)
                    Log.e("after loop Thread.currentThread().isInterrupted ", "true")
                }
            } catch (e: Exception) {
                e.printStackTrace()
                deleteDownloadFile(tempFilePath)
                sendSuccessError(
                    link, false,
                    IDownload.RESPONSE_CONNECTION_ERROR_MESSAGE,
                    notificationMessage,
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
        runnableResults.put(link, result)
    }

    private fun deleteDownloadFile(tempFilePath: String) {
        IDownload.DeleteRecursive(
            this,
            tempFilePath
        )
    }

    fun sendAdded(
        url: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putString(IDownload.RESPONSE_ADDED_KEY, null)
        sendEvent(message)
    }

    fun sendProgress(
        url: String, progress: Int,
        notificationMessage: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putInt(IDownload.RESPONSE_PROGRESS_KEY, progress)
        val time = Date().time
        if (time - lastProgressTime >= 1200) {
            updateProgress(url, progress)
            val notificationBuilder = getNotificationBuilderOfDownload(
                notificationMessage
            )
            lastProgressTime = time
            notificationBuilder.setProgress(100, progress, false)
            notifyProgress(url, notificationBuilder.build())
            Log.e("android idownloadservice","sendProgress")
            sendEvent(message)
        }
    }

    fun updateProgress(url: String, progress: Int) {
        if (downloadModelList.any { it.url == url }) {
            val index = downloadModelList.indexOfFirst { it.url == url }
            if ((index != -1) && (index < downloadModelList.size))
                downloadModelList[index].progress = progress
        }
    }

    fun sendCanceled(
        url: String
    ) {
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putString(IDownload.RESPONSE_CANCELED_KEY, null)
        sendEvent(message)
    }

    fun sendSuccessError(
        url: String,
        isSuccess: Boolean, errorMessage: String?,
        notificationMessage: String
    ) {
        delete(url)
        val message = Bundle()
        message.putString(IDownload.RESPONSE_URL_KEY, url)
        message.putBoolean(IDownload.RESPONSE_SUCCESS_ERROR_KEY, isSuccess)
        if (!isSuccess) {
            message.putString(IDownload.RESPONSE_ERROR_MESSAGE_KEY, errorMessage)
            if (errorMessage != null) {
                callbackBeforeError(errorMessage)
            }
            notifyError(url)
        }
        if (isSuccess) {
            val notificationBuilder = getNotificationBuilderOfCompleteDownload(
                notificationMessage
            )
            notifySuccess(url, notificationBuilder.build())
        }
        sendEvent(message)
        checkToStopService()
    }


    fun delete(url: String) {
        runnableResults.remove(url)
        downloadModelList.removeAll { item -> item.url == url }
    }

    fun checkToStopService() {
        if (downloadModelList.isEmpty()) {
            stopThisService()
        }
    }

    fun stopThisService() {
        executorService?.shutdown()
        executorService?.shutdownNow()
        if (!isSerial) {
            notifyStoppedService()
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            stopForeground(true)
        }
        stopSelf()
    }

    companion object {
        var downloadModelList: MutableList<DownloadModel> = mutableListOf()
        fun getListData(): String {
            var data = ""
            for (i in 0 until downloadModelList.size) {
                data = (data + downloadModelList[i].url
                        +DOWNLOADER_LIST_ITEM_INTERNAL_KEY
                        +downloadModelList[i].progress
                        +DOWNLOADER_LIST_DIVIDER_KEY)
            }
            return data
        }
        val STATUS_DOWNLOAD_ADDED = "STATUS_DOWNLOAD_ADDED"
        val STATUS_DOWNLOAD_PROGRESS = "STATUS_DOWNLOAD_PROGRESS"
        val STATUS_DOWNLOAD_CANCELED = "STATUS_DOWNLOAD_CANCELED"
        val STATUS_DOWNLOAD_COMPLETED = "STATUS_DOWNLOAD_COMPLETED"
        val STATUS_DOWNLOAD_ERROR = "STATUS_DOWNLOAD_ERROR"
        val DOWNLOADER_LIST_ITEM_INTERNAL_KEY = "downloader-internal"
        val DOWNLOADER_LIST_DIVIDER_KEY = "downloader-divider" }


}