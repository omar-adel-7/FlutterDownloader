package com.file.downloader

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ResultReceiver
import androidx.annotation.NonNull
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_ADDED
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_CANCELED
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_COMPLETED
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_ERROR
import com.file.downloader.IDownloadService.Companion.STATUS_DOWNLOAD_PROGRESS
import com.file.downloader.IDownloadService.Companion.getListData

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** DownloaderPlugin */
class DownloaderPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    val CHANNEL_DOWNLOAD = "download"
    private val CHANNEL_DOWNLOAD_START = "start"
    private val CHANNEL_CANCEL_SINGLE = "cancelSingle"
    private val CHANNEL_CANCEL_ALL = "cancelAll"
    private val CHANNEL_RESULT_ADDED = "resultAdded"
    private val CHANNEL_RESULT_PROGRESS = "resultProgress"
    private val CHANNEL_RESULT_CANCELED = "resultCanceled"
    private val CHANNEL_RESULT_COMPLETED = "resultCompleted"
    private val CHANNEL_RESULT_ERROR = "resultError"
    private val CHANNEL_RESULT_GET_INITIAL_LIST_DATA = "resultGetInitialListData"

    private var context: Context? = null
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        if(methodChannel==null){
            initPlugin(flutterPluginBinding.binaryMessenger)
        }
        context = binding.applicationContext
        methodChannel?.invokeMethod(
            CHANNEL_RESULT_GET_INITIAL_LIST_DATA, hashMapOf(
                "listData" to getListData()
            )
        )
    }


    private fun initPlugin(binaryMessenger: BinaryMessenger) {
        methodChannel = MethodChannel(binaryMessenger, CHANNEL_DOWNLOAD)
        methodChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method.equals(CHANNEL_DOWNLOAD_START)) {
            val argsMap = call.arguments as HashMap<*, *>
            val url = argsMap["url"] as String
            val destinationPath = argsMap["destinationPath"] as String
            val fileName = argsMap["fileName"] as String
            val notificationMessage = argsMap["notificationMessage"] as String
            val notificationProgressMessage = argsMap["notificationProgressMessage"] as String?
            val notificationCompleteMessage = argsMap["notificationCompleteMessage"] as String?
            context?.let { context ->
                val intent = Intent(context, DownloadService::class.java)
                intent.action = context.getString(
                    R.string.download_ACTION_START
                )
                intent.putExtra(IDownload.SRC_URL_KEY, url)
                intent.putExtra(IDownload.SRC_DEST_DIR_PATH_KEY, destinationPath)
                intent.putExtra(
                    IDownload.SRC_FILE_NAME_KEY,
                    fileName
                )
                intent.putExtra(IDownload.SRC_NOTIFICATION_MESSAGE, notificationMessage)
                intent.putExtra(IDownload.SRC_NOTIFICATION_PROGRESS_MESSAGE, notificationProgressMessage)
                intent.putExtra(IDownload.SRC_NOTIFICATION_COMPLETE_MESSAGE, notificationCompleteMessage)

                intent.putExtra(
                    IDownload.ResultReceiver_Key,
                    object : ResultReceiver(Handler(Looper.getMainLooper())) {
                        override fun onReceiveResult(resultCode: Int, resultData: Bundle) {
                            super.onReceiveResult(resultCode, resultData)
                            val url = resultData.getString(IDownload.ResultReceiver_Url)
                            val status = resultData.getString(IDownload.ResultReceiver_Status)
                            val progress = resultData.getInt(IDownload.ResultReceiver_Progress)
                            val error = resultData.getString(IDownload.ResultReceiver_Error)
                            if (status == STATUS_DOWNLOAD_ADDED) {
                                methodChannel?.invokeMethod(
                                    CHANNEL_RESULT_ADDED, hashMapOf(
                                        "listData" to getListData(),
                                        "url" to url,
                                    )
                                )
                            } else if (status == STATUS_DOWNLOAD_PROGRESS) {
                                methodChannel?.invokeMethod(
                                    CHANNEL_RESULT_PROGRESS, hashMapOf(
                                        "listData" to getListData(),
                                        "url" to url,
                                        "progress" to progress,
                                    )
                                )
                            } else if (status == STATUS_DOWNLOAD_CANCELED) {
                                methodChannel?.invokeMethod(
                                    CHANNEL_RESULT_CANCELED, hashMapOf(
                                        "listData" to getListData(),
                                        "url" to url
                                    )
                                )
                            } else if (status == STATUS_DOWNLOAD_COMPLETED) {
                                methodChannel?.invokeMethod(
                                    CHANNEL_RESULT_COMPLETED, hashMapOf(
                                        "listData" to getListData(),
                                        "url" to url
                                    )
                                )
                            } else if (status == STATUS_DOWNLOAD_ERROR) {
                                methodChannel?.invokeMethod(
                                    CHANNEL_RESULT_ERROR, hashMapOf(
                                        "listData" to getListData(),
                                        "url" to url,
                                        "error" to error,
                                    )
                                )
                            }
                        }
                    })
                context.startService(intent)
            }
        } else if (call.method.equals(CHANNEL_CANCEL_SINGLE)) {
            val argsMap = call.arguments as HashMap<*, *>
            val url = argsMap["url"] as String
            context?.let { context -> DownloadService.cancelDownloadFile(context, url) }
        } else if (call.method.equals(CHANNEL_CANCEL_ALL)) {
            context?.let { context -> DownloadService.cancelDownloads(context) }
        } else {
            result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        initPlugin(flutterPluginBinding.binaryMessenger)
    }


    override fun onDetachedFromActivity() {
        context = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    companion object {
        private var methodChannel: MethodChannel? = null
        private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    }


}
