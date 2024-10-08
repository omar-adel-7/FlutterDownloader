package com.file.downloader

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ResultReceiver
import androidx.annotation.NonNull
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_COMPLETED
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_ERROR
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_PROGRESS

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** DownloaderPlugin */
class DownloaderPlugin : FlutterPlugin, MethodCallHandler {

    val CHANNEL_DOWNLOAD = "download"
    private val CHANNEL_DOWNLOAD_START = "startDownload"
    private val CHANNEL_DOWNLOAD_RESULT_PROGRESS = "downloadResultProgress"
    private val CHANNEL_DOWNLOAD_RESULT_COMPLETED = "downloadResultCompleted"
    private val CHANNEL_DOWNLOAD_RESULT_ERROR = "downloadResultError"
    private val CHANNEL_DOWNLOAD_STOP_SERVICE = "stopDownloadService"


    private var methodChannelDownload: MethodChannel? = null
    private var context: Context? = null
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannelDownload =
            MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_DOWNLOAD)
        methodChannelDownload?.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, @NonNull result: MethodChannel.Result) {
            if (call.method.equals(CHANNEL_DOWNLOAD_START)) {
            val argsMap = call.arguments as HashMap<*, *>
            val id = argsMap["id"] as String
            val url = argsMap["url"] as String
            val destinationDirPath = argsMap["destinationDirPath"] as String
            val fileName = argsMap["fileName"] as String
            val notificationMessage = argsMap["notificationMessage"] as String
            val notificationProgressMessage = argsMap["notificationProgressMessage"] as String
            val notificationCompleteMessage = argsMap["notificationCompleteMessage"] as String

            context?.let { context ->
                val intent = Intent(context, DownloadService::class.java)
                intent.action = context.getString(
                    R.string.download_ACTION_DOWNLOAD_ITEM
                )
                intent.putExtra(IDownload.SRC_ID_KEY, id)
                intent.putExtra(IDownload.SRC_URL_KEY, url)
                intent.putExtra(IDownload.SRC_DEST_DIR_PATH_KEY, destinationDirPath)
                intent.putExtra(
                    IDownload.SRC_FILE_NAME_KEY,
                    fileName
                )
                intent.putExtra(IDownload.SRC_NOTIFICATION_MESSAGE, notificationMessage)
                intent.putExtra(
                    IDownload.SRC_NOTIFICATION_PROGRESS_MESSAGE,
                    notificationProgressMessage
                )
                intent.putExtra(
                    IDownload.SRC_NOTIFICATION_COMPLETE_MESSAGE,
                    notificationCompleteMessage
                )
                intent.putExtra(
                    IDownload.ResultReceiver_Key,
                    object : ResultReceiver(Handler(Looper.getMainLooper())) {
                        override fun onReceiveResult(resultCode: Int, resultData: Bundle) {
                            super.onReceiveResult(resultCode, resultData)
                            val id = resultData.getString(IDownload.ResultReceiver_Id)
                            val url = resultData.getString(IDownload.ResultReceiver_Url)
                            val status = resultData.getString(IDownload.ResultReceiver_Status)
                            val progress = resultData.getInt(IDownload.ResultReceiver_Progress)
                            val error = resultData.getString(IDownload.ResultReceiver_Error)

                            if (status == STATUS_DOWNLOAD_PROGRESS) {
                                methodChannelDownload?.invokeMethod(
                                    CHANNEL_DOWNLOAD_RESULT_PROGRESS, hashMapOf(
                                        "id" to id,
                                        "url" to url,
                                        "progress" to progress,
                                    )
                                )
                            } else if (status == STATUS_DOWNLOAD_COMPLETED) {
                                methodChannelDownload?.invokeMethod(
                                    CHANNEL_DOWNLOAD_RESULT_COMPLETED, hashMapOf(
                                        "id" to id,
                                        "url" to url
                                    )
                                )
                            } else if (status == STATUS_DOWNLOAD_ERROR) {
                                methodChannelDownload?.invokeMethod(
                                    CHANNEL_DOWNLOAD_RESULT_ERROR, hashMapOf(
                                        "id" to id,
                                        "url" to url,
                                        "error" to error,
                                    )
                                )
                            }
                        }
                    })
                context.startService(intent)
            }
        }
            else if (call.method.equals(CHANNEL_DOWNLOAD_STOP_SERVICE)) {
                context?.let { context -> DownloadService.stopService(context) }
            }
        else {
                result.notImplemented()
            }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        methodChannelDownload?.setMethodCallHandler(null)
        methodChannelDownload = null
    }

}
